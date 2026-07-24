# Lexicon API Server MVP: план FastAPI backend

## Цель

Сделать MVP backend для мобильного приложения Lexicon.

Этот репозиторий отвечает за обычные backend-задачи мобильного приложения: аккаунты, авторизацию, пользовательские настройки, каталог готовых датасетов и безопасную доставку SQLite-пакетов. Генерация данных живет вне этого проекта. Любой внешний data-проект может подготовить результат в виде SQLite-пакета и зарегистрировать его в Lexicon API.

Сервер не должен строить датасеты сам и не должен быть runtime для чтения содержимого каждого SQLite-пакета. Его роль в MVP:

- авторизация пользователя;
- хранение сессий и токенов авторизации;
- хранение профиля и настроек;
- публикация списка доступных датасетов;
- контроль версий датасетов;
- проверка прав доступа;
- выдача временных ссылок на скачивание SQLite-пакетов;
- регистрация новых dataset releases, подготовленных внешним producer-процессом.

Основная работа с данными должна выполняться локально в мобильном приложении по скачанным SQLite-пакетам.

## Архитектурная идея

Backend является `control plane` для датасетов.

```text
Mobile App
  -> FastAPI Backend
      -> PostgreSQL
      -> Object Storage / CDN

External Dataset Producer
  -> builds SQLite dataset packs
  -> publishes packs to object storage
  -> registers versions in FastAPI backend
```

FastAPI не должен отдавать большие `.sqlite`, `.sqlite.gz` или `.sqlite.zst` файлы напрямую.

Скачивание:

```text
Mobile App
  -> POST /datasets/{version_id}/download-url
  -> receives signed temporary URL
  -> downloads compressed SQLite pack from storage/CDN
```

## Что входит в MVP

### Обязательно

1. FastAPI application skeleton.
2. PostgreSQL schema and migrations.
3. User registration and login.
4. JWT access token.
5. User profile endpoint.
6. User settings endpoint.
7. Dataset registry.
8. Dataset version registry.
9. Public dataset manifest.
10. User-specific sync endpoint.
11. Storage adapter for S3-compatible storage.
12. Signed download URL endpoint.
13. Publish CLI for registering ready SQLite releases.
14. Basic tests for auth, manifest and sync logic.
15. Docker Compose for local development.

### Необязательно для первого MVP

- subscriptions and payments;
- full admin panel;
- background worker;
- Redis;
- server-side querying of dataset contents;
- real-time notifications;
- A/B experiments;
- analytics pipeline;
- multi-region storage;
- complex organization/team accounts.

## Рекомендуемый стек

```text
Python 3.12+
FastAPI
Uvicorn
Pydantic Settings
SQLAlchemy 2.x
Alembic
PostgreSQL
Passlib / pwdlib for password hashing
python-jose or PyJWT for JWT
boto3 or aioboto3 for S3-compatible storage
pytest
httpx
ruff
mypy optional
```

Для локального object storage:

```text
MinIO
```

Для production:

```text
Cloudflare R2, AWS S3, Backblaze B2 or another S3-compatible provider
```

## Предлагаемая структура проекта

```text
backend/
  app/
    __init__.py
    main.py

    core/
      __init__.py
      config.py
      database.py
      security.py
      errors.py
      pagination.py

    auth/
      __init__.py
      models.py
      schemas.py
      router.py
      service.py
      dependencies.py

    users/
      __init__.py
      models.py
      schemas.py
      router.py
      service.py

    datasets/
      __init__.py
      models.py
      schemas.py
      router.py
      service.py
      manifest.py
      storage.py
      permissions.py

  migrations/
    env.py
    versions/

  scripts/
    publish_dataset.py
    seed_dev_data.py

  tests/
    conftest.py
    test_auth.py
    test_dataset_manifest.py
    test_dataset_sync.py
    test_download_url.py

  pyproject.toml
  docker-compose.yml
  alembic.ini
  README.md
```

В этом репозитории backend является основным приложением, поэтому структура живет в корне
репозитория.

Главное правило: код сервера не должен напрямую зависеть от runtime-файлов проектов, которые генерируют SQLite-пакеты. Сервер получает готовый артефакт и его метаданные.

## Доменные сущности

### User

Пользователь приложения.

```text
id
email
password_hash
is_active
created_at
updated_at
last_login_at
```

### UserSettings

Настройки, которые нужно синхронизировать между устройствами.

```text
id
user_id
preferred_language
selected_domains
offline_mode
sync_over_cellular
created_at
updated_at
```

Пример `selected_domains`:

