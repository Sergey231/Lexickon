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

Target workflow:

```bash
make install
make dev
```

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

## Auth Smoke Test

Register:

```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@example.com","password":"password123"}'
```

Login:

```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@example.com","password":"password123"}'
```

Use the returned access token for authenticated endpoints:

```bash
curl http://localhost:8000/me \
  -H "Authorization: Bearer <access_token>"
```

## Publishing A Dataset Pack

Target CLI shape:

```bash
python3 scripts/publish_dataset.py \
  --dataset-key core-en \
  --language en \
  --domain core \
  --version 1.0.0 \
  --sqlite-schema-version 1 \
  --file artifacts/core-en-v1.0.0.sqlite.gz \
  --compression gzip \
  --title "Core English"
```

The CLI should:

1. validate the file path, extension, and compression;
2. calculate file size and SHA-256;
3. prevent accidental overwrite of an existing version;
4. upload the immutable pack to object storage;
5. create or update `Dataset`;
6. create an active `DatasetVersion`;
7. print machine-readable JSON output.

## Dataset Smoke Test

After publishing a pack:

```bash
curl http://localhost:8000/datasets/manifest
```

Sync:

```bash
curl -X POST http://localhost:8000/datasets/sync \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <access_token>" \
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
curl -X POST http://localhost:8000/datasets/versions/<version_id>/download-url \
  -H "Authorization: Bearer <access_token>"
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
