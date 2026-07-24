# Development Runbook

This runbook describes the local workflow for the FastAPI backend in this
repository.

## Expected Local Stack

- Python 3.12+
- FastAPI
- Uvicorn
- SQLAlchemy 2.x
- Alembic
- PostgreSQL
- MinIO for S3-compatible local object storage
- pytest and httpx for tests
- ruff for linting

## Project Layout

```text
app/
  main.py
  core/
  auth/
  users/
  datasets/
migrations/
scripts/
  publish_dataset.py
  seed_dev_data.py
tests/
pyproject.toml
docker-compose.yml
alembic.ini
```

This repository is the backend application. Keep API modules independent from
dataset-generation runtime modules.

## Environment Variables

Minimum local configuration:

```text
APP_ENV=local
APP_DEBUG=true
APP_SECRET_KEY=change-me

DATABASE_URL=postgresql+psycopg://lexicon:lexicon@localhost:5432/lexicon

JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

STORAGE_ENDPOINT_URL=http://localhost:9000
STORAGE_BUCKET=lexicon-datasets
STORAGE_ACCESS_KEY_ID=minio
STORAGE_SECRET_ACCESS_KEY=minio123
STORAGE_REGION=us-east-1
STORAGE_SIGNED_URL_EXPIRE_SECONDS=900
```

## Local Startup

Install dependencies:

```bash
make install
```

Start the full local stack and API:

```bash
make dev
```

`make dev` performs these steps:

1. starts PostgreSQL;
2. starts MinIO;
3. creates the local MinIO bucket;
4. applies Alembic migrations;
5. starts `uvicorn app.main:app --reload`.

Health check:

```bash
curl http://localhost:8000/health
```

Expected response:

```json
{
  "status": "ok"
}
```

To start only infrastructure without the API:

```bash
make infra-up
make db-ready
make storage-ready
```

To stop the containers:

```bash
make db-down
```

`make db-down` stops the Docker Compose stack. Named Docker volumes keep local
PostgreSQL and MinIO data until you explicitly remove them with Docker.

## Migrations

Apply migrations:

```bash
make migrate
```

Create a new migration after model changes:

```bash
.venv/bin/alembic revision --autogenerate -m "describe change"
```

Inspect migration status:

```bash
.venv/bin/alembic current
.venv/bin/alembic history
```

## Auth Smoke Test

Register:

```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@example.com","password":"password123"}'
```

Login:

```bash
TOKEN=$(curl -s -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@example.com","password":"password123"}' \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["access_token"])')
```

Use the access token for authenticated endpoints:

```bash
curl http://localhost:8000/me \
  -H "Authorization: Bearer ${TOKEN}"
```

## Publishing A Dataset Pack

The backend does not generate dataset content. A producer process gives this
project a ready `.sqlite.gz` file, and the publish CLI uploads it to MinIO/S3
and registers metadata in PostgreSQL.

For local smoke testing, create a tiny gzip file:

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

Run a dry run first. This validates the file and prints the same JSON summary,
but does not upload to storage or commit to the database:

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

The CLI:

1. validates the file path, extension, and compression;
2. calculates file size and SHA-256;
3. prevents accidental overwrite of an existing version;
4. uploads the immutable pack to object storage;
5. creates or updates `Dataset`;
6. creates an active `DatasetVersion`;
7. prints machine-readable JSON output.

Important rules:

- only `.sqlite.gz` is supported now;
- `dataset-key` must match `{domain}-{language}`, for example `core-en`;
- `version` must be SemVer, for example `1.0.0`;
- a repeated publish of the same version is rejected without `--force`;
- an existing storage object is rejected to keep published files immutable.

## Dataset Smoke Test

After publishing a pack:

```bash
curl http://localhost:8000/datasets/manifest
```

The response should include `core-en`. Save the returned `version_id` for the
download URL request.

Sync:

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

Download URL:

```bash
VERSION_ID="<version_id_from_manifest>"

curl -X POST "http://localhost:8000/datasets/versions/${VERSION_ID}/download-url" \
  -H "Authorization: Bearer ${TOKEN}"
```

The response includes a temporary signed URL:

```json
{
  "url": "http://localhost:9000/lexicon-datasets/...",
  "expires_at": "2026-07-22T10:15:00Z",
  "checksum_sha256": "64-char-hex",
  "compressed_size_bytes": 123,
  "compression": "gzip"
}
```

The mobile client must verify the downloaded file against `checksum_sha256`
before installing it.

## Mobile Sync Flow

First install:

```text
1. User logs in.
2. App requests GET /datasets/manifest.
3. App chooses wanted language/domain pairs.
4. App calls POST /datasets/sync with an empty installed list.
5. API returns missing or not_allowed actions.
6. App requests POST /datasets/versions/{version_id}/download-url.
7. App downloads the .sqlite.gz pack from the signed URL.
8. App verifies checksum_sha256.
9. App decompresses and installs SQLite locally.
```

Next launches:

```text
1. App reads local installed dataset metadata.
2. App calls POST /datasets/sync.
3. API returns up_to_date, update_available, missing, not_allowed, or unknown_dataset.
4. App downloads only changed or missing packs.
```

## Test Expectations

Minimum automated coverage:

- health check;
- registration and login;
- duplicate email rejection;
- JWT-protected `/me`;
- default settings creation;
- partial settings update;
- empty and populated manifest;
- sync statuses for missing, up-to-date, update available, and unknown dataset;
- signed URL success and forbidden cases;
- publish CLI checksum and duplicate-version behavior.

## Definition Of Done

The backend MVP is ready when this flow works locally:

```text
1. FastAPI, PostgreSQL, and MinIO start locally.
2. Migrations apply cleanly.
3. Publish CLI registers core-en v1.0.0.
4. User registers and logs in.
5. Mobile-style client reads manifest.
6. Mobile-style client posts sync state.
7. API returns a missing dataset action.
8. API returns a signed URL for the needed version.
9. Client downloads the pack from storage.
10. Downloaded file checksum matches the manifest.
```
