from collections.abc import Mapping
from functools import lru_cache
from pathlib import Path
from typing import Protocol

from app.core.config import get_settings


class StorageAdapter(Protocol):
    def upload_file(
        self,
        file_path: Path,
        storage_key: str,
        metadata: Mapping[str, str] | None = None,
    ) -> None:
        raise NotImplementedError

    def create_presigned_download_url(self, storage_key: str, expires_in_seconds: int) -> str:
        raise NotImplementedError


class S3StorageAdapter(StorageAdapter):
    def __init__(
        self,
        endpoint_url: str,
        bucket: str,
        access_key_id: str,
        secret_access_key: str,
        region: str,
    ) -> None:
        self.endpoint_url = endpoint_url
        self.bucket = bucket
        self.access_key_id = access_key_id
        self.secret_access_key = secret_access_key
        self.region = region
        self._client_instance = None

    def upload_file(
        self,
        file_path: Path,
        storage_key: str,
        metadata: Mapping[str, str] | None = None,
    ) -> None:
        client = self._client()
        extra_args = {"Metadata": dict(metadata)} if metadata is not None else None
        if extra_args is None:
            client.upload_file(str(file_path), self.bucket, storage_key)
            return

        client.upload_file(str(file_path), self.bucket, storage_key, ExtraArgs=extra_args)

    def create_presigned_download_url(self, storage_key: str, expires_in_seconds: int) -> str:
        client = self._client()
        return str(
            client.generate_presigned_url(
                "get_object",
                Params={"Bucket": self.bucket, "Key": storage_key},
                ExpiresIn=expires_in_seconds,
            )
        )

    def _client(self):
        if self._client_instance is not None:
            return self._client_instance

        import boto3

        self._client_instance = boto3.client(
            "s3",
            endpoint_url=self.endpoint_url,
            aws_access_key_id=self.access_key_id,
            aws_secret_access_key=self.secret_access_key,
            region_name=self.region,
        )
        return self._client_instance


@lru_cache
def get_s3_storage_adapter() -> S3StorageAdapter:
    settings = get_settings()
    return S3StorageAdapter(
        endpoint_url=settings.storage_endpoint_url,
        bucket=settings.storage_bucket,
        access_key_id=settings.storage_access_key_id,
        secret_access_key=settings.storage_secret_access_key,
        region=settings.storage_region,
    )


def get_storage_adapter() -> StorageAdapter:
    return get_s3_storage_adapter()
