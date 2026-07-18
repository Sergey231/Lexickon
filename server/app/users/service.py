from sqlalchemy.orm import Session

from app.users.models import User, UserSettings
from app.users.schemas import UserSettingsUpdate


def build_default_user_settings(user: User) -> UserSettings:
    return UserSettings(
        user=user,
        preferred_language="en",
        selected_domains=["core"],
        offline_mode=False,
        sync_over_cellular=False,
    )


def get_or_create_user_settings(db: Session, user: User) -> UserSettings:
    if user.settings is not None:
        return user.settings

    settings = build_default_user_settings(user)
    db.add(settings)
    db.commit()
    db.refresh(settings)
    return settings


def update_user_settings(db: Session, user: User, payload: UserSettingsUpdate) -> UserSettings:
    settings = get_or_create_user_settings(db, user)
    update_data = payload.model_dump(exclude_unset=True)

    for field_name, value in update_data.items():
        setattr(settings, field_name, value)

    db.commit()
    db.refresh(settings)
    return settings
