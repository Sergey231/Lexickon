from datetime import UTC, datetime

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session, sessionmaker

from app.datasets.models import Dataset, DatasetVersion


def checksum(seed: str) -> str:
    return seed * 64


def dataset_version(
    version: str,
    status: str,
    checksum_sha256: str,
    sqlite_schema_version: int = 1,
    compressed_size_bytes: int = 100,
) -> DatasetVersion:
    return DatasetVersion(
        version=version,
        sqlite_schema_version=sqlite_schema_version,
        storage_key=f"datasets/core-en/{version}.sqlite.gz",
        file_name=f"core-en-{version}.sqlite.gz",
        file_size_bytes=compressed_size_bytes * 2,
        compressed_size_bytes=compressed_size_bytes,
        checksum_sha256=checksum_sha256,
        compression="gzip",
        status=status,
        release_notes=None,
        published_at=datetime.now(UTC) if status == "active" else None,
    )


def create_dataset(
    db_session_factory: sessionmaker[Session],
    dataset_key: str,
    language: str,
    domain: str,
    title: str,
    required_plan: str = "free",
    versions: list[DatasetVersion] | None = None,
    is_public: bool = True,
) -> Dataset:
    dataset = Dataset(
        dataset_key=dataset_key,
        language=language,
        domain=domain,
        title=title,
        description=f"{title} dataset",
        is_public=is_public,
        required_plan=required_plan,
        versions=versions or [],
    )

    with db_session_factory() as db:
        db.add(dataset)
        db.commit()
        db.refresh(dataset)
        return dataset


def test_manifest_returns_empty_dataset_list(client: TestClient) -> None:
    response = client.get("/datasets/manifest")

    assert response.status_code == 200
    body = response.json()
    assert body["schema_version"] == 1
    assert body["generated_at"]
    assert body["datasets"] == []


def test_manifest_returns_latest_active_versions_for_multiple_datasets(
    client: TestClient, db_session_factory: sessionmaker[Session]
) -> None:
    create_dataset(
        db_session_factory,
        dataset_key="core-en",
        language="en",
        domain="core",
        title="Core English",
        versions=[
            dataset_version("1.0.0", "active", checksum("a"), compressed_size_bytes=100),
            dataset_version("1.1.0", "active", checksum("b"), compressed_size_bytes=120),
        ],
    )
    create_dataset(
        db_session_factory,
        dataset_key="programming-en",
        language="en",
        domain="programming",
        title="Programming English",
        required_plan="pro",
        versions=[
            dataset_version("2.0.0", "active", checksum("c"), sqlite_schema_version=2),
        ],
    )

    response = client.get("/datasets/manifest")

    assert response.status_code == 200
    datasets = response.json()["datasets"]
    assert [dataset["dataset_key"] for dataset in datasets] == ["core-en", "programming-en"]

    core_manifest = datasets[0]
    assert core_manifest["latest_version"] == "1.1.0"
    assert core_manifest["sqlite_schema_version"] == 1
    assert core_manifest["file_size_bytes"] == 240
    assert core_manifest["compressed_size_bytes"] == 120
    assert core_manifest["checksum_sha256"] == checksum("b")
    assert core_manifest["required_plan"] == "free"
    assert core_manifest["status"] == "active"

    programming_manifest = datasets[1]
    assert programming_manifest["latest_version"] == "2.0.0"
    assert programming_manifest["sqlite_schema_version"] == 2
    assert programming_manifest["required_plan"] == "pro"


def test_manifest_uses_numeric_semver_sorting(
    client: TestClient, db_session_factory: sessionmaker[Session]
) -> None:
    create_dataset(
        db_session_factory,
        dataset_key="core-en",
        language="en",
        domain="core",
        title="Core English",
        versions=[
            dataset_version("1.2.0", "active", checksum("a")),
            dataset_version("1.10.0", "active", checksum("b")),
        ],
    )

    response = client.get("/datasets/manifest")

    assert response.status_code == 200
    assert response.json()["datasets"][0]["latest_version"] == "1.10.0"


def test_manifest_excludes_deprecated_revoked_and_private_versions(
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
            dataset_version("9.0.0", "deprecated", checksum("d")),
            dataset_version("10.0.0", "revoked", checksum("e")),
        ],
    )
    create_dataset(
        db_session_factory,
        dataset_key="private-en",
        language="en",
        domain="private",
        title="Private English",
        is_public=False,
        versions=[dataset_version("1.0.0", "active", checksum("f"))],
    )

    response = client.get("/datasets/manifest")

    assert response.status_code == 200
    datasets = response.json()["datasets"]
    assert len(datasets) == 1
    assert datasets[0]["dataset_key"] == "core-en"
    assert datasets[0]["latest_version"] == "1.0.0"
    assert datasets[0]["checksum_sha256"] == checksum("a")


def test_dataset_catalog_endpoints_return_public_datasets(
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
        dataset_key="private-en",
        language="en",
        domain="private",
        title="Private English",
        is_public=False,
        versions=[dataset_version("1.0.0", "active", checksum("b"))],
    )

    list_response = client.get("/datasets")
    assert list_response.status_code == 200
    assert [dataset["dataset_key"] for dataset in list_response.json()] == ["core-en"]

    detail_response = client.get("/datasets/core-en")
    assert detail_response.status_code == 200
    assert detail_response.json()["dataset_key"] == "core-en"
    assert detail_response.json()["versions"][0]["version"] == "1.0.0"

    private_response = client.get("/datasets/private-en")
    assert private_response.status_code == 404
