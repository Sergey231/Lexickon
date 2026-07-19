from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


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
