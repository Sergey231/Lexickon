# Lexickon API

This repository contains the Lexickon mobile backend. The backend stores account
data, authentication sessions, user settings, dataset metadata, and signed
download access for ready-made SQLite database packs.

## Current State

- Repository status: FastAPI backend with auth, user settings, dataset registry,
  dataset sync, signed download URLs, environment-based config, SQLAlchemy,
  Alembic, PostgreSQL, MinIO, and automated tests.
- Planned runtime: Python 3.12+, FastAPI, PostgreSQL, SQLAlchemy, Alembic.
- Planned storage: S3-compatible object storage, with MinIO for local development.
- Primary backend role: authentication, profile/settings sync, dataset registry, dataset versioning, access control, and signed download URLs.
- Dataset source: external build or data projects publish ready SQLite packs into this backend.
- Non-goal for MVP: generating datasets or querying dataset contents from the API. The mobile client should use downloaded SQLite packs locally.

## Documentation Map

- [FastAPI server MVP plan](docs/fastapi_server_mvp_plan.md): detailed product, architecture, entity, endpoint, security, testing, and implementation plan.
- [Architecture overview](docs/architecture.md): concise system overview and boundaries.
- [API contract](docs/api_contract.md): compact endpoint and payload reference for the MVP API.
- [Development runbook](docs/development_runbook.md): local setup, environment, migration, smoke-test, and dataset publishing notes.

## Local Setup

Prerequisites:

- Python 3.12+
- Docker Desktop or another Docker Compose runtime

```bash
make install
make dev
```

`make dev` starts PostgreSQL and MinIO, creates the local storage bucket, applies
Alembic migrations, and starts the FastAPI server.

Health check:

```bash
curl http://localhost:8000/health
```

Expected response:

```json
{"status":"ok"}
```

MinIO console:

```text
http://localhost:9001
```

Local credentials:

```text
login: minio
password: minio123
```

## Environment

Local defaults are defined in `.env.example` and mirrored in `app/core/config.py`.
The project also reads an optional `.env` file from the repository root.

```bash
cp .env.example .env
```

Important local values:

```text
DATABASE_URL=postgresql+psycopg://lexickon:lexickon@localhost:5432/lexickon
STORAGE_ENDPOINT_URL=http://localhost:9000
STORAGE_BUCKET=lexickon-datasets
STORAGE_ACCESS_KEY_ID=minio
STORAGE_SECRET_ACCESS_KEY=minio123
```

## Migrations

Run Alembic migrations manually:

```bash
make migrate
```

Create a new migration:

```bash
.venv/bin/alembic revision --autogenerate -m "describe change"
```

## Publish A Dataset Pack

The API does not build datasets. It registers ready `.sqlite.gz` packs.

Create a tiny local smoke-test pack:

```bash
mkdir -p artifacts
python3 - <<'PY'
import gzip
from pathlib import Path

Path("artifacts").mkdir(exist_ok=True)
with gzip.open("artifacts/core-en-v1.0.0.sqlite.gz", "wb") as file:
    file.write(b"local smoke test sqlite payload")
PY
```

Dry run:

```bash
.venv/bin/python scripts/publish_dataset.py \
  --dataset-key core-en \
  --language en \
  --domain core \
  --version 1.0.0 \
  --sqlite-schema-version 1 \
  --file artifacts/core-en-v1.0.0.sqlite.gz \
  --compression gzip \
  --title "Core English" \
  --dry-run
```

Publish:

```bash
.venv/bin/python scripts/publish_dataset.py \
  --dataset-key core-en \
  --language en \
  --domain core \
  --version 1.0.0 \
  --sqlite-schema-version 1 \
  --file artifacts/core-en-v1.0.0.sqlite.gz \
  --compression gzip \
  --title "Core English"
```

The CLI prints JSON with `dataset_key`, `version`, `storage_key`,
`compressed_size_bytes`, and `checksum_sha256`. Published storage objects are
treated as immutable; publishing the same version again is rejected unless
`--force` is passed, and an existing storage object is never overwritten.

## API Smoke Test

Register:

```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@example.com","password":"password123"}'
```

Login and save a token:

```bash
TOKEN=$(curl -s -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@example.com","password":"password123"}' \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')
```

Read manifest:

```bash
curl http://localhost:8000/datasets/manifest
```

Mobile-style sync:

```bash
curl -X POST http://localhost:8000/datasets/sync \
  -H "Content-Type: application/json" \
  -d '{
    "client_schema_version": 1,
    "installed": [],
    "wanted": [
      {
        "language": "en",
        "domain": "core"
      }
    ]
  }'
```

Get the published `version_id` from the manifest and request a signed download
URL:

```bash
VERSION_ID="<version_id_from_manifest>"

curl -X POST "http://localhost:8000/datasets/versions/${VERSION_ID}/download-url" \
  -H "Authorization: Bearer ${TOKEN}"
```

## Planned System Shape

```text
Mobile App
  -> FastAPI API
      -> PostgreSQL
      -> S3-compatible object storage / CDN

External Dataset Producer
  -> builds compressed SQLite packs
  -> uploads packs to object storage
  -> registers dataset versions through backend tooling
```

The backend should return manifests, sync decisions, and signed temporary download URLs. The mobile app downloads, verifies, decompresses, installs, and reads SQLite packs locally.

## MVP Milestones

1. Create FastAPI skeleton, config, database session, Alembic, Docker Compose, and `/health`.
2. Add registration, login, JWT access tokens, and `/me`.
3. Add synced user settings.
4. Add dataset and dataset version models.
5. Add public manifest and authenticated sync endpoints.
6. Add S3-compatible storage adapter and signed download URLs.
7. Add publish CLI for registering SQLite pack releases.
8. Add focused tests for auth, manifest, sync, storage, and publish flows.

## Notes For Implementation

- Keep backend code isolated from dataset-generation projects. The backend receives ready SQLite packs; it does not know how those packs were built.
- Treat published dataset files as immutable.
- Keep PostgreSQL as the source of truth for dataset metadata. Object storage metadata is supplementary.
- Require checksum verification on the client before installing a downloaded dataset pack.
- Keep admin or publish credentials separate from normal mobile user authentication.
