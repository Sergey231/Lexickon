from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = "Lexicon API"
    app_env: str = "local"
    app_debug: bool = False
    app_secret_key: str = Field(
        default="local-dev-secret-key-change-before-production",
        min_length=32,
    )
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = Field(default=30, gt=0)

    database_url: str = "postgresql+psycopg://lexicon:lexicon@localhost:5432/lexicon"


@lru_cache
def get_settings() -> Settings:
    return Settings()
