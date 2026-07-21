from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.auth.dependencies import get_current_user
from app.core.config import get_settings
from app.core.database import get_db
from app.datasets.models import Dataset
from app.datasets.schemas import (
    DatasetDownloadUrlResponse,
    DatasetManifestResponse,
    DatasetResponse,
    DatasetSyncRequest,
    DatasetSyncResponse,
)
from app.datasets.service import (
    build_dataset_manifest,
    build_dataset_sync,
    build_download_url_response,
    can_download_dataset_version,
    get_dataset_version_by_id,
    get_public_dataset_by_key,
    list_public_datasets,
)
from app.datasets.storage import StorageAdapter, get_storage_adapter
from app.users.models import User

router = APIRouter(prefix="/datasets", tags=["datasets"])


@router.get("/manifest", response_model=DatasetManifestResponse)
def read_dataset_manifest(db: Annotated[Session, Depends(get_db)]) -> DatasetManifestResponse:
    return build_dataset_manifest(db)


@router.get("", response_model=list[DatasetResponse])
def read_datasets(db: Annotated[Session, Depends(get_db)]) -> list[Dataset]:
    return list_public_datasets(db)


@router.post("/sync", response_model=DatasetSyncResponse)
def sync_datasets(
    payload: DatasetSyncRequest,
    db: Annotated[Session, Depends(get_db)],
) -> DatasetSyncResponse:
    return build_dataset_sync(db, payload)


@router.post("/versions/{version_id}/download-url", response_model=DatasetDownloadUrlResponse)
def create_dataset_version_download_url(
    version_id: UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
    storage: Annotated[StorageAdapter, Depends(get_storage_adapter)],
) -> DatasetDownloadUrlResponse:
    version = get_dataset_version_by_id(db, version_id)
    if version is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dataset version not found",
        )

    if version.status == "revoked":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Dataset version is revoked",
        )

    if version.status not in {"active", "deprecated"}:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Dataset version is not downloadable",
        )

    if not can_download_dataset_version(current_user, version):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User does not have access to this dataset",
        )

    settings = get_settings()
    url = storage.create_presigned_download_url(
        version.storage_key,
        settings.storage_signed_url_expire_seconds,
    )
    return build_download_url_response(version, url, settings.storage_signed_url_expire_seconds)


@router.get("/{dataset_key}", response_model=DatasetResponse)
def read_dataset(dataset_key: str, db: Annotated[Session, Depends(get_db)]) -> Dataset:
    dataset = get_public_dataset_by_key(db, dataset_key)
    if dataset is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dataset not found",
        )
    return dataset
