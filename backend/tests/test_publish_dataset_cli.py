import gzip
from collections.abc import Mapping
from pathlib import Path

import pytest
from sqlalchemy.orm import Session, sessionmaker

from app.datasets.service import build_dataset_manifest
from scripts.publish_dataset import PublishDatasetCommand, PublishError, publish_dataset


class FakeStorageAdapter:
    def __init__(self) -> None:
        self.uploads: list[tuple[Path, str, Mapping[str, str] | None]] = []
        self.existing_keys: set[str] = set()

    def object_exists(self, storage_key: str) -> bool:
        return storage_key in self.existing_keys

    def upload_file(
        self,
        file_path: Path,
        storage_key: str,
        metadata: Mapping[str, str] | None = None,
    ) -> None:
        self.uploads.append((file_path, storage_key, metadata))

    def create_presigned_download_url(self, storage_key: str, expires_in_seconds: int) -> str:
        return f"https://storage.test/{storage_key}?expires={expires_in_seconds}"


def create_sqlite_gzip_file(tmp_path: Path, content: bytes = b"sqlite payload") -> Path:
    file_path = tmp_path / "core-en-v1.0.0.sqlite.gz"
    with gzip.open(file_path, "wb") as file:
        file.write(content)
    return file_path


def publish_command(file_path: Path, *, dry_run: bool = False) -> PublishDatasetCommand:
    return PublishDatasetCommand(
        dataset_key="core-en",
        language="en",
        domain="core",
        version="1.0.0",
        sqlite_schema_version=1,
        file=file_path,
        compression="gzip",
        title="Core English",
        dry_run=dry_run,
    )


def test_publish_dataset_uploads_file_and_registers_manifest(
    tmp_path: Path,
    db_session_factory: sessionmaker[Session],
) -> None:
    file_path = create_sqlite_gzip_file(tmp_path)
    storage = FakeStorageAdapter()

    with db_session_factory() as db:
        summary = publish_dataset(publish_command(file_path), db, storage)
        manifest = build_dataset_manifest(db)

    assert summary.uploaded is True
    assert summary.storage_key == "core/en/1.0.0/core-en-v1.0.0.sqlite.gz"
    assert summary.compressed_size_bytes == file_path.stat().st_size
    assert summary.file_size_bytes == len(b"sqlite payload")
    assert len(summary.checksum_sha256) == 64

    assert storage.uploads == [
        (
            file_path,
            "core/en/1.0.0/core-en-v1.0.0.sqlite.gz",
            {
                "dataset_key": "core-en",
                "version": "1.0.0",
                "sqlite_schema_version": "1",
                "checksum_sha256": summary.checksum_sha256,
                "compression": "gzip",
            },
        )
    ]

    assert len(manifest.datasets) == 1
    assert manifest.datasets[0].dataset_key == "core-en"
    assert manifest.datasets[0].latest_version == "1.0.0"
    assert manifest.datasets[0].checksum_sha256 == summary.checksum_sha256


def test_publish_dataset_rejects_duplicate_version_without_force(
    tmp_path: Path,
    db_session_factory: sessionmaker[Session],
) -> None:
    file_path = create_sqlite_gzip_file(tmp_path)
    storage = FakeStorageAdapter()

    with db_session_factory() as db:
        publish_dataset(publish_command(file_path), db, storage)

    duplicate_storage = FakeStorageAdapter()
    with db_session_factory() as db:
        with pytest.raises(PublishError, match="Dataset version already exists"):
            publish_dataset(publish_command(file_path), db, duplicate_storage)

    assert duplicate_storage.uploads == []


def test_publish_dataset_dry_run_does_not_upload_or_commit(
    tmp_path: Path,
    db_session_factory: sessionmaker[Session],
) -> None:
    file_path = create_sqlite_gzip_file(tmp_path)
    storage = FakeStorageAdapter()

    with db_session_factory() as db:
        summary = publish_dataset(publish_command(file_path, dry_run=True), db, storage)
        manifest = build_dataset_manifest(db)

    assert summary.dry_run is True
    assert summary.uploaded is False
    assert summary.created_dataset is True
    assert summary.created_version is True
    assert storage.uploads == []
    assert manifest.datasets == []


def test_publish_dataset_rejects_existing_storage_object(
    tmp_path: Path,
    db_session_factory: sessionmaker[Session],
) -> None:
    file_path = create_sqlite_gzip_file(tmp_path)
    storage = FakeStorageAdapter()
    storage.existing_keys.add("core/en/1.0.0/core-en-v1.0.0.sqlite.gz")

    with db_session_factory() as db:
        with pytest.raises(PublishError, match="Storage object already exists"):
            publish_dataset(publish_command(file_path), db, storage)

    assert storage.uploads == []
