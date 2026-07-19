import re
from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.datasets.models import Dataset, DatasetVersion
from app.datasets.schemas import DatasetManifestItem, DatasetManifestResponse

SEMVER_PATTERN = re.compile(r"^(\d+)\.(\d+)\.(\d+)$")


def list_public_datasets(db: Session) -> list[Dataset]:
    return list(
        db.scalars(
            select(Dataset)
            .where(Dataset.is_public.is_(True))
            .options(joinedload(Dataset.versions))
            .order_by(Dataset.dataset_key)
        )
        .unique()
        .all()
    )


def get_public_dataset_by_key(db: Session, dataset_key: str) -> Dataset | None:
    return (
        db.scalars(
            select(Dataset)
            .where(Dataset.dataset_key == dataset_key, Dataset.is_public.is_(True))
            .options(joinedload(Dataset.versions))
        )
        .unique()
        .one_or_none()
    )


def semver_sort_key(version: str) -> tuple[int, int, int]:
    match = SEMVER_PATTERN.fullmatch(version)
    if match is None:
        return (-1, -1, -1)
    return tuple(int(part) for part in match.groups())


def latest_active_version(dataset: Dataset) -> DatasetVersion | None:
    active_versions = [version for version in dataset.versions if version.status == "active"]
    if not active_versions:
        return None
    return max(active_versions, key=lambda version: semver_sort_key(version.version))


def build_dataset_manifest(db: Session) -> DatasetManifestResponse:
    items: list[DatasetManifestItem] = []
    for dataset in list_public_datasets(db):
        version = latest_active_version(dataset)
        if version is None:
            continue

        items.append(
            DatasetManifestItem(
                dataset_key=dataset.dataset_key,
                language=dataset.language,
                domain=dataset.domain,
                title=dataset.title,
                latest_version=version.version,
                version_id=version.id,
                sqlite_schema_version=version.sqlite_schema_version,
                compression=version.compression,
                file_size_bytes=version.file_size_bytes,
                compressed_size_bytes=version.compressed_size_bytes,
                checksum_sha256=version.checksum_sha256,
                required_plan=dataset.required_plan,
                status=version.status,
            )
        )

    return DatasetManifestResponse(
        schema_version=1,
        generated_at=datetime.now(UTC),
        datasets=items,
    )
