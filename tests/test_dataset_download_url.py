from datetime import datetime
from uuid import UUID, uuid4

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session, sessionmaker

from app.datasets.models import DatasetVersion
from app.datasets.storage import get_storage_adapter
from app.main import app
from tests.test_dataset_manifest import checksum, create_dataset, dataset_version

EMAIL = "download@example.com"
PASSWORD = "password123"


class FakeStorageAdapter:
    def __init__(self) -> None:
        self.calls: list[tuple[str, int]] = []

    def create_presigned_download_url(self, storage_key: str, expires_in_seconds: int) -> str:
        self.calls.append((storage_key, expires_in_seconds))
        return f"https://storage.test/{storage_key}?expires={expires_in_seconds}"


def register(client: TestClient) -> None:
    response = client.post("/auth/register", json={"email": EMAIL, "password": PASSWORD})
    assert response.status_code == 201


def login_token(client: TestClient) -> str:
    response = client.post("/auth/login", json={"email": EMAIL, "password": PASSWORD})
    assert response.status_code == 200
    return response.json()["access_token"]


def auth_headers(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


def version_with_id(status: str, compressed_size_bytes: int = 100) -> tuple[UUID, DatasetVersion]:
    version_id = uuid4()
    version = dataset_version(
        "1.0.0",
        status,
        checksum("a"),
        compressed_size_bytes=compressed_size_bytes,
    )
    version.id = version_id
    return version_id, version


def test_download_url_returns_signed_url_with_expiration(
    client: TestClient, db_session_factory: sessionmaker[Session]
) -> None:
    fake_storage = FakeStorageAdapter()
    app.dependency_overrides[get_storage_adapter] = lambda: fake_storage

    version_id, version = version_with_id("active", compressed_size_bytes=120)
    create_dataset(
        db_session_factory,
        dataset_key="core-en",
        language="en",
        domain="core",
        title="Core English",
        versions=[version],
    )
    register(client)
    token = login_token(client)

    response = client.post(
        f"/datasets/versions/{version_id}/download-url",
        headers=auth_headers(token),
    )

    assert response.status_code == 200
    body = response.json()
    assert body["url"] == "https://storage.test/datasets/core-en/1.0.0.sqlite.gz?expires=900"
    assert datetime.fromisoformat(body["expires_at"])
    assert body["checksum_sha256"] == checksum("a")
    assert body["compressed_size_bytes"] == 120
    assert body["compression"] == "gzip"
    assert fake_storage.calls == [("datasets/core-en/1.0.0.sqlite.gz", 900)]


def test_download_url_requires_valid_access_token(
    client: TestClient, db_session_factory: sessionmaker[Session]
) -> None:
    version_id, version = version_with_id("active")
    create_dataset(
        db_session_factory,
        dataset_key="core-en",
        language="en",
        domain="core",
        title="Core English",
        versions=[version],
    )

    response = client.post(f"/datasets/versions/{version_id}/download-url")

    assert response.status_code == 401


def test_revoked_version_does_not_issue_download_url(
    client: TestClient, db_session_factory: sessionmaker[Session]
) -> None:
    fake_storage = FakeStorageAdapter()
    app.dependency_overrides[get_storage_adapter] = lambda: fake_storage

    version_id, version = version_with_id("revoked")
    create_dataset(
        db_session_factory,
        dataset_key="core-en",
        language="en",
        domain="core",
        title="Core English",
        versions=[version],
    )
    register(client)
    token = login_token(client)

    response = client.post(
        f"/datasets/versions/{version_id}/download-url",
        headers=auth_headers(token),
    )

    assert response.status_code == 409
    assert response.json() == {"detail": "Dataset version is revoked"}
    assert fake_storage.calls == []


def test_user_without_plan_access_gets_forbidden(
    client: TestClient, db_session_factory: sessionmaker[Session]
) -> None:
    fake_storage = FakeStorageAdapter()
    app.dependency_overrides[get_storage_adapter] = lambda: fake_storage

    version_id, version = version_with_id("active")
    create_dataset(
        db_session_factory,
        dataset_key="medicine-en",
        language="en",
        domain="medicine",
        title="Medicine English",
        required_plan="pro",
        versions=[version],
    )
    register(client)
    token = login_token(client)

    response = client.post(
        f"/datasets/versions/{version_id}/download-url",
        headers=auth_headers(token),
    )

    assert response.status_code == 403
    assert response.json() == {"detail": "User does not have access to this dataset"}
    assert fake_storage.calls == []
