from fastapi.testclient import TestClient
from sqlalchemy import select
from sqlalchemy.orm import Session, sessionmaker

from app.users.models import User, UserSettings

EMAIL = "settings@example.com"
PASSWORD = "password123"


def register(client: TestClient, email: str = EMAIL, password: str = PASSWORD):
    return client.post("/auth/register", json={"email": email, "password": password})


def login_token(client: TestClient, email: str = EMAIL, password: str = PASSWORD) -> str:
    response = client.post("/auth/login", json={"email": email, "password": password})
    assert response.status_code == 200
    return response.json()["access_token"]


def auth_headers(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


def test_register_creates_default_user_settings(
    client: TestClient, db_session_factory: sessionmaker[Session]
) -> None:
    response = register(client)

    assert response.status_code == 201

    with db_session_factory() as db:
        user = db.scalar(select(User).where(User.email == EMAIL))
        assert user is not None

        settings = db.scalar(select(UserSettings).where(UserSettings.user_id == user.id))
        assert settings is not None
        assert settings.preferred_language == "en"
        assert settings.selected_domains == ["core"]
        assert settings.offline_mode is False
        assert settings.sync_over_cellular is False


def test_get_settings_returns_stable_json_format(client: TestClient) -> None:
    assert register(client).status_code == 201
    token = login_token(client)

    response = client.get("/me/settings", headers=auth_headers(token))

    assert response.status_code == 200
    body = response.json()
    assert list(body) == [
        "id",
        "user_id",
        "preferred_language",
        "selected_domains",
        "offline_mode",
        "sync_over_cellular",
        "created_at",
        "updated_at",
    ]
    assert body["preferred_language"] == "en"
    assert body["selected_domains"] == ["core"]
    assert body["offline_mode"] is False
    assert body["sync_over_cellular"] is False


def test_settings_requires_valid_access_token(client: TestClient) -> None:
    response = client.get("/me/settings")

    assert response.status_code == 401


def test_patch_settings_updates_partially(client: TestClient) -> None:
    assert register(client).status_code == 201
    token = login_token(client)

    response = client.patch(
        "/me/settings",
        headers=auth_headers(token),
        json={"selected_domains": ["Programming", "core", "programming"]},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["preferred_language"] == "en"
    assert body["selected_domains"] == ["programming", "core"]
    assert body["offline_mode"] is False
    assert body["sync_over_cellular"] is False


def test_patch_settings_updates_sync_flags(client: TestClient) -> None:
    assert register(client).status_code == 201
    token = login_token(client)

    response = client.patch(
        "/me/settings",
        headers=auth_headers(token),
        json={"offline_mode": True, "sync_over_cellular": True},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["offline_mode"] is True
    assert body["sync_over_cellular"] is True


def test_patch_settings_rejects_invalid_sync_format(client: TestClient) -> None:
    assert register(client).status_code == 201
    token = login_token(client)

    response = client.patch(
        "/me/settings",
        headers=auth_headers(token),
        json={"sync_over_cellular": "true"},
    )

    assert response.status_code == 422


def test_patch_settings_rejects_invalid_selected_domains(client: TestClient) -> None:
    assert register(client).status_code == 201
    token = login_token(client)

    response = client.patch(
        "/me/settings",
        headers=auth_headers(token),
        json={"selected_domains": ["core", "bad domain"]},
    )

    assert response.status_code == 422
