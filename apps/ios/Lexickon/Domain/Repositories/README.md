# Репозитории Domain

`Domain/Repositories` содержит контракты доступа к данным, которые нужны
сценариям использования. Эти протоколы описывают возможности приложения, а не
способ получения или хранения данных.

## Текущие контракты

- `AuthRepository` — регистрация, вход, выход и состояние авторизации;
- `UserRepository` — текущий пользователь и его настройки;
- `DatasetCatalogRepository` — каталог, доступность и download URL;
- `InstalledDatasetRepository` — установленные датасеты и применение
  рассчитанного sync-плана;
- `FrequencyRepository` — поиск частотности по выбранному датасету.

Use case зависит от подходящего протокола через existential-тип:

```swift
struct GetInstalledDatasetsUseCase: Sendable {
    private let repository: any InstalledDatasetRepository

    init(repository: any InstalledDatasetRepository) {
        self.repository = repository
    }
}
```

## Правила контрактов

- Имя протокола выражает доменную роль: `DatasetCatalogRepository`, а не
  `DatasetCatalogRepositoryProtocol`.
- В сигнатурах используются только Domain-модели и типы стандартной библиотеки.
- Протокол не знает об API, DTO, `URLSession`, Keychain, SQLite и конкретном
  формате хранения.
- В имени нет `Remote`, `Local`, `File` или другого инфраструктурного признака.
- Репозитории соответствуют `Sendable` и не требуют `MainActor`.
- Ошибки инфраструктуры преобразуются реализацией в `AppError` до выхода из
  слоя Data.
- Контракт формируется потребностями use case, а не полным набором операций
  внешнего API или базы данных.

## Как добавить репозиторий

1. Определить Domain input/output модели для нового сценария.
2. Добавить минимальный протокол, необходимый use case'ам.
3. Создать use case, зависящий от `any <Name>Repository`.
4. Реализовать контракт в `Data/Repositories`.
5. Зарегистрировать реализацию в `RepositoriesAssembly` и use case в `UseCases`.
6. Добавить тесты контракта реализации и поведения use case.
