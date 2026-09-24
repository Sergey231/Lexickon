# Этап 7. Безопасная установка датасета — Декомпозиция на Stories

Источник: `apps/ios/docs/ios_mvp_implementation_stages.md` (строки 317-368)

---

## Epic: Safe Dataset Installation

**Goal**: Реализовать устойчивую установку SQLite-пака без риска заменить рабочую версию повреждённым или несовместимым файлом.

---

## Story 7.1: Download to Temporary Location with Progress & Cancellation

**As a** система установки  
**I want** скачивать пак во временную директорию с прогрессом и поддержкой отмены  
**So that** пользователь видит прогресс и может прервать загрузку

### Acceptance Criteria
- [ ] Загрузка происходит в `FileManager.temporaryDirectory` с уникальным именем
- [ ] Прогресс отдаётся через `AsyncStream<Double>` (0.0–1.0)
- [ ] `Task.checkCancellation()` вызывается в цикле чтения байтов
- [ ] При отмене временный файл удаляется
- [ ] `URLSession` использует `byteRange` для resumable загрузки (опционально, если решат в открытом вопросе #6)

### Technical Notes
- `DatasetDownloader` actor
- Вход: `URL` (signed download URL), `ExpectedSize` (из manifest)
- Выход: `URL` временного файла или `DownloadError`

---

## Story 7.2: Cellular Download Policy (`sync_over_cellular`)

**As a** пользователь  
**I want** чтобы автоматическая загрузка не начиналась в сотовой сети, если выключен `sync_over_cellular`  
**So that** не тратить мобильный трафик неожиданно

### Acceptance Criteria
- [ ] Проверка `NWPathMonitor` перед стартом авто-загрузки
- [ ] Если `expensive == true` и `sync_over_cellular == false` → ошибка `DownloadError.cellularNotAllowed`
- [ ] Ручной запуск пользователем игнорирует политику (разрешено всегда)
- [ ] Настройка читается из `UserSettings` (Domain)

### Technical Notes
- Политика применяется в `DatasetInstaller.install()` перед вызовом downloader
- Unit-тест: mock `NWPathMonitor` с `.expensive` / `.notExpensive`

---

## Story 7.3: SHA-256 Verification Before Unpack

**As a** система установки  
**I want** верифицировать SHA-256 скачанного файла до распаковки  
**So that** не тратить ресурсы на повреждённые/поддельные паки

### Acceptance Criteria
- [ ] Checksum вычисляется стримингово (не загружая весь файл в память)
- [ ] Сравнение с `expectedChecksum` из manifest (case-insensitive hex)
- [ ] При mismatch: удалить временный файл, вернуть `InstallError.checksumMismatch`
- [ ] Лог: только факт mismatch, без signed URL

### Technical Notes
- `ChecksumValidator` actor с методом `verify(fileAt: URL, expected: String) async throws`
- Использовать `CryptoKit.SHA256` + `FileHandle` для чанков

---

## Story 7.4: Safe Unpack to Staging Directory (No Path Traversal)

**As a** система установки  
**I want** безопасно распаковывать `.sqlite.gz` в staging директорию  
**So that** исключить path traversal и выход за границы staging

### Acceptance Criteria
- [ ] Staging: `Application Support/Lexickon/Staging/<dataset_key>/<version>/`
- [ ] Распаковка через `libarchive` / `gzip` + `FileManager` (без shell)
- [ ] Проверка каждого entry: `destinationPath.hasPrefix(stagingRoot)`
- [ ] Ожидаемый результат: один файл `dataset.sqlite`
- [ ] При нарушении границ: cleanup staging, `InstallError.pathTraversal`

### Technical Notes
- `ArchiveExtractor` actor
- Не использовать `unzip` CLI — только Swift/API

---

## Story 7.5: Free Space Check & Expected Size Validation

**As a** система установки  
**I want** проверять свободное место и соответствие размера перед распаковкой  
**So that** не заполнить диск и не оставить битый файл

### Acceptance Criteria
- [ ] `FileManager.freeSpaceAtPath(stagingRoot)` ≥ `expectedSize * 1.5` (запас 50%)
- [ ] `expectedSize` берётся из manifest
- [ ] После распаковки: реальный размер ≈ expectedSize (±10%)
- [ ] При нехватке места: `InstallError.insufficientSpace`

### Technical Notes
- Проверка ДО скачивания (по manifest) и ПОСЛЕ распаковки

---

## Story 7.6: SQLite Integrity & Schema Validation

**As a** система установки  
**I want** валидировать SQLite файл перед активацией  
**So that** не активировать повреждённую или несовместимую базу

### Acceptance Criteria
- [ ] `PRAGMA integrity_check` → "ok"
- [ ] `PRAGMA quick_check` → "ok"
- [ ] Проверка `schema_version` таблицы `meta` == ожидаемой (из manifest)
- [ ] Наличие обязательных таблиц: `frequency`, `meta`, индексы
- [ ] При ошибке: cleanup staging, `InstallError.schemaMismatch` / `corrupted`

### Technical Notes
- `SQLiteValidator` actor, использует `SQLite.swift` или прямой `sqlite3` API
- Не открывать на MainActor

---

## Story 7.7: Atomic Version Switch & Registry Update

**As a** система установки  
**I want** атомарно переключить активную версию и обновить реестр  
**So that** нет промежуточного состояния (ни старой, ни новой)

### Acceptance Criteria
- [ ] Активная версия: симлинк `Active/<dataset_key> -> Staging/.../dataset.sqlite` ИЛИ `FileManager.replaceItemAt`
- [ ] Обновление `LocalDatasetRegistry` (SQLite/JSON) в той же транзакции
- [ ] При сбое на любом шаге: откат, старая версия работает
- [ ] Registry запись: `dataset_key`, `data_version`, `schema_version`, `checksum`, `installed_at`, `status: active`

### Technical Notes
- `DatasetActivator` actor
- Атомарность: либо всё применилось, либо ничего
- Registry — отдельный файл/таблица, не в паке

---

## Story 7.8: Cleanup Temporary & Staging Files + Retry

**As a** система установки  
**I want** очищать временные артефакты и поддерживать retry  
**So that** не мусорить на диске и восстанавливаться после перебоев

### Acceptance Criteria
- [ ] `defer { cleanup() }` или `withTaskCancellationHandler` для гарантированного cleanup
- [ ] Удаление: temp download file, staging directory (при ошибке)
- [ ] При успехе: staging можно оставить для кэша или удалить (политика)
- [ ] Retry: до 3 попыток с exponential backoff (1s, 2s, 4s) для network errors
- [ ] Не ретраить: checksum mismatch, schema mismatch, path traversal

### Technical Notes
- `InstallationCleanup` helper
- Retry policy конфигурируемая

---

## Story 7.9: Actor Isolation & Concurrency Safety

**As a** разработчик  
**I want** чтобы установщик был actor-isolated и безопасен для конкурентного запуска  
**So that** одновременные установки одного dataset не ломают состояние

### Acceptance Criteria
- [ ] `DatasetInstaller` — `actor`
- [ ] Все внутренние компоненты (downloader, validator, extractor, activator) — actors или `@Sendable` замыкания
- [ ] Сериализация установок одного `dataset_key`: либо queue, либо lock
- [ ] Два параллельных вызова `install(datasetKey:)` → второй ждёт или возвращает `InstallError.alreadyInstalling`

### Technical Notes
- Использовать `Mutex` / `Task` queue внутри actor
- Тест: запустить 2 установки параллельно → только одна проходит, вторая ждёт/ошибка

---

## Story 7.10: Logging Without Signed URLs

**As a** security reviewer  
**I want** чтобы логи не содержали signed URL, токены, пароли  
**So that** при утечке логов не скомпрометирован доступ

### Acceptance Criteria
- [ ] Все `AppLogger` вызовы в установщике: без URL, без токенов
- [ ] Логируем: `dataset_key`, `version`, `stage`, `progress`, `error.type`
- [ ] Не логируем: `signedDownloadURL`, `Authorization` header, `checksum` (опционально, не секрет)

### Technical Notes
- Проверка в CI: `grep -r "signed.*url\|authorization\|bearer" --include="*.swift" Sources/Features/DatasetInstaller`

---

## Зависимости между сторис

```text
7.1 Download
  ├── 7.2 Cellular Policy (параллельно, используется в 7.1)
  ├── 7.3 SHA-256 (после 7.1)
  ├── 7.4 Unpack (после 7.3)
  ├── 7.5 Space Check (до 7.1 и после 7.4)
  ├── 7.6 SQLite Validation (после 7.4)
  ├── 7.7 Atomic Switch (после 7.6)
  ├── 7.8 Cleanup & Retry (всё время, фокус после 7.7)
  ├── 7.9 Actor Isolation (архитектура, сначала)
  └── 7.10 Logging (все этапы)
```

---

## Definition of Ready для спринта

- [ ] Все 10 stories имеют AC
- [ ] Зависимости согласованы
- [ ] Открытые вопросы #6 (background download) и #3 (mandatory dataset) не блокируют 7.1–7.9
- [ ] Технический дизайн: actors, protocols, error types зафиксированы в `Domain/DatasetInstaller.swift`

---

## Definition of Done для Epic

- [ ] Все 10 stories done
- [ ] Integration test: fixture pack → install → open SQLite → query works
- [ ] Fault injection tests (7 сценариев из документа)
- [ ] Concurrency test: 2 parallel installs
- [ ] Log audit: no secrets
- [ ] Code coverage ≥ 90% для DatasetInstaller module