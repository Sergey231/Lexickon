---
stepsCompleted: []
inputDocuments:
  - _bmad-output/stage-7-stories.md
  - _bmad-output/planning-artifacts/briefs/brief-Lexickon-2026-09-20/brief.md
  - _bmad-output/planning-artifacts/briefs/brief-Lexickon-2026-09-20/addendum.md
  - apps/ios/docs/ios_mvp_implementation_stages.md
  - backend/docs/api_contract.md
  - backend/docs/architecture.md
  - apps/ios/Lexickon/Domain/README.md
  - apps/ios/Lexickon/Domain/Repositories/README.md
  - apps/ios/Lexickon/Data/README.md
  - apps/ios/Lexickon/Data/Repositories/README.md
  - apps/ios/Lexickon/Data/Repositories/Dataset/DTO/README.md
  - apps/ios/Lexickon/App/DependencyInjection/README.md
  - apps/ios/Lexickon/Presentation/README.md
---

# Lexickon - Epic Breakdown

## Overview

Этот документ содержит требования и декомпозицию Epic 7 «Безопасная установка
датасета». Он уточняет исходную декомпозицию по фактическим API-контрактам,
архитектурным правилам iOS-клиента и уже существующему коду Lexickon.

## Requirements Inventory

### Functional Requirements

FR1: Клиент должен получать короткоживущий подписанный URL только для конкретной
разрешённой версии датасета и не сохранять URL в постоянное локальное состояние.

FR2: Клиент должен скачивать immutable SQLite-пак во временное расположение, не
изменяя активную локальную версию до завершения всех проверок.

FR3: Операция скачивания должна сообщать прогресс и поддерживать cooperative
cancellation вплоть до сетевого transport.

FR4: Автоматическая загрузка должна учитывать настройку `syncOverCellular`;
поведение явно запущенной пользователем загрузки в cellular-сети должно быть
зафиксировано отдельным продуктовым решением до реализации соответствующей ветки.

FR5: Клиент должен проверить SHA-256 скачанного сжатого файла до распаковки и
активации, используя checksum из доверенного manifest/download-url контракта.

FR6: Клиент должен распаковать поддерживаемый `gzip`-пак в изолированное staging-
расположение, самостоятельно определяя целевой путь и не используя shell-команды.

FR7: Клиент должен отклонять неизвестный или неподдерживаемый алгоритм сжатия до
изменения локального состояния.

FR8: Клиент должен проверить достаточность свободного места до установки и
валидировать ожидаемые размеры на тех этапах, где контракт предоставляет
соответствующий compressed/uncompressed размер.

FR9: Клиент должен проверить целостность распакованного SQLite-файла, совместимость
его schema version и минимальный schema probe до активации.

FR10: Клиент должен активировать проверенную версию так, чтобы читатели видели либо
предыдущую согласованную версию, либо новую, но никогда промежуточное состояние.

FR11: После успешной активации клиент должен сохранить в локальном реестре
`dataset_key`, data version, SQLite schema version, SHA-256 и дату установки,
используя существующую модель `InstalledDataset`.

FR12: Ошибка на любом этапе должна оставлять предыдущий установленный pack рабочим
и приводить файловую систему и реестр к документированному восстанавливаемому
состоянию.

FR13: Временный download-файл и незавершённый staging должны удаляться после
ошибки или отмены; политика хранения успешно установленной версии и предыдущих
версий должна быть зафиксирована до реализации cleanup.

FR14: Повторные попытки должны применяться только к подтверждённым transient
network failures; checksum, schema, compatibility и local-storage failures не
должны автоматически повторяться.

FR15: Одновременные операции установки одного `dataset_key` должны быть
сериализованы или безопасно дедуплицированы с однозначно определённым поведением
второго вызова.

FR16: Установщик должен предоставлять типизированные состояния/ошибки, достаточные
для последующего UI этапа 8: downloading, verifying, installing, cancellation,
network, checksum, schema, disk-space и local-storage failure.

### NonFunctional Requirements

NFR1: Установка должна быть fail-safe: ни network error, ни cancellation, ни
checksum mismatch, ни ошибка распаковки, schema validation или активации не может
повредить предыдущий рабочий pack.

NFR2: Хеширование, файловые операции, распаковка и SQLite validation не должны
выполняться на `MainActor`.

NFR3: Компоненты и значения, пересекающие concurrency boundaries, должны
соответствовать Swift 6 strict-concurrency требованиям и `Sendable`-контрактам.

