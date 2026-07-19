from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

DatasetSyncStatus = Literal[
    "up_to_date",
    "missing",
    "update_available",
    "not_allowed",
    "deprecated",
    "revoked",
    "unknown_dataset",
]


class DatasetVersionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    version: str
    sqlite_schema_version: int
    storage_key: str
    file_name: str
    file_size_bytes: int
    compressed_size_bytes: int
    checksum_sha256: str
    compression: str
    status: str
    release_notes: str | None
    created_at: datetime
    published_at: datetime | None


class DatasetResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    dataset_key: str
    language: str
    domain: str
    title: str
    description: str | None
    is_public: bool
    required_plan: str
    created_at: datetime
    updated_at: datetime
    versions: list[DatasetVersionResponse]


class DatasetManifestItem(BaseModel):
    dataset_key: str
    language: str
    domain: str
    title: str
    latest_version: str
    version_id: UUID
    sqlite_schema_version: int
    compression: str
    file_size_bytes: int
    compressed_size_bytes: int
    checksum_sha256: str
    required_plan: str
    status: str


class DatasetManifestResponse(BaseModel):
    schema_version: int
    generated_at: datetime
    datasets: list[DatasetManifestItem]


class InstalledDataset(BaseModel):
    dataset_key: str = Field(min_length=1, max_length=128)
    version: str = Field(min_length=1, max_length=32)
    sqlite_schema_version: int = Field(gt=0)
    checksum_sha256: str = Field(min_length=64, max_length=64)


class WantedDataset(BaseModel):
    language: str = Field(min_length=2, max_length=16)
    domain: str = Field(min_length=1, max_length=64)


class DatasetSyncRequest(BaseModel):
    client_schema_version: int = Field(gt=0)
    installed: list[InstalledDataset] = Field(default_factory=list)
    wanted: list[WantedDataset] = Field(min_length=1)


class DatasetSyncAction(BaseModel):
    dataset_key: str
    status: DatasetSyncStatus
    installed_version: str | None = None
    latest_version: str | None = None
    version_id: UUID | None = None
    sqlite_schema_version: int | None = None
    compressed_size_bytes: int | None = None
    checksum_sha256: str | None = None
    required_plan: str | None = None


class DatasetSyncResponse(BaseModel):
    schema_version: int
    actions: list[DatasetSyncAction]
