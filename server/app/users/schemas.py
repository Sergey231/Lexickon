import re
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field, StrictBool, field_validator

DOMAIN_KEY_PATTERN = re.compile(r"^[a-z][a-z0-9_-]*$")
LANGUAGE_CODE_PATTERN = re.compile(r"^[a-z]{2}(-[A-Z]{2})?$")


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    email: EmailStr
    is_active: bool
    created_at: datetime
    updated_at: datetime
    last_login_at: datetime | None


class UserSettingsResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    preferred_language: str
    selected_domains: list[str]
    offline_mode: bool
    sync_over_cellular: bool
    created_at: datetime
    updated_at: datetime


class UserSettingsUpdate(BaseModel):
    preferred_language: str | None = Field(default=None, min_length=2, max_length=16)
    selected_domains: list[str] | None = Field(default=None, min_length=1, max_length=50)
    offline_mode: StrictBool | None = None
    sync_over_cellular: StrictBool | None = None

    @field_validator("preferred_language")
    @classmethod
    def validate_preferred_language(cls, value: str | None) -> str | None:
        if value is None:
            return None

        if not LANGUAGE_CODE_PATTERN.fullmatch(value):
            raise ValueError("preferred_language must look like 'en' or 'en-US'")
        return value

    @field_validator("selected_domains")
    @classmethod
    def validate_selected_domains(cls, value: list[str] | None) -> list[str] | None:
        if value is None:
            return None

        normalized_domains: list[str] = []
        seen_domains: set[str] = set()
        for domain in value:
            normalized_domain = domain.strip().lower()
            if not DOMAIN_KEY_PATTERN.fullmatch(normalized_domain):
                raise ValueError(
                    "selected_domains items must use lowercase letters, numbers, '_' or '-'"
                )
            if normalized_domain not in seen_domains:
                normalized_domains.append(normalized_domain)
                seen_domains.add(normalized_domain)

        return normalized_domains
