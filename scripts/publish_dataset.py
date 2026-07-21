from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import sys
from collections.abc import Sequence
from dataclasses import asdict, dataclass
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.core.database import SessionLocal
from app.datasets.models import Dataset, DatasetVersion
from app.datasets.service import SEMVER_PATTERN
from app.datasets.storage import StorageAdapter, get_storage_adapter

CHUNK_SIZE = 1024 * 1024
VALID_STATUSES = {"active", "draft"}


class PublishError(Exception):
    pass


@dataclass(frozen=True)
class PublishDatasetCommand:
    dataset_key: str
    language: str
    domain: str
    version: str
    sqlite_schema_version: int
    file: Path
    compression: str
    title: str
    description: str | None = None
    required_plan: str = "free"
    release_notes: str | None = None
    status: str = "active"
    dry_run: bool = False
    force: bool = False


@dataclass(frozen=True)
class PublishDatasetSummary:
    dataset_key: str
    version: str
    status: str
    storage_key: str
    file_name: str
    file_size_bytes: int
    compressed_size_bytes: int
    checksum_sha256: str
    sqlite_schema_version: int
    compression: str
    required_plan: str
    dry_run: bool
    uploaded: bool
    created_dataset: bool
    created_version: bool
    replaced_version: bool


def calculate_sha256(file_path: Path) -> str:
    digest = hashlib.sha256()
    with file_path.open("rb") as file:
        for chunk in iter(lambda: file.read(CHUNK_SIZE), b""):
            digest.update(chunk)
    return digest.hexdigest()


def calculate_gzip_uncompressed_size(file_path: Path) -> int:
    size = 0
    with gzip.open(file_path, "rb") as file:
        for chunk in iter(lambda: file.read(CHUNK_SIZE), b""):
            size += len(chunk)
    return size


def normalize_command(command: PublishDatasetCommand) -> PublishDatasetCommand:
    return PublishDatasetCommand(
        dataset_key=command.dataset_key.strip().lower(),
        language=command.language.strip().lower(),
        domain=command.domain.strip().lower(),
        version=command.version.strip(),
        sqlite_schema_version=command.sqlite_schema_version,
        file=command.file.expanduser(),
        compression=command.compression.strip().lower(),
        title=command.title.strip(),
        description=command.description,
        required_plan=command.required_plan.strip().lower(),
        release_notes=command.release_notes,
        status=command.status.strip().lower(),
        dry_run=command.dry_run,
        force=command.force,
    )


def validate_command(command: PublishDatasetCommand) -> None:
    if not command.file.exists():
        raise PublishError(f"File does not exist: {command.file}")
    if not command.file.is_file():
        raise PublishError(f"Path is not a file: {command.file}")
    if command.compression != "gzip":
        raise PublishError("Only gzip compression is supported for publish CLI")
    if not command.file.name.endswith(".sqlite.gz"):
        raise PublishError("gzip dataset packs must use .sqlite.gz extension")
    if command.sqlite_schema_version <= 0:
        raise PublishError("sqlite-schema-version must be greater than 0")
    if command.status not in VALID_STATUSES:
        raise PublishError(f"status must be one of: {', '.join(sorted(VALID_STATUSES))}")
    if SEMVER_PATTERN.fullmatch(command.version) is None:
        raise PublishError("version must be SemVer in MAJOR.MINOR.PATCH format")
    expected_dataset_key = f"{command.domain}-{command.language}"
    if command.dataset_key != expected_dataset_key:
        raise PublishError(f"dataset-key must match domain-language: {expected_dataset_key}")
    if not command.title:
        raise PublishError("title is required")


def build_storage_key(command: PublishDatasetCommand) -> str:
    return (
        f"{command.domain}/{command.language}/{command.version}/"
        f"{command.dataset_key}-v{command.version}.sqlite.gz"
    )


def load_dataset(db: Session, dataset_key: str) -> Dataset | None:
    return (
        db.scalars(
            select(Dataset)
            .where(Dataset.dataset_key == dataset_key)
            .options(joinedload(Dataset.versions))
        )
        .unique()
        .one_or_none()
    )


def find_dataset_version(dataset: Dataset, version: str) -> DatasetVersion | None:
    for dataset_version in dataset.versions:
        if dataset_version.version == version:
            return dataset_version
    return None


def build_storage_metadata(
    command: PublishDatasetCommand,
    checksum_sha256: str,
) -> dict[str, str]:
    return {
        "dataset_key": command.dataset_key,
        "version": command.version,
        "sqlite_schema_version": str(command.sqlite_schema_version),
        "checksum_sha256": checksum_sha256,
        "compression": command.compression,
    }