NFR4: Проверка SHA-256 и обработка файла должны быть потоковыми и не требовать
загрузки всего датасета в память.

NFR5: Cancellation должна завершать активную работу за ограниченное число
cooperative cancellation points и запускать cleanup временных артефактов.

NFR6: Логи должны создаваться только через `AppLogger` и не содержать signed URL,
authorization headers, токены, пароли, содержимое файлов или пользовательские
данные.

NFR7: Установка должна сохранять разделение слоёв: Domain не импортирует
`URLSession`, `FileManager`, `SQLite3`, SwiftUI или конкретные record/DTO-типы.

NFR8: Все инфраструктурные ошибки должны быть нормализованы до Domain/AppError-
состояний до выхода из Data.

NFR9: Решение должно работать с immutable published packs; изменение содержимого
уже опубликованной версии не поддерживается.

NFR10: Реализация должна иметь unit-, integration-, fault-injection- и concurrency-
тесты для критических переходов, включая сохранность предыдущей версии после
каждого отказа.

NFR11: Проверка должна включать fixture pack, checksum match/mismatch, недостаток
места, повреждённый gzip/SQLite, несовместимую schema version, отмену, сбой перед
активацией и две параллельные установки одного dataset.

NFR12: Заявленная в исходной декомпозиции цель покрытия `DatasetInstaller` не ниже
90% требует отдельного подтверждения как проектная политика; до подтверждения она
не является release gate.

### Additional Requirements

- Backend остаётся control plane и не скачивает/устанавливает пак за клиента;
  содержимое датасетов читается мобильным приложением локально.
- Backend/PostgreSQL является источником истины для статуса версии, доступа,
  checksum и current version; опубликованные storage objects immutable.
- `dataset_key` имеет формат `{domain}-{language}`, data version использует SemVer,
  SQLite schema version является отдельным положительным целым значением.
- Download URL требует авторизации, имеет короткий TTL и не выдаётся для revoked
  или deprecated версии.
- Контракт download-url предоставляет URL, expiry, SHA-256, compressed size и
  compression; installer не должен предполагать наличие иных полей без изменения
  API-контракта.
- Текущий публичный backend-контракт поддерживает `gzip`; расширение на `zstd` или
  `none` требует синхронного изменения backend contract, DTO, Domain enum и тестов.
- Для одиночного `.sqlite.gz` нет archive entries с путями. Защита от path
  traversal обеспечивается тем, что клиент сам формирует единственный staging-
  путь; entry-by-entry проверка понадобится только при появлении контейнерного
  архивного формата.
- `InstalledDatasetRegistry` уже существует как actor-backed файловый data source,
  а `FileInstalledDatasetRegistry.upsert` атомарно переписывает JSON-файл.
- Текущая `InstalledDataset` хранит key, version, SQLite schema version, checksum,
  installedAt и updateState; отдельного поля `status: active` в модели нет.
- Файловая активация SQLite и обновление JSON-реестра не образуют одну общую
  транзакцию. Архитектура должна определить порядок commit, rollback/recovery и
  поведение после process termination между двумя операциями.
- Конкретный механизм active-version pointer (`replaceItemAt`, rename или иной
  вариант) и политика хранения предыдущих версий остаются открытыми решениями.
- Domain должен определить минимальный installer use case и типизированный
  результат; `URLSession`, hashing, decompression, SQLite probe и filesystem
  implementations принадлежат Data.
- Новые production-зависимости регистрируются явно через `DataSourcesAssembly`,
  `RepositoriesAssembly`, `UseCases` и `AppContainer`; Presentation получает
  только use cases.
- Полноценная background/resumable download, pause/resume и восстановление после
  termination не входят в подтверждённый MVP, пока не принято открытое решение 6.
- Обязательный dataset и gate перехода в Main относятся к этапу 8 и не должны
  блокировать внутреннюю корректность installer этапа 7.
- SQL-контракт frequency query ещё не утверждён. В Epic 7 допустим только
  минимальный compatibility/schema probe, не реализация поиска.
- Отдельной UX-декомпозиции в Epic 7 нет: UI выбора, прогресса и ошибок относится
  к этапу 8, а Epic 7 предоставляет ему типизированный install contract.

### UX Design Requirements

Для Epic 7 отдельные UX Design Requirements отсутствуют: подтверждённая область
эпика ограничена Domain/Data установщиком. Требования к экранным состояниям и
пользовательским действиям будут декомпозированы в Epic 8.

### FR Coverage Map

{{requirements_coverage_map}}

## Epic List

{{epics_list}}