```json
["core", "programming", "medicine"]
```

`sync_over_cellular` управляет тем, может ли клиент скачивать SQLite-пакеты через мобильную сеть.

### Dataset

Логическая сущность датасета.

```text
id
dataset_key
language
domain
title
description
is_public
required_plan
created_at
updated_at
```

Примеры:

```text
core-en
programming-en
medicine-en
legal-en
```

### DatasetVersion

Конкретная опубликованная версия датасета.

```text
id
dataset_id
version
sqlite_schema_version
storage_key
file_name
file_size_bytes
compressed_size_bytes
checksum_sha256
compression
status
release_notes
created_at
published_at
```

Статусы:

```text
draft
active
deprecated
revoked
```

### Optional: UserDatasetInstall

На MVP эту таблицу можно не делать, если клиент сам сообщает локальные версии.

Она нужна позже для аналитики и поддержки:

```text
id
user_id
dataset_version_id
device_id
installed_at
last_seen_at
```

## Правила идентификаторов

```text
dataset_key = "{domain}-{language}"
version = SemVer, for example "1.0.0"
sqlite_schema_version = integer
checksum_sha256 = required
```

Версия данных и версия SQLite-схемы являются разными полями.

Пример:

```json
{
  "dataset_key": "core-en",
  "version": "1.0.0",
  "sqlite_schema_version": 1
}
```

## API endpoints

### Health

```http
GET /health
```

Ответ:

```json
{
  "status": "ok"
}
```

### Auth

```http
POST /auth/register
POST /auth/login
```

Refresh/logout можно добавить позже, когда появится отдельная модель refresh token lifecycle.

### Me

```http
GET /me
GET /me/settings
PATCH /me/settings
```

Пример `PATCH /me/settings`:

```json
{
  "preferred_language": "en",
  "selected_domains": ["core", "programming"],
  "offline_mode": true,
  "sync_over_cellular": false
}
```

### Dataset catalog

```http
GET /datasets
GET /datasets/{dataset_key}
```

### Manifest

```http
GET /datasets/manifest
```

Manifest должен быть удобен для мобильного клиента. Клиент сравнивает этот ответ со своими локальными версиями.

Пример:

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

### Dataset sync

```http
POST /datasets/sync
```

Запрос:

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
    },
    {
      "language": "en",
      "domain": "programming"
    }
  ]
}
```

Ответ:

```json
{
  "schema_version": 1,
  "actions": [
    {
      "dataset_key": "core-en",
      "status": "up_to_date",
      "installed_version": "1.0.0",
      "latest_version": "1.0.0"
    },
    {
      "dataset_key": "programming-en",
      "status": "missing",
      "latest_version": "1.0.0",
      "version_id": "01J...",
      "compressed_size_bytes": 22000000,
      "checksum_sha256": "64-char-hex"
    }
  ]
}
```

Возможные `status`:

```text
up_to_date
missing
update_available
not_allowed
deprecated
revoked
unknown_dataset
```

### Download URL

```http
POST /datasets/versions/{version_id}/download-url
```

Ответ:

```json
{
  "url": "https://storage.example.com/...",
  "expires_at": "2026-07-11T10:15:00Z",
  "checksum_sha256": "64-char-hex",
  "compressed_size_bytes": 18400000,
  "compression": "gzip"
}
```

Правила:

- endpoint требует авторизацию;
- сервер проверяет право пользователя на `required_plan`;
- signed URL должен жить ограниченное время;
- клиент обязан проверить `checksum_sha256` после скачивания;
- клиент не должен устанавливать пакет, если checksum не совпал.

## Storage contract

Рекомендуемая структура object storage:

```text
lexicon-datasets/
  core/en/1.0.0/core-en-v1.0.0.sqlite.gz
  programming/en/1.0.0/programming-en-v1.0.0.sqlite.gz
