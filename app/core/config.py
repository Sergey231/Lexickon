from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = "Lexickon API"
    app_env: str = "local"
    app_debug: bool = False
    app_secret_key: str = Field(
        default="local-dev-secret-key-change-before-production",
        min_length=32,
    )
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = Field(default=30, gt=0)

    database_url: str = "postgresql+psycopg://lexickon:lexickon@localhost:5432/lexickon"

    storage_endpoint_url: str = "http://localhost:9000"
    storage_bucket: str = "lexickon-datasets"
    storage_access_key_id: str = "minio"
    storage_secret_access_key: str = "minio123"
    storage_region: str = "us-east-1"
    storage_signed_url_expire_seconds: int = Field(default=900, gt=0)


@lru_cache
def get_settings() -> Settings:
    return Settings()
