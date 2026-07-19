from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.datasets.models import Dataset
from app.datasets.schemas import (
    DatasetManifestResponse,
    DatasetResponse,
    DatasetSyncRequest,
    DatasetSyncResponse,
)
from app.datasets.service import (
    build_dataset_manifest,
    build_dataset_sync,
    get_public_dataset_by_key,
    list_public_datasets,
)

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


@router.get("/{dataset_key}", response_model=DatasetResponse)
def read_dataset(dataset_key: str, db: Annotated[Session, Depends(get_db)]) -> Dataset:
    dataset = get_public_dataset_by_key(db, dataset_key)
    if dataset is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dataset not found",
        )
    return dataset