```

`storage_key` в базе:

```text
core/en/1.0.0/core-en-v1.0.0.sqlite.gz
```

Metadata в storage object:

```text
dataset_key
version
sqlite_schema_version
checksum_sha256
compression
```

Но source of truth для приложения остается PostgreSQL, не object metadata.

## Publish CLI

Команда:

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

Что делает CLI:

1. Проверяет существование файла.
2. Проверяет расширение и compression.
3. Считает размер файла.
4. Считает SHA-256.
5. Проверяет, что такая версия еще не опубликована.
6. Загружает файл в object storage.
7. Создает или обновляет `Dataset`.
8. Создает `DatasetVersion` со статусом `active`.
9. Деактивирует предыдущую active-версию, если нужно.
10. Печатает machine-readable summary.

Пример output:

```json
{
  "dataset_key": "core-en",
  "version": "1.0.0",
  "status": "active",
  "storage_key": "core/en/1.0.0/core-en-v1.0.0.sqlite.gz",
  "compressed_size_bytes": 18400000,
  "checksum_sha256": "64-char-hex"
}
```

## Этапы реализации

### Этап 1. Backend skeleton

Задачи:

- создать структуру backend-приложения в корне репозитория;
- настроить `pyproject.toml`;
- добавить FastAPI app;
- добавить `/health`;
- добавить config через environment variables;
- добавить Docker Compose с PostgreSQL;
- подключить SQLAlchemy session;
- подключить Alembic.

Acceptance criteria:

- `uvicorn app.main:app --reload` запускается локально;
- `GET /health` возвращает `{"status": "ok"}`;
- Alembic создает пустую миграцию;
- тест healthcheck проходит.

### Этап 2. Auth

Задачи:

- создать таблицу `users`;
- реализовать password hashing;
- реализовать `POST /auth/register`;
- реализовать `POST /auth/login`;
- реализовать JWT access token;
- добавить dependency `get_current_user`;
- реализовать `GET /me`.

Acceptance criteria:

- пользователь может зарегистрироваться;
- нельзя зарегистрировать один email дважды;
- login возвращает access token;
- `/me` работает только с валидным token;
- тесты покрывают успешный и ошибочный login.

### Этап 3. User settings

Задачи:

- создать таблицу `user_settings`;
- создать default settings при регистрации;
- реализовать `GET /me/settings`;
- реализовать `PATCH /me/settings`;
- валидировать формат настроек синхронизации;
- валидировать формат `selected_domains`.

Acceptance criteria:

- новый пользователь получает default settings;
- настройки можно обновить частично;
- неверный формат настроек синхронизации отклоняется;
- settings возвращаются в стабильном JSON-формате.

### Этап 4. Dataset registry

Задачи:

- создать таблицу `datasets`;
- создать таблицу `dataset_versions`;
- добавить уникальный индекс на `dataset_key`;
- добавить уникальный индекс на `(dataset_id, version)`;
- реализовать `GET /datasets`;
- реализовать `GET /datasets/{dataset_key}`;
- реализовать `GET /datasets/manifest`.

Acceptance criteria:

- manifest возвращает только active versions;
- manifest содержит checksum, размер, schema version и required plan;
- deprecated/revoked версии не попадают как latest;
- тесты покрывают пустой manifest и manifest с несколькими датасетами.

### Этап 5. Dataset sync

Задачи:

- реализовать `POST /datasets/sync`;
- сравнивать installed versions клиента с latest active versions;
- учитывать wanted language/domain pairs;
- возвращать `missing`, `up_to_date`, `update_available`;
- заложить `not_allowed`, даже если paid plans пока не реализованы.

Acceptance criteria:

- клиент без локальных датасетов получает `missing`;
- клиент с актуальной версией получает `up_to_date`;
- клиент со старой версией получает `update_available`;
- неизвестный dataset возвращает `unknown_dataset`.

### Этап 6. Storage adapter

Задачи:

- реализовать интерфейс storage adapter;
- добавить S3-compatible implementation;
- добавить MinIO config для локального запуска;
- реализовать signed URL generation;
- добавить `POST /datasets/versions/{version_id}/download-url`;
- проверить права пользователя перед выдачей URL.

Acceptance criteria:

- endpoint возвращает signed URL;
- URL имеет expiration;
- revoked version не выдает URL;
- пользователь без доступа получает 403;
- тесты используют fake storage adapter.

### Этап 7. Publish CLI

Задачи:

- реализовать `scripts/publish_dataset.py`;
- считать SHA-256 файла;
- определять размер файла;
- загружать файл в storage;
- регистрировать `Dataset` и `DatasetVersion`;
- предотвращать перезапись уже опубликованной версии;
- добавить dry-run режим.

Acceptance criteria:

- CLI может опубликовать локальный `.sqlite.gz`;
- повторная публикация той же версии без force отклоняется;
- manifest начинает показывать опубликованный dataset;
- SHA-256 в manifest совпадает с файлом.

### Этап 8. Operational safeguards

Задачи:

- добавить dry-run режим для publish CLI;
- добавить машинно-читаемый output для publish CLI;
- добавить проверку, что published file immutable;
- добавить понятные ошибки для revoked/deprecated dataset versions;
- добавить audit-friendly logging для публикации и выдачи signed URL.

Acceptance criteria:

- повторная публикация существующей версии без explicit force отклоняется;
- revoked version не попадает в manifest и не выдает signed URL;
- publish CLI печатает JSON summary;
- в логах можно увидеть, кто запросил signed URL и для какой версии.

### Этап 9. Documentation and local runbook

Задачи:

- описать local setup;
- описать environment variables;
- описать миграции;
- описать публикацию dataset pack;
- описать мобильный sync flow;
- добавить примеры curl.

Acceptance criteria:

- новый разработчик может поднять backend по README;
- можно создать пользователя, опубликовать dataset и получить manifest;
- можно получить signed URL на опубликованный dataset.

## Environment variables

Минимальный набор:

```text
APP_ENV=local
APP_DEBUG=true
APP_SECRET_KEY=change-me

