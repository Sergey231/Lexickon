# Architecture Overview

## Purpose

The API is the Lexicon mobile backend and a control plane for local-first dataset delivery. It manages users, sessions, settings, dataset metadata, dataset versions, authorization, and signed download URLs. External data projects produce ready SQLite packs; this backend stores metadata and safely delivers those packs to mobile clients.

## Responsibilities

The backend owns:

- user registration, login, and access tokens;
- user profile and settings sync;
- dataset catalog and version metadata;
- public manifest generation;
- per-user dataset sync decisions;
- access checks for restricted datasets;
- short-lived signed download URLs;
- dataset release registration from external build or publish tooling.

The backend should not own:

- dataset generation or transformation;
- query traffic for dataset contents during normal app usage;
- direct streaming of large SQLite artifacts;
- mobile-side checksum verification or installation;
- external dataset producer internals.

## Main Components

```text
FastAPI Application
  app/core
    config, database, security, errors
  app/auth
    registration, login, token dependencies
  app/users
    profile and settings
  app/datasets
    catalog, manifest, sync, permissions, storage
PostgreSQL
  users
  user_settings
  datasets
  dataset_versions

Object Storage
  compressed SQLite packs
  immutable objects addressed by storage_key

Publish CLI
  validates a dataset pack
  calculates checksum and size
  uploads to storage
  registers Dataset and DatasetVersion rows
```

## Data Delivery Flow

First install:

```text
1. User logs in.
2. Mobile app requests /datasets/manifest.
3. Mobile app selects desired packs.
4. Mobile app posts installed and wanted packs to /datasets/sync.
5. API returns missing or update_available actions.
6. Mobile app asks for a signed URL for each needed version.
7. Mobile app downloads from object storage or CDN.
8. Mobile app verifies SHA-256.
9. Mobile app decompresses and installs SQLite locally.
10. Lookups run locally.
```

Subsequent sync:

```text
1. Mobile app reads local installed dataset metadata.
2. Mobile app posts current metadata to /datasets/sync.
3. API returns up_to_date, update_available, missing, not_allowed, revoked, or unknown_dataset.
4. Mobile app downloads only changed packs.
```

## Dataset Versioning

Dataset data version and SQLite schema version are separate values:

```json
{
  "dataset_key": "core-en",
  "version": "1.0.0",
  "sqlite_schema_version": 1
}
```

Rules:

- `dataset_key` format: `{domain}-{language}`.
- `version` format: SemVer.
- `sqlite_schema_version`: integer.
- `checksum_sha256`: required for every published pack.
- active versions appear in manifests and sync results.
- revoked versions must not receive signed download URLs.

## Storage Contract

Recommended bucket layout:

```text
lexicon-datasets/
  core/en/1.0.0/core-en-v1.0.0.sqlite.gz
  programming/en/1.0.0/programming-en-v1.0.0.sqlite.gz
```

Recommended database `storage_key`:

```text
core/en/1.0.0/core-en-v1.0.0.sqlite.gz
```

The database remains the source of truth for status, access rules, checksums, and current versions.

## Security Invariants

- Passwords are hashed, never stored as plaintext.
- JWT secret is provided only through environment configuration.
- Dataset download URL generation requires authentication.
- Access is checked before generating a signed URL.
- Signed URLs expire quickly.
- Published dataset files are immutable.
- Clients verify checksums before installing downloaded packs.
- Revoked dataset versions are excluded from manifests and download URLs.
