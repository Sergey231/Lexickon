# Lexicon API

This repository contains the Lexicon mobile backend. The backend stores account
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
