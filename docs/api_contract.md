# MVP API Contract

This is the compact contract for the planned FastAPI service. See [fastapi_server_mvp_plan.md](fastapi_server_mvp_plan.md) for full implementation notes and examples.

## Health

```http
GET /health
```

Response:

```json
{
  "status": "ok"
}
```

## Auth

```http
POST /auth/register
POST /auth/login
```

`register` returns the created user. `login` returns a bearer access token.

## Current User

```http
GET /me
GET /me/settings
PATCH /me/settings
```

Settings patch example:

```json
{
  "preferred_language": "en",
  "selected_domains": ["core", "programming"],
  "offline_mode": true,
  "sync_over_cellular": false
}
```

`sync_over_cellular` controls whether the mobile app may download SQLite packs over a cellular connection.

## Dataset Catalog

```http
GET /datasets
GET /datasets/{dataset_key}
```

`dataset_key` should follow `{domain}-{language}`, for example `core-en`.

## Manifest

```http
GET /datasets/manifest
```

The manifest is optimized for mobile clients comparing remote dataset state with local installed packs.

Response shape:

```json
{
  "schema_version": 1,
  "generated_at": "2026-07-11T10:00:00Z",
  "datasets": [
    {
      "dataset_key": "core-en",
      "language": "en",
      "domain": "core",
      "title": "Core English",
      "latest_version": "1.0.0",
      "version_id": "01J...",
      "sqlite_schema_version": 1,
      "compression": "gzip",
      "compressed_size_bytes": 18400000,
      "checksum_sha256": "64-char-hex",
      "required_plan": "free",
      "status": "active"
    }
  ]
}
```

Manifest rules:

- include latest active versions;
- exclude draft, revoked, and deprecated versions as latest install targets;
- include checksum and compressed size;
- include access tier metadata, even before paid plans exist.

## Dataset Sync

```http
POST /datasets/sync
```

Request:

```json
{
  "client_schema_version": 1,
  "installed": [
    {
      "dataset_key": "core-en",
      "version": "1.0.0",
      "sqlite_schema_version": 1,
      "checksum_sha256": "64-char-hex"
    }
  ],
  "wanted": [
    {
      "language": "en",
      "domain": "core"
    }
  ]
}
```

Response:

```json
{
  "schema_version": 1,
  "actions": [
    {
      "dataset_key": "core-en",
      "status": "up_to_date",
      "installed_version": "1.0.0",
      "latest_version": "1.0.0"
    }
  ]
}
```

Allowed action statuses:

```text
up_to_date
missing
update_available
not_allowed
deprecated
revoked
unknown_dataset
```

## Download URL

```http
POST /datasets/versions/{version_id}/download-url
```

Response:

```json
{
  "url": "https://storage.example.com/...",
  "expires_at": "2026-07-11T10:15:00Z",
  "checksum_sha256": "64-char-hex",
  "compressed_size_bytes": 18400000,
  "compression": "gzip"
}
```

Rules:

- endpoint requires authentication;
- API checks the user's access to the dataset version;
- signed URL has a short TTL;
- revoked and deprecated versions return explicit errors;
- client verifies checksum after download.

## Dataset Content

The API does not expose dataset-content query endpoints in the MVP. Dataset content is delivered as immutable SQLite packs. Mobile clients download, verify, install, and read those packs locally.
