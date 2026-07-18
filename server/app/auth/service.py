from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.security import hash_password, verify_password
from app.users.models import User
from app.users.service import build_default_user_settings


class EmailAlreadyRegisteredError(Exception):
    pass


def normalize_email(email: str) -> str:
    return email.strip().lower()


def get_user_by_email(db: Session, email: str) -> User | None:
    return db.scalar(select(User).where(User.email == normalize_email(email)))


def register_user(db: Session, email: str, password: str) -> User:
    normalized_email = normalize_email(email)
    if get_user_by_email(db, normalized_email) is not None:
        raise EmailAlreadyRegisteredError

    user = User(email=normalized_email, password_hash=hash_password(password))
    user.settings = build_default_user_settings(user)
    db.add(user)
    try:
        db.commit()
    except IntegrityError as error:
        db.rollback()
        raise EmailAlreadyRegisteredError from error

    db.refresh(user)
    return user


def authenticate_user(db: Session, email: str, password: str) -> User | None:
    user = get_user_by_email(db, email)
    if user is None or not verify_password(password, user.password_hash):
        return None
    if not user.is_active:
        return None

    user.last_login_at = datetime.now(UTC)
    db.commit()
    db.refresh(user)
    return user
