# Presentation

Presentation содержит всё, что относится к пользовательскому интерфейсу и
управлению пользовательскими сценариями: SwiftUI View, ViewModel, экранные
состояния, координаторы и переиспользуемые UI-компоненты.

## Структура

Структура сценариев следует дереву координаторов:

```text
Presentation/
├── App/
│   ├── AppCoordinator.swift
│   ├── Launch/
│   │   ├── LaunchView.swift
│   │   └── LaunchViewModel.swift
│   ├── Authentication/
│   │   └── AuthCoordinator.swift
│   ├── DatasetSetup/
│   │   └── DatasetSetupCoordinator.swift
│   └── Main/
│       └── MainCoordinator.swift
├── Components/
│   └── NavigationPlaceholderScreen.swift
└── Navigation/
    └── Coordinator.swift
```

В `Presentation/Navigation` располагается только общая навигационная
инфраструктура. Корневой пользовательский сценарий находится в
`Presentation/App`. Каждый конкретный Coordinator расположен в директории
своего сценария. Его дочерние Coordinator и уникальные экранные модули
размещаются внутри этой директории.
Если экран или компонент используется несколькими соседними сценариями, он
поднимается до их ближайшего общего уровня. Общие UI-компоненты без бизнес-логики
располагаются в `Presentation/Components`.

Например, экранные модули авторизации, которые используются только
`AuthCoordinator`, размещаются так:

```text
Presentation/App/Authentication/
├── AuthCoordinator.swift
├── AuthRoot/
│   ├── AuthRootView.swift
│   └── AuthRootViewModel.swift
├── Login/
│   ├── LoginView.swift
│   └── LoginViewModel.swift
├── Registration/
│   ├── RegistrationView.swift
│   └── RegistrationViewModel.swift
└── Shared/
    ├── AuthFormContainer.swift
    └── AuthFormState.swift
```

Presentation зависит от Domain, но Domain ничего не знает о Presentation. Data
не используется из View или ViewModel напрямую: доступ к данным происходит
через Domain use case’ы, переданные фабриками из `App/DependencyInjection`.

## Навигация

Навигация Lexickon построена как иерархическая система Step-Driven Coordinator,
адаптированная для декларативной модели SwiftUI. Внешняя навигационная библиотека
и отдельный Router не используются.

## Концепция

`Step` — единственный тип навигационного сообщения. Он описывает произошедшее
событие или требуемое состояние, но не способ отображения интерфейса.

```text
View
      ↓ пользовательское действие
ViewModel
      ↓ Step
Coordinator.navigate(to:)
      ↓
изменение navigation state или передача Step родителю
      ↓
CoordinatorView → SwiftUI
```

Решение о том, станет Step push-переходом, sheet, full-screen cover, сменой
вкладки или заменой корневого сценария, принимает Coordinator. Благодаря этому
ViewModel не зависит от конкретного способа presentation.

Экранный View не вызывает Coordinator напрямую. Пользовательские действия,
которые приводят к навигации, проходят через ViewModel и выражаются Step.
ViewModel может отправить Step через callback, но не владеет Coordinator и не
изменяет navigation state самостоятельно.

CoordinatorView создаёт экранный ViewModel, передавая ему необходимые use case’ы
и Step callback, а затем передаёт готовый ViewModel во View. Экранный View не
получает use case’ы через init и не создаёт ViewModel из domain-зависимостей.

Навигация разделена на независимые сценарии. Каждый сценарий имеет собственный
Step-тип, Coordinator и CoordinatorView. Дочерний сценарий завершается обычным
Step, который его Coordinator преобразует в Step родительского уровня и передаёт
через callback. Отдельных Result-типов нет.

Step может играть одну из двух ролей:

- event Step сообщает о событии и сразу интерпретируется Coordinator;
- presentation Step сохраняется в navigation state и отображается SwiftUI.

Обе роли выражаются cases одного Step enum и не образуют отдельные сущности.

## Сущности

### CoordinatorStep

Общий marker protocol для всех Step-типов:

```swift
protocol CoordinatorStep: Hashable, Identifiable, Sendable {}
```

`Hashable` позволяет хранить Step в `NavigationStack.path`, `Identifiable` —
использовать его в modal presentation, а `Sendable` фиксирует возможность
безопасной передачи значения между concurrency domains.

### Coordinator

Coordinator интерпретирует Step своего сценария и управляет его навигационным
состоянием:

```swift
@MainActor
protocol Coordinator: AnyObject {
    associatedtype Step: CoordinatorStep

    func navigate(to step: Step)
}
```

Coordinator не создаёт SwiftUI View внутри `navigate(to:)`, не содержит
бизнес-логику и не выполняет операции с данными.

### CoordinatorView

CoordinatorView связывает наблюдаемое состояние Coordinator со штатными
механизмами SwiftUI:

- `NavigationStack` для push-навигации;
- `.sheet(item:)` для sheet;
- `.fullScreenCover(item:)` для полноэкранного представления;
- `TabView` для вкладок;
- замену View subtree для перехода между корневыми сценариями.

CoordinatorView сопоставляет presentation Step с конкретным экраном и связывает
Step callback экранного ViewModel с `Coordinator.navigate(to:)`.

## Navigation state

SwiftUI требует явного состояния для построения интерфейса. Это техническое
представление Step, а не дополнительная навигационная модель:

- `currentStep: AppStep` — активный корневой presentation Step;
- `path: [Step]` — push stack сценария;
- `sheet: Step?` — активный sheet;
- `fullScreenCover: Step?` — активное полноэкранное представление;
- `selectedTab` — выбранная вкладка.

`AppCoordinator` интерпретирует события верхнего уровня и хранит только
нормализованный presentation Step в `currentStep`. Дочерние Coordinators ему не
принадлежат.

`AppCoordinatorView` выбирает сценарий по `currentStep`. `CoordinatorView`
выбранного сценария создаёт его Coordinator и удерживает через `@State`. При
изменении `currentStep` старый View subtree удаляется, поэтому его Coordinator
освобождается вместе со всем navigation state.

Если сценарий не имеет собственного дочернего Coordinator, как `Launch`,
`AppCoordinatorView` создаёт его корневой ViewModel напрямую и передаёт callback
в `AppCoordinator`.

## Основные правила

- все навигационные намерения и результаты выражаются Step;
- экранный View не вызывает Coordinator напрямую;
- пользовательское действие, приводящее к навигации, проходит через ViewModel;
- CoordinatorView создаёт экранный ViewModel и передаёт его во View;
- use case’ы передаются во ViewModel, но не протаскиваются через экранный View;
- каждый Coordinator принимает только Step своего сценария;
- Step не выбирает способ presentation;
- дочерний Coordinator сообщает о завершении Step родительского уровня, но не
  выбирает следующий сценарий;
- Coordinator изменяет состояние, а CoordinatorView отображает его;
- временем жизни дочернего Coordinator владеет его CoordinatorView;
- переход между корневыми сценариями заменяет предыдущий View subtree, а не
  добавляет его в общий push stack.
