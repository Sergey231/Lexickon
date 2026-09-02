# Внедрение зависимостей

В Lexickon используется ручной DI без стороннего контейнера, service locator и
`resolve(Type.self)`.

## Схема

```text
ProductionAssembly
        ↓
   AppContainer
        ↓
DataSourcesAssembly → RepositoriesAssembly → UseCases
        ↓
SwiftUI Environment(\.useCases)
        ↓
View / ViewModel
```

## Компоненты

### ProductionAssembly

Создаёт production `DataSourcesAssembly` и отдаёт его в `AppContainer`.

### DataSourcesAssembly

Хранит инфраструктуру и низкоуровневые источники данных: `APIClient`,
`SessionController`, token store, transport и refresh-стратегию.

### RepositoriesAssembly

Хранит реализации доменных репозиториев. В production строится из
`DataSourcesAssembly`; в тестах принимает stub-репозитории через явный init.

### UseCases

Единый список use case’ов приложения. UI получает именно `UseCases`, а не
репозитории, API-клиент или data sources.

`UseCases` кладётся в SwiftUI Environment:

```swift
AppCoordinatorView(coordinator: coordinator)
    .environment(\.useCases, container.useCases)
```

Экран или coordinator-view берёт нужный use case и передаёт его дальше:

```swift
@Environment(\.useCases) private var useCases

LoginViewModel(
    loginUseCase: useCases.loginUseCase,
    navigate: { step in
        authCoordinator.navigate(to: step)
    }
)
```

## Правила

- Presentation не получает `AppContainer`, `RepositoriesAssembly` или
  `DataSourcesAssembly`.
- ViewModel принимает конкретные use case’ы через init.
- SwiftUI Environment используется только как простой способ доставить
  `UseCases` в дерево view.
- Новая зависимость добавляется явно: репозиторий в `RepositoriesAssembly`, use
  case в `UseCases`, затем конкретный экран берёт его из `Environment`.
