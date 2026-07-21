from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.auth.dependencies import get_current_user
from app.core.database import get_db
from app.users.models import User, UserSettings
from app.users.schemas import UserResponse, UserSettingsResponse, UserSettingsUpdate
from app.users.service import get_or_create_user_settings, update_user_settings

router = APIRouter(tags=["users"])


@router.get("/me", response_model=UserResponse)
def read_current_user(current_user: Annotated[User, Depends(get_current_user)]) -> User:
    return current_user


@router.get("/me/settings", response_model=UserSettingsResponse)
def read_current_user_settings(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
) -> UserSettings:
    return get_or_create_user_settings(db, current_user)


@router.patch("/me/settings", response_model=UserSettingsResponse)
def patch_current_user_settings(
    payload: UserSettingsUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
) -> UserSettings:
    return update_user_settings(db, current_user, payload)