def publish_dataset(
    command: PublishDatasetCommand,
    db: Session,
    storage: StorageAdapter,
) -> PublishDatasetSummary:
    command = normalize_command(command)
    validate_command(command)

    storage_key = build_storage_key(command)
    compressed_size_bytes = command.file.stat().st_size
    try:
        file_size_bytes = calculate_gzip_uncompressed_size(command.file)
    except OSError as error:
        raise PublishError("File is not a valid gzip dataset pack") from error
    checksum_sha256 = calculate_sha256(command.file)

    dataset = load_dataset(db, command.dataset_key)
    existing_version = (
        find_dataset_version(dataset, command.version) if dataset is not None else None
    )
    if existing_version is not None and not command.force:
        raise PublishError(
            f"Dataset version already exists: {command.dataset_key} {command.version}. "
            "Use --force to replace it."
        )

    summary = PublishDatasetSummary(
        dataset_key=command.dataset_key,
        version=command.version,
        status=command.status,
        storage_key=storage_key,
        file_name=command.file.name,
        file_size_bytes=file_size_bytes,
        compressed_size_bytes=compressed_size_bytes,
        checksum_sha256=checksum_sha256,
        sqlite_schema_version=command.sqlite_schema_version,
        compression=command.compression,
        required_plan=command.required_plan,
        dry_run=command.dry_run,
        uploaded=False,
        created_dataset=dataset is None,
        created_version=existing_version is None,
        replaced_version=existing_version is not None,
    )
    if command.dry_run:
        return summary

    metadata = build_storage_metadata(command, checksum_sha256)
    storage.upload_file(command.file, storage_key, metadata)

    if dataset is None:
        dataset = Dataset(
            dataset_key=command.dataset_key,
            language=command.language,
            domain=command.domain,
            title=command.title,
            description=command.description,
            required_plan=command.required_plan,
            is_public=True,
        )
        db.add(dataset)
        db.flush()
    else:
        dataset.language = command.language
        dataset.domain = command.domain
        dataset.title = command.title
        dataset.description = command.description
        dataset.required_plan = command.required_plan
        dataset.is_public = True

    if command.status == "active":
        for dataset_version in dataset.versions:
            if dataset_version.version != command.version and dataset_version.status == "active":
                dataset_version.status = "deprecated"

    published_at = datetime.now(UTC) if command.status == "active" else None
    if existing_version is None:
        db.add(
            DatasetVersion(
                dataset_id=dataset.id,
                version=command.version,
                sqlite_schema_version=command.sqlite_schema_version,
                storage_key=storage_key,
                file_name=command.file.name,
                file_size_bytes=file_size_bytes,
                compressed_size_bytes=compressed_size_bytes,
                checksum_sha256=checksum_sha256,
                compression=command.compression,
                status=command.status,
                release_notes=command.release_notes,
                published_at=published_at,
            )
        )
    else:
        existing_version.sqlite_schema_version = command.sqlite_schema_version
        existing_version.storage_key = storage_key
        existing_version.file_name = command.file.name
        existing_version.file_size_bytes = file_size_bytes
        existing_version.compressed_size_bytes = compressed_size_bytes
        existing_version.checksum_sha256 = checksum_sha256
        existing_version.compression = command.compression
        existing_version.status = command.status
        existing_version.release_notes = command.release_notes
        existing_version.published_at = published_at

    db.commit()
    return PublishDatasetSummary(**{**asdict(summary), "uploaded": True})


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Publish a ready SQLite dataset pack.")
    parser.add_argument("--dataset-key", required=True)
    parser.add_argument("--language", required=True)
    parser.add_argument("--domain", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--sqlite-schema-version", required=True, type=int)
    parser.add_argument("--file", required=True, type=Path)
    parser.add_argument("--compression", default="gzip")
    parser.add_argument("--title", required=True)
    parser.add_argument("--description")
    parser.add_argument("--required-plan", default="free")
    parser.add_argument("--release-notes")
    parser.add_argument("--status", default="active", choices=sorted(VALID_STATUSES))
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--force", action="store_true")
    return parser


def command_from_args(args: argparse.Namespace) -> PublishDatasetCommand:
    return PublishDatasetCommand(
        dataset_key=args.dataset_key,
        language=args.language,
        domain=args.domain,
        version=args.version,
        sqlite_schema_version=args.sqlite_schema_version,
        file=args.file,
        compression=args.compression,
        title=args.title,
        description=args.description,
        required_plan=args.required_plan,
        release_notes=args.release_notes,
        status=args.status,
        dry_run=args.dry_run,
        force=args.force,
    )


def print_json(payload: dict[str, Any], *, stream: Any = sys.stdout) -> None:
    print(json.dumps(payload, indent=2, sort_keys=True), file=stream)


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    command = command_from_args(args)

    try:
        with SessionLocal() as db:
            summary = publish_dataset(command, db, get_storage_adapter())
    except PublishError as error:
        print_json({"error": str(error)}, stream=sys.stderr)
        return 1

    print_json(asdict(summary))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
