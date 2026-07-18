from typing import Annotated
from uuid import UUID

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import decode_access_token
from app.users.models import User

bearer_scheme = HTTPBearer(auto_error=False)


def credentials_exception() -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )


def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer_scheme)],
    db: Annotated[Session, Depends(get_db)],
) -> User:
    if credentials is None:
        raise credentials_exception()

    try:
        user_id = UUID(decode_access_token(credentials.credentials))
    except (jwt.InvalidTokenError, ValueError):
        raise credentials_exception() from None

    user = db.get(User, user_id)
    if user is None or not user.is_active:
        raise credentials_exception()
    return user
