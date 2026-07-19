from fastapi.testclient import TestClient
from sqlalchemy.orm import Session, sessionmaker

from tests.test_dataset_manifest import checksum, create_dataset, dataset_version


def sync_payload(
    installed: list[dict] | None = None,
    wanted: list[dict] | None = None,
) -> dict:
    return {
        "client_schema_version": 1,
        "installed": installed or [],
        "wanted": wanted or [{"language": "en", "domain": "core"}],
    }


def test_sync_returns_missing_for_client_without_local_dataset(
    client: TestClient, db_session_factory: sessionmaker[Session]
) -> None:
    create_dataset(
        db_session_factory,
        dataset_key="core-en",
        language="en",
        domain="core",
        title="Core English",
        versions=[dataset_version("1.0.0", "active", checksum("a"))],
    )

    response = client.post("/datasets/sync", json=sync_payload())

    assert response.status_code == 200
    assert response.json()["actions"] == [
        {
            "dataset_key": "core-en",
            "status": "missing",
            "installed_version": None,
            "latest_version": "1.0.0",
            "version_id": response.json()["actions"][0]["version_id"],
            "sqlite_schema_version": 1,
            "compressed_size_bytes": 100,
            "checksum_sha256": checksum("a"),
            "required_plan": "free",
        }
    ]


def test_sync_returns_up_to_date_for_current_installed_dataset(
    client: TestClient, db_session_factory: sessionmaker[Session]
) -> None:
    create_dataset(
        db_session_factory,
        dataset_key="core-en",
        language="en",
        domain="core",
        title="Core English",
        versions=[dataset_version("1.0.0", "active", checksum("a"))],
    )

    response = client.post(
        "/datasets/sync",
        json=sync_payload(
            installed=[
                {
                    "dataset_key": "core-en",
                    "version": "1.0.0",
                    "sqlite_schema_version": 1,
                    "checksum_sha256": checksum("a"),
                }
            ]
        ),
    )

    assert response.status_code == 200
    assert response.json()["actions"] == [
        {
            "dataset_key": "core-en",
            "status": "up_to_date",
            "installed_version": "1.0.0",
            "latest_version": "1.0.0",
            "version_id": None,
            "sqlite_schema_version": None,
            "compressed_size_bytes": None,
            "checksum_sha256": None,
            "required_plan": None,
        }
    ]


def test_sync_returns_update_available_for_old_installed_dataset(
    client: TestClient, db_session_factory: sessionmaker[Session]
) -> None:
    create_dataset(
        db_session_factory,
        dataset_key="core-en",
        language="en",
        domain="core",
        title="Core English",
        versions=[
            dataset_version("1.0.0", "active", checksum("a")),
            dataset_version("1.1.0", "active", checksum("b"), compressed_size_bytes=120),
        ],
    )

    response = client.post(
        "/datasets/sync",
        json=sync_payload(
            installed=[
                {
                    "dataset_key": "core-en",
                    "version": "1.0.0",
                    "sqlite_schema_version": 1,
                    "checksum_sha256": checksum("a"),
                }
            ]
        ),
    )

    assert response.status_code == 200
    action = response.json()["actions"][0]
    assert action["dataset_key"] == "core-en"
    assert action["status"] == "update_available"
    assert action["installed_version"] == "1.0.0"
    assert action["latest_version"] == "1.1.0"
    assert action["compressed_size_bytes"] == 120
    assert action["checksum_sha256"] == checksum("b")
    assert action["required_plan"] == "free"


def test_sync_returns_unknown_dataset_for_unknown_wanted_pair(client: TestClient) -> None:
    response = client.post(
        "/datasets/sync",
        json=sync_payload(wanted=[{"language": "en", "domain": "legal"}]),
    )

    assert response.status_code == 200
    assert response.json()["actions"] == [
        {
            "dataset_key": "legal-en",
            "status": "unknown_dataset",
            "installed_version": None,
            "latest_version": None,
            "version_id": None,
            "sqlite_schema_version": None,
            "compressed_size_bytes": None,
            "checksum_sha256": None,
            "required_plan": None,
        }
    ]


def test_sync_uses_wanted_pairs_and_returns_not_allowed_for_paid_dataset(
    client: TestClient, db_session_factory: sessionmaker[Session]
) -> None:
    create_dataset(
        db_session_factory,
        dataset_key="core-en",
        language="en",
        domain="core",
        title="Core English",
        versions=[dataset_version("1.0.0", "active", checksum("a"))],
    )
    create_dataset(
        db_session_factory,
        dataset_key="medicine-en",
        language="en",
        domain="medicine",
        title="Medicine English",
        required_plan="pro",
        versions=[dataset_version("2.0.0", "active", checksum("b"))],
    )

    response = client.post(
        "/datasets/sync",
        json=sync_payload(wanted=[{"language": "en", "domain": "medicine"}]),
    )

    assert response.status_code == 200
    actions = response.json()["actions"]
    assert len(actions) == 1
    assert actions[0]["dataset_key"] == "medicine-en"
    assert actions[0]["status"] == "not_allowed"
    assert actions[0]["latest_version"] == "2.0.0"
    assert actions[0]["required_plan"] == "pro"
