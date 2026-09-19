# Dataset DTO

Эта директория содержит transport-модели dataset API. Они повторяют wire-контракт
backend и используются только внутри слоя Data.

## Файлы

- `DatasetManifestDTO.swift` — response каталога и преобразование элементов
  манифеста в `Dataset`;
- `DatasetSyncDTOs.swift` — request/response синхронизации и server actions;
- `DatasetDownloadURLDTO.swift` — response с временным URL для скачивания
  версии датасета.

## Граница с Domain

DTO не должны выходить из `Data/Repositories/Dataset`. Репозиторий принимает и
возвращает Domain-модели, выполняя преобразование на границе:

```text
Domain input -> request DTO -> API
API response -> response DTO -> validation -> Domain model
```

Имена и optional-поля DTO соответствуют backend payload. Общий `APIClient`
преобразует ключи между `camelCase` и `snake_case`, поэтому вручную задавать
`CodingKeys` нужно только при отклонении wire-контракта от этой стратегии.

## Правила

- Все transport-модели имеют суффикс `DTO` и соответствуют `Sendable`.
- Request DTO реализуют `Encodable`, response DTO — `Decodable`.
- DTO не содержат UI- или navigation-состояние.
- Значения из response считаются недоверенными и проверяются до создания
  Domain-модели.
- Неизвестные backend status преобразуются в безопасное Domain-состояние, а не
  приводят к неявному успешному результату.
- Signed download URL не сохраняется в `InstalledDatasetRegistry` и не попадает
  в логи.
- Общие для всего API transport-модели, например `APIErrorDTO`, остаются в
  `DataSources/Remote/API/DTO`.

## Добавление DTO

1. Зафиксировать фактический request или response schema backend.
2. Добавить минимальную `Encodable` или `Decodable` модель без Domain-логики.
3. Реализовать явное преобразование в Domain-модель рядом с DTO или
   репозиторием.
4. Проверить обязательные значения, enum cases, размеры, checksum и URL до
   пересечения границы Data.
5. Добавить decoding/encoding и mapping-тесты, включая повреждённые и
   неизвестные значения.
