import re
from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.datasets.models import Dataset, DatasetVersion
from app.datasets.schemas import (
    DatasetDownloadUrlResponse,
    DatasetManifestItem,
    DatasetManifestResponse,
    DatasetSyncAction,
    DatasetSyncRequest,
    DatasetSyncResponse,
    DatasetSyncStatus,
    InstalledDataset,
)
from app.users.models import User

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


def get_dataset_version_by_id(db: Session, version_id: UUID) -> DatasetVersion | None:
    return (
        db.scalars(
            select(DatasetVersion)
            .where(DatasetVersion.id == version_id)
            .options(joinedload(DatasetVersion.dataset))
        )
        .unique()
        .one_or_none()
    )


def semver_sort_key(version: str) -> tuple[int, int, int]:
    match = SEMVER_PATTERN.fullmatch(version)
    if match is None:
        return (-1, -1, -1)

    major, minor, patch = match.groups()
    return int(major), int(minor), int(patch)


def latest_active_version(dataset: Dataset) -> DatasetVersion | None:
    active_versions = [version for version in dataset.versions if version.status == "active"]
    if not active_versions:
        return None
    return max(active_versions, key=lambda version: semver_sort_key(version.version))


def dataset_key_for(language: str, domain: str) -> str:
    return f"{domain.strip().lower()}-{language.strip().lower()}"


def find_public_dataset_for_pair(
    datasets: list[Dataset], language: str, domain: str
) -> Dataset | None:
    normalized_language = language.strip().lower()
    normalized_domain = domain.strip().lower()
    for dataset in datasets:
        if dataset.language == normalized_language and dataset.domain == normalized_domain:
            return dataset
    return None


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


def build_update_action(
    dataset: Dataset,
    version: DatasetVersion,
    status: DatasetSyncStatus,
    installed: InstalledDataset | None = None,
) -> DatasetSyncAction:
    return DatasetSyncAction(
        dataset_key=dataset.dataset_key,
        status=status,
        installed_version=installed.version if installed is not None else None,
        latest_version=version.version,
        version_id=version.id,
        sqlite_schema_version=version.sqlite_schema_version,
        compressed_size_bytes=version.compressed_size_bytes,
        checksum_sha256=version.checksum_sha256,
        required_plan=dataset.required_plan,
    )


def is_installed_version_current(installed: InstalledDataset, latest: DatasetVersion) -> bool:
    return (
        installed.version == latest.version
        and installed.sqlite_schema_version == latest.sqlite_schema_version
        and installed.checksum_sha256 == latest.checksum_sha256
    )


def build_dataset_sync(db: Session, payload: DatasetSyncRequest) -> DatasetSyncResponse:
    public_datasets = list_public_datasets(db)
    installed_by_key = {dataset.dataset_key: dataset for dataset in payload.installed}
    actions: list[DatasetSyncAction] = []

    for wanted in payload.wanted:
        dataset = find_public_dataset_for_pair(public_datasets, wanted.language, wanted.domain)
        if dataset is None:
            actions.append(
                DatasetSyncAction(
                    dataset_key=dataset_key_for(wanted.language, wanted.domain),
                    status="unknown_dataset",
                )
            )
            continue

        latest = latest_active_version(dataset)
        if latest is None:
            actions.append(
                DatasetSyncAction(dataset_key=dataset.dataset_key, status="unknown_dataset")
            )
            continue

        installed = installed_by_key.get(dataset.dataset_key)
        if dataset.required_plan != "free":
            actions.append(build_update_action(dataset, latest, "not_allowed", installed))
            continue

        if installed is None:
            actions.append(build_update_action(dataset, latest, "missing"))
            continue

        if is_installed_version_current(installed, latest):
            actions.append(
                DatasetSyncAction(
                    dataset_key=dataset.dataset_key,
                    status="up_to_date",
                    installed_version=installed.version,
                    latest_version=latest.version,
                )
            )
            continue

        actions.append(build_update_action(dataset, latest, "update_available", installed))

    return DatasetSyncResponse(schema_version=1, actions=actions)


def can_download_dataset_version(user: User, version: DatasetVersion) -> bool:
    return version.dataset.required_plan == "free"


def build_download_url_response(
    version: DatasetVersion, url: str, expires_in_seconds: int
) -> DatasetDownloadUrlResponse:
    return DatasetDownloadUrlResponse(
        url=url,
        expires_at=datetime.now(UTC) + timedelta(seconds=expires_in_seconds),
        checksum_sha256=version.checksum_sha256,
        compressed_size_bytes=version.compressed_size_bytes,
        compression=version.compression,
    )