DATABASE_URL=postgresql+psycopg://lexicon:lexicon@localhost:5432/lexicon

JWT_ACCESS_TOKEN_EXPIRE_MINUTES=60

STORAGE_PROVIDER=s3
STORAGE_BUCKET=lexicon-datasets
STORAGE_ENDPOINT_URL=http://localhost:9000
STORAGE_REGION=us-east-1
STORAGE_ACCESS_KEY_ID=minio
STORAGE_SECRET_ACCESS_KEY=minio-password
STORAGE_SIGNED_URL_TTL_SECONDS=900

```

## Security decisions for MVP

1. Passwords are never stored in plaintext.
2. JWT secret comes only from environment.
3. Dataset download always requires auth.
4. Signed URLs expire quickly.
5. Dataset files are immutable after publishing.
6. Client verifies checksum before installing.
7. Revoked versions are not returned in manifest or download URL.
8. Admin/publish CLI credentials are separate from mobile user auth.

## Testing plan

### Unit tests

- password hashing;
- JWT creation and parsing;
- manifest generation;
- sync status calculation;
- storage key generation;
- checksum calculation.

### API tests

- register;
- login;
- `/me`;
- settings patch;
- datasets manifest;
- datasets sync;
- download URL success;
- download URL forbidden.

### Integration tests

- PostgreSQL migration applies cleanly;
- publish CLI creates dataset version;
- manifest reflects published version;
- fake storage receives uploaded file.

### Manual smoke test

```bash
docker compose up -d
alembic upgrade head
uvicorn app.main:app --reload

curl http://localhost:8000/health

curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@example.com","password":"password123"}'

curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@example.com","password":"password123"}'
```

## Mobile sync flow

Первый запуск:

```text
1. User logs in.
2. App requests /datasets/manifest.
3. App chooses default packs: core-en.
4. App calls /datasets/sync with empty installed list.
5. Server returns missing core-en.
6. App requests download URL.
7. App downloads .sqlite.gz from storage.
8. App verifies checksum.
9. App decompresses and installs SQLite.
10. App reads data from the installed SQLite pack locally.
```

Повторный запуск:

```text
1. App reads local installed dataset metadata.
2. App calls /datasets/sync.
3. Server returns up_to_date or update_available.
4. App downloads only changed packs.
```

## Decisions to postpone

Эти решения не нужно блокировать на первом backend MVP:

- exact subscription provider;
- exact paid plan matrix;
- advanced admin UI;
- data analytics;
- multi-device installed dataset tracking;
- push notifications for new dataset versions;
- differential updates instead of full dataset downloads;
- server-side search across all corpora.

## Рекомендуемый порядок работ

1. Skeleton, config, database, migrations.
2. Auth and `/me`.
3. User settings.
4. Dataset and dataset version models.
5. Manifest endpoint.
6. Sync endpoint.
7. Storage adapter and signed URLs.
8. Publish CLI.
9. Operational safeguards.
10. Local README and smoke test.

## Definition of Done for MVP server

MVP server можно считать готовым, когда выполняется полный сценарий:

```text
1. Разработчик поднимает FastAPI + PostgreSQL + MinIO локально.
2. CLI публикует core-en v1.0.0 SQLite pack.
3. Пользователь регистрируется через API.
4. Пользователь логинится и получает token.
5. Мобильный клиент получает manifest.
6. Мобильный клиент отправляет sync request.
7. Сервер сообщает, что core-en нужно скачать.
8. Мобильный клиент получает signed URL.
9. Мобильный клиент скачивает файл из storage.
10. Checksum файла совпадает с manifest.
```

После этого backend выполняет свою главную MVP-роль: управляет доставкой локальных датасетов для mobile local-first приложения.
