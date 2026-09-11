# Реализации репозиториев

`Data/Repositories` содержит реализации протоколов из `Domain/Repositories`.
Репозиторий является границей между Domain и инфраструктурой: он получает
данные из одного или нескольких data source и наружу возвращает только
Domain-модели.

```text
Domain use case
      ↓
Domain repository protocol
      ↑ implements
Data repository
      ├── Remote API
      ├── Local storage
      └── DTO / record mapping
```

## Структура

- `Auth` содержит запросы авторизации и `AuthRepositoryImpl`;
- `Dataset` содержит `DatasetCatalogRepositoryImpl`,
  `InstalledDatasetRepositoryImpl`, API-запросы и transport DTO;
- `UnavailableRepositories.swift` содержит fail-fast реализации для ещё не
  подключённых зависимостей.

`SynchronizeDatasetsUseCase` в Domain координирует удалённый каталог и локальное
хранилище. Чистый `DatasetSyncPlanner` также находится в Domain.

## Ответственность реализации

- вызывать типизированные data source;
- преобразовывать Domain input в request DTO;
- преобразовывать response DTO и database record в Domain-модели;
- выполнять одну определённую возможность доступа к данным;
- нормализовать `NetworkError`, ошибки хранилища и неизвестные ошибки в
  `AppError`;
- не пропускать transport DTO и инфраструктурные ошибки за границу Data.

Repository не должен содержать UI-состояние, навигацию или зависеть от
Presentation. Низкоуровневые детали HTTP, Keychain и файловой системы остаются
в соответствующих `DataSources`.

## Именование

- Протокол сохраняет чистое доменное имя, например
  `DatasetCatalogRepository`.
- Единственная production-реализация без дополнительной доменной специализации
  получает суффикс `Impl`, например `AuthRepositoryImpl`,
  `DatasetCatalogRepositoryImpl` или `InstalledDatasetRepositoryImpl`.
- Заглушка, которая сообщает о неподключённой зависимости, называется
  `Unavailable<Name>Repository`.
- DTO имеют суффикс `DTO` и располагаются рядом с feature, которому принадлежат.

## Тестирование

Тесты реализации должны проверять наблюдаемый контракт, включая:

- построение API request и преобразование ответа;
- взаимодействие с локальным data source;
- согласованность данных при синхронизации;
- полный mapping ожидаемых инфраструктурных ошибок;
- отсутствие чувствительных transport-данных в локальном состоянии и логах.

Для HTTP-тестов используется `URLProtocolStub`; запущенный backend не требуется.

Подробности authentication flow описаны в `Auth/README.md`.
