# Lexicon API

This repository contains planning documentation for the Lexicon mobile backend. The backend stores account data, authentication sessions, user settings, dataset metadata, and signed download access for ready-made SQLite database packs.

The first backend skeleton lives in [server](server). The broader source of truth for the MVP remains the plan in [docs/fastapi_server_mvp_plan.md](docs/fastapi_server_mvp_plan.md).

## Current State

- Repository status: FastAPI skeleton with `/health`, environment-based config, SQLAlchemy session setup, Alembic, PostgreSQL Docker Compose, and a healthcheck test.
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

- Keep server code isolated from dataset-generation projects. The server receives ready SQLite packs; it does not know how those packs were built.
- Treat published dataset files as immutable.
- Keep PostgreSQL as the source of truth for dataset metadata. Object storage metadata is supplementary.
- Require checksum verification on the client before installing a downloaded dataset pack.
- Keep admin or publish credentials separate from normal mobile user authentication.
