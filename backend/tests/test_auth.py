import pytest
from fastapi.testclient import TestClient
from sqlalchemy import select
from sqlalchemy.orm import Session, sessionmaker

from app.core.security import verify_password
from app.users.models import User

EMAIL = "dev@example.com"
PASSWORD = "password123"


def register(client: TestClient, email: str = EMAIL, password: str = PASSWORD):
    return client.post("/auth/register", json={"email": email, "password": password})


def test_register_hashes_password(
    client: TestClient, db_session_factory: sessionmaker[Session]
) -> None:
    response = register(client, email="Dev@Example.com")

    assert response.status_code == 201
    assert response.json()["email"] == EMAIL
    assert "password" not in response.json()

    with db_session_factory() as db:
        user = db.scalar(select(User).where(User.email == EMAIL))
        assert user is not None
        assert user.password_hash != PASSWORD
        assert verify_password(PASSWORD, user.password_hash)


def test_cannot_register_duplicate_email(client: TestClient) -> None:
    assert register(client).status_code == 201

    response = register(client, email="DEV@example.com")

    assert response.status_code == 409
    assert response.json() == {"detail": "Email is already registered"}


def test_login_returns_access_token_and_token_opens_me(client: TestClient) -> None:
    assert register(client).status_code == 201

    login_response = client.post("/auth/login", json={"email": EMAIL, "password": PASSWORD})

    assert login_response.status_code == 200
    token_body = login_response.json()
    assert token_body["token_type"] == "bearer"
    assert token_body["access_token"]

    me_response = client.get(
        "/me", headers={"Authorization": f"Bearer {token_body['access_token']}"}
    )
    assert me_response.status_code == 200
    assert me_response.json()["email"] == EMAIL
    assert me_response.json()["last_login_at"] is not None


@pytest.mark.parametrize(
    ("email", "password"),
    [(EMAIL, "wrong-password"), ("unknown@example.com", PASSWORD)],
)
def test_login_rejects_invalid_credentials(client: TestClient, email: str, password: str) -> None:
    assert register(client).status_code == 201

    response = client.post("/auth/login", json={"email": email, "password": password})

    assert response.status_code == 401
    assert response.json() == {"detail": "Incorrect email or password"}


@pytest.mark.parametrize(
    "headers",
    [{}, {"Authorization": "Bearer invalid-token"}],
)
def test_me_requires_valid_access_token(client: TestClient, headers: dict[str, str]) -> None:
    response = client.get("/me", headers=headers)

    assert response.status_code == 401
    assert response.headers["www-authenticate"] == "Bearer"
