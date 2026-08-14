# Навигационная система Lexickon

Этот документ описывает фактическую навигационную систему приложения в её
текущем состоянии. Он является основным источником информации о назначении
navigation-типов, их жизненном цикле и взаимодействии со SwiftUI.

Навигация построена как иерархический Step-Driven Coordinator и использует
только штатные механизмы SwiftUI:

- Observation (`@Observable` и `@Bindable`) для синхронизации состояния;
- `NavigationStack` с типизированным массивом path для push-навигации;
- `.sheet(item:)` для sheet presentation;
- `.fullScreenCover(item:)` для полноэкранной presentation;
- `TabView(selection:)` для выбора вкладки;
- замену корневого SwiftUI subtree при переходе между root flows.

Внешней navigation-библиотеки и отдельного Router в проекте нет.

## Главная идея

Coordinator хранит навигационное состояние и принимает типизированные команды
`Step`. CoordinatorView наблюдает это состояние и преобразует его в конкретные
SwiftUI presentation-механизмы.

```text
Пользовательское действие
        │
        ▼
CoordinatorView
        │ handle(Step) или finish(Result)
        ▼
Coordinator
        │ изменяет path / sheet / cover / selectedTab / root
        ▼
Observation
        │
        ▼
SwiftUI обновляет NavigationStack / modal / TabView / root View
```

Root-level навигация организована отдельным потоком:

```text
LexickonApp
  └── AppCoordinator
        ├── AuthCoordinator
        ├── DatasetSetupCoordinator
        └── MainCoordinator
```

В каждый момент времени `AppCoordinator` удерживает только Coordinator активного
root flow. Переход Authentication → Dataset Setup → Main не является push в
общий stack. Старый root flow освобождается и заменяется новым.

## Структура файлов

```text
App/
  LexickonApp.swift

Navigation/
  README.md

  Core/
    Coordinator.swift

  App/
    AppStep.swift
    AppCoordinator.swift
    AppCoordinatorView.swift

  Authentication/
    AuthStep.swift
    AuthCoordinator.swift
    AuthCoordinatorView.swift

  DatasetSetup/
    DatasetSetupStep.swift
    DatasetSetupCoordinator.swift
    DatasetSetupCoordinatorView.swift

  Main/
    MainStep.swift
    MainCoordinator.swift
    MainCoordinatorView.swift

  Views/
    NavigationPlaceholderScreen.swift
```

Файлы каждого flow разделены по ответственности:

| Тип файла | Содержимое | Ответственность |
| --- | --- | --- |
| `*Step.swift` | Step, Result, tab и modal enums | Описывает типизированный navigation vocabulary конкретного flow |
| `*Coordinator.swift` | Наблюдаемое navigation state и таблица переходов | Решает, как Step изменяет навигацию, и сообщает родителю о завершении flow |
| `*CoordinatorView.swift` | `NavigationStack`, destinations, sheets, covers и root View | Преобразует состояние Coordinator в SwiftUI UI |
| `Navigation/Core` | Общие протоколы и операции path | Задаёт единый контракт всех координаторов |
| `Navigation/Views` | Общие navigation-related views | Содержит временные экраны, используемые несколькими flows |

## Термины и разделение ответственности

### Step

`Step` — типизированная команда конкретному Coordinator. Он описывает
навигационное намерение, например:

```swift
coordinator.handle(.login)
coordinator.handle(.about)
coordinator.handle(.selectTab(.profile))
```

Step не задаёт presentation style самостоятельно. Решение о том, будет ли это
push, sheet, full-screen cover, смена tab или замена root, находится в
`handle(_:)` соответствующего Coordinator.

В текущей реализации некоторые Step одновременно используются как значения
`NavigationStack.path`. Это относится только к push destinations. Команды для
sheet, cover и смены tab в path не добавляются.

### Result

`CoordinatorResult` — типизированный результат завершения дочернего flow.
Результат направлен снизу вверх: дочерний Coordinator ничего не знает о
`AppStep` и не выбирает следующий root самостоятельно.

Пример:

```swift
AuthCoordinatorResult.authenticated
    → AppCoordinator.handle(_ result: AuthCoordinatorResult)
    → AppStep.showDatasetSetup
```

Это сохраняет дочерний flow независимым от родительского.

### Presentation state

Presentation state — данные, которые SwiftUI получает через binding:

- `path` — push stack;
- `sheet` — активный sheet или `nil`;
- `fullScreenCover` — активный full-screen cover или `nil`;
- `selectedTab` — выбранная вкладка;
- `root` — активный root flow.

Coordinator изменяет данные, а не вызывает императивные методы показа View.

### Coordinator

Coordinator:

- принимает только свой Step;
- хранит только navigation state;
- выбирает presentation style;
- завершает flow через typed Result;
- для root coordinator создаёт и освобождает child coordinators.

Coordinator не создаёт UI внутри `handle(_:)`, не выполняет сетевые запросы,
не работает с Keychain, SQLite или файловой системой и не содержит продуктовых
бизнес-правил.

### CoordinatorView

CoordinatorView является SwiftUI-адаптером Coordinator. Он:

- получает Coordinator через `@Bindable`;
- связывает `path` с `NavigationStack`;
- сопоставляет push Step с destination View;
- связывает modal state с `.sheet` и `.fullScreenCover`;
- передаёт пользовательские события обратно в Coordinator.

CoordinatorView не решает последовательность root flows и не хранит собственную
копию navigation state.

## Core: общий контракт координаторов

Общие navigation-типы находятся в `Core/Coordinator.swift`.

### `CoordinatorStep`

```swift
protocol CoordinatorStep: Hashable, Sendable {}
```

Это marker protocol для Step-типов.

- `Hashable` необходим для использования Step в типизированном
  `NavigationStack.path` и поиска уже открытого destination.
- `Sendable` явно фиксирует возможность безопасной передачи значения между
  concurrency domains. Само изменение UI-bound navigation state всё равно
  выполняется на `MainActor`.

Протокол не содержит методов: значение Step интерпретирует конкретный
Coordinator.

### `Coordinator`

```swift
@MainActor
protocol Coordinator: AnyObject {
    associatedtype Step: CoordinatorStep

    func handle(_ step: Step)
}
```

Назначение частей контракта:

- `@MainActor` гарантирует, что navigation state изменяется на главном actor;
- `AnyObject` ограничивает Coordinator ссылочными типами, что важно для
  наблюдаемого изменяемого состояния и identity;
- `associatedtype Step` связывает каждый Coordinator только с его Step;
- `handle(_:)` является единой точкой интерпретации navigation-команд.

Из-за `associatedtype` нельзя случайно передать `MainStep` в
`AuthCoordinator` — такая ошибка обнаруживается компилятором.

### `pushUnique(_:)`

```swift
extension Array where Element: CoordinatorStep {
    mutating func pushUnique(_ step: Element) {
        if let existingIndex = firstIndex(of: step) {
            removeSubrange(index(after: existingIndex)..<endIndex)
        } else {
            append(step)
        }
    }
}
```

Операция используется typed path всех дочерних координаторов. Её семантика:

- если Step отсутствует в path — добавить его на вершину;
- если Step уже есть — оставить его и удалить всё после него;
- никогда не хранить две одинаковые destinations в одном path.

Это не только защита от повторного push, но и операция, аналогичная `popTo`.

| Path до вызова | Step | Path после вызова |
| --- | --- | --- |
| `[]` | `.login` | `[.login]` |
| `[.login]` | `.login` | `[.login]` |
| `[.login, .registration]` | `.login` | `[.login]` |
| `[.selection]` | `.installation` | `[.selection, .installation]` |

## Точка входа приложения

`LexickonApp` является composition root UI и navigation слоя:

```swift
@main
@MainActor
struct LexickonApp: App {
    private let container: AppContainer
    private let coordinator: AppCoordinator

    init() {
        container = ProductionAssembly.makeContainer()
        coordinator = AppCoordinator()
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: coordinator)
        }
    }
}
```

`AppCoordinator` создаётся один раз на lifetime экземпляра `LexickonApp` и
передаётся в `AppCoordinatorView`. Сейчас `AppContainer` создаётся рядом, но
navigation placeholder flows ещё не используют его зависимости.

Default initializer `AppCoordinator()` начинает с
`AppStep.showAuthentication`.

## App flow: корневая навигация

### `AppStep`

`AppStep` содержит команды верхнего уровня:

| Case | Результат |
| --- | --- |
| `.showAuthentication` | Заменить текущий root на Authentication |
| `.showDatasetSetup` | Заменить текущий root на Dataset Setup |
| `.showMain` | Заменить текущий root на Main |
| `.logout` | Заменить текущий root на Authentication |
| `.sessionExpired` | Заменить текущий root на Authentication |

`.logout` и `.sessionExpired` приводят к одному UI-переходу, но остаются
разными семантическими событиями. В дальнейшем это позволяет по-разному
обрабатывать причину возврата к авторизации, не меняя child result contract.

### `AppRoot`

```swift
enum AppRoot: Equatable, Sendable {
    case authentication
    case datasetSetup
    case main
}
```

`AppRoot` — это не команда, а текущее состояние корневого UI. Разделение важно:

- `AppStep` описывает событие/намерение;
- `AppRoot` описывает то, что сейчас должно отображаться.

Например, три разных Step — `.showAuthentication`, `.logout` и
`.sessionExpired` — отображаются в один `AppRoot.authentication`.

### `AppCoordinator`

`AppCoordinator` владеет root navigation state:

```swift
private(set) var root: AppRoot
private(set) var rootRevision = 0

private(set) var authCoordinator: AuthCoordinator?
private(set) var datasetSetupCoordinator: DatasetSetupCoordinator?
private(set) var mainCoordinator: MainCoordinator?
```

#### `root`

Определяет, какую ветку отображает `AppCoordinatorView`.

#### Child coordinator properties

`authCoordinator`, `datasetSetupCoordinator` и `mainCoordinator` хранят
состояние соответствующих flows. Снаружи их можно читать, но изменять можно
только внутри `AppCoordinator` благодаря `private(set)`.

Инвариант реализации: после завершения `replaceRoot(with:)` ненулевым должен
быть только Coordinator активного root.

#### `rootRevision`

`rootRevision` является identity revision корневого SwiftUI subtree. Он
увеличивается при фактической замене root и используется так:

```swift
.id(coordinator.rootRevision)
```

Новая identity заставляет SwiftUI создать новый subtree вместо переиспользования
состояния завершённого flow. Это дополнительная защита от сохранения локального
View state и возможности вернуться в старый flow системным back gesture.

Повторная команда для уже активного и существующего root не увеличивает
`rootRevision`.

#### Обработка `AppStep`

```swift
func handle(_ step: AppStep) {
    switch step {
    case .showAuthentication, .logout, .sessionExpired:
        replaceRoot(with: .authentication)
    case .showDatasetSetup:
        replaceRoot(with: .datasetSetup)
    case .showMain:
        replaceRoot(with: .main)
    }
}
```

Таблица является единственным местом, где App Step сопоставляется с root.

#### Преобразование child results

Для каждого child result существует отдельный overload `handle`:

```swift
func handle(_ result: AuthCoordinatorResult) {
    switch result {
    case .authenticated:
        handle(.showDatasetSetup)
    }
}
```

Полная текущая цепочка:

| Child result | App Step | Новый root |
| --- | --- | --- |
| `AuthCoordinatorResult.authenticated` | `.showDatasetSetup` | `.datasetSetup` |
| `DatasetSetupCoordinatorResult.completed` | `.showMain` | `.main` |
| `MainCoordinatorResult.logout` | `.logout` | `.authentication` |
| `MainCoordinatorResult.sessionExpired` | `.sessionExpired` | `.authentication` |

#### `replaceRoot(with:)`

Замена root выполняется в строгом порядке:

1. Проверить, не является ли запрошенный root уже активным и полностью
   созданным.
2. Освободить ссылки на все child coordinators.
3. Записать новое значение `root`.
4. Увеличить `rootRevision`.
5. Создать Coordinator нового root.
6. Передать ему `onFinish` callback с `[weak self]`.

```text
Текущий child
    │
    ├── releaseChildren() → все child properties = nil
    │
    ├── root = newRoot
    ├── rootRevision += 1
    │
    └── создать ровно один новый child Coordinator
```

`[weak self]` не позволяет callback дочернего Coordinator сформировать retain
cycle с родителем.

Метод `activeChildExists(for:)` защищает от ситуации, когда значение `root`
совпадает, но соответствующий child Coordinator почему-либо отсутствует. В этом
случае flow будет создан заново.

### `AppCoordinatorView`

`AppCoordinatorView` отображает child CoordinatorView, соответствующий
`AppRoot`:

```swift
switch coordinator.root {
case .authentication:
    if let child = coordinator.authCoordinator {
        AuthCoordinatorView(coordinator: child)
    }
case .datasetSetup:
    if let child = coordinator.datasetSetupCoordinator {
        DatasetSetupCoordinatorView(coordinator: child)
    }
case .main:
    if let child = coordinator.mainCoordinator {
        MainCoordinatorView(coordinator: child)
    }
}
```

View не создаёт child coordinators. Их lifetime полностью принадлежит
`AppCoordinator`.

## Общая анатомия дочернего flow

Auth, Dataset Setup и Main используют один принцип:

```swift
@Observable
@MainActor
final class FeatureCoordinator: Coordinator {
    var path: [FeatureStep] = []
    var sheet: FeatureSheet?
    var fullScreenCover: FeatureFullScreenCover?

    private let onFinish: @MainActor (FeatureCoordinatorResult) -> Void

    func handle(_ step: FeatureStep) {
        // Step → изменение presentation state
    }

    func finish(with result: FeatureCoordinatorResult) {
        onFinish(result)
    }
}
```

### `@Observable`

Observation сообщает SwiftUI об изменениях `path`, modal state и selected tab.
Coordinator не обязан вручную вызывать `objectWillChange`.

### `@Bindable`

CoordinatorView принимает наблюдаемый Coordinator как `@Bindable`:

```swift
@Bindable var coordinator: AuthCoordinator
```

Это позволяет сформировать bindings `$coordinator.path`,
`$coordinator.sheet` и `$coordinator.fullScreenCover`.

### `path`

Typed array является источником истины push-навигации:

```swift
NavigationStack(path: $coordinator.path)
```

Изменение path работает в обе стороны:

- Coordinator добавляет или удаляет значения — SwiftUI меняет UI stack;
- пользователь нажимает Back или использует системный back gesture —
  `NavigationStack` обновляет связанный массив.

Модели данных приложения не передаются через path. В текущих placeholder flows
path содержит только Step без associated model values.

### Modal state

Sheet и full-screen cover используют отдельные optional enum:

```swift
.sheet(item: $coordinator.sheet) { sheet in ... }
.fullScreenCover(item: $coordinator.fullScreenCover) { cover in ... }
```

Каждый modal enum реализует `Identifiable`, возвращая `Self` как identity:

```swift
var id: Self { self }
```

Закрытие выполняется установкой соответствующего state в `nil`. Интерактивное
закрытие пользователем также синхронизируется SwiftUI обратно в binding.

Текущая модель не делает sheet и full-screen cover взаимоисключающими:
Coordinator может хранить оба значения одновременно. Отдельной очереди или
политики разрешения конфликтующих presentations сейчас нет.

### `onFinish` и `finish(with:)`

`onFinish` — единственный канал завершения дочернего flow. Он передаётся
родителем при создании Coordinator и остаётся private.

CoordinatorView может инициировать завершение:

```swift
coordinator.finish(with: .authenticated)
```

После callback родитель обычно заменяет root, поэтому вызывающий child
Coordinator освобождается. Код после `onFinish(result)` не должен рассчитывать,
что flow всё ещё активен.

### Destination builder

Каждый CoordinatorView содержит локальный метод:

```swift
@ViewBuilder
private func destination(for step: FeatureStep) -> some View
```

Он является сопоставлением значения typed path с экраном. Cases, предназначенные
для sheet, cover или команды, возвращают `EmptyView`, чтобы `switch` оставался
исчерпывающим. Нормальный `handle(_:)` никогда не добавляет такие cases в path.

## Authentication flow

### Типы `AuthStep.swift`

| Тип | Case | Назначение |
| --- | --- | --- |
| `AuthStep` | `.login` | Push экрана входа |
| `AuthStep` | `.registration` | Push экрана регистрации |
| `AuthStep` | `.help` | Показ help sheet |
| `AuthStep` | `.privacy` | Показ privacy full-screen cover |
| `AuthCoordinatorResult` | `.authenticated` | Сообщить App flow об успешной авторизации |
| `AuthSheet` | `.help` | Typed state для `.sheet(item:)` |
| `AuthFullScreenCover` | `.privacy` | Typed state для `.fullScreenCover(item:)` |

### `AuthCoordinator`

Таблица переходов реализована в `handle(_:)`:

| Step | Изменение состояния |
| --- | --- |
| `.login` | `path.pushUnique(.login)` |
| `.registration` | `path.pushUnique(.registration)` |
| `.help` | `sheet = .help` |
| `.privacy` | `fullScreenCover = .privacy` |

Начальный path пуст, поэтому корнем является `authenticationRoot`, а не один из
Step cases.

### `AuthCoordinatorView`

View связывает:

- `authenticationRoot` с корнем `NavigationStack`;
- `.login` и `.registration` с push destinations;
- `AuthSheet.help` с help sheet;
- `AuthFullScreenCover.privacy` с полноэкранным privacy экраном.

Кнопка завершения на root и login/registration destinations вызывает:

```swift
coordinator.finish(with: .authenticated)
```

Результат доходит до `AppCoordinator`, который заменяет root на Dataset Setup.

## Dataset Setup flow

### Типы `DatasetSetupStep.swift`

| Тип | Case | Назначение |
| --- | --- | --- |
| `DatasetSetupStep` | `.selection` | Push экрана выбора датасета |
| `DatasetSetupStep` | `.installation` | Push экрана установки |
| `DatasetSetupStep` | `.storageInfo` | Показ sheet с информацией о хранилище |
| `DatasetSetupStep` | `.installationDetails` | Показ full-screen деталей установки |
| `DatasetSetupCoordinatorResult` | `.completed` | Сообщить App flow о завершении setup |
| `DatasetSetupSheet` | `.storageInfo` | Typed state для sheet |
| `DatasetSetupFullScreenCover` | `.installationDetails` | Typed state для full-screen cover |

### `DatasetSetupCoordinator`

| Step | Изменение состояния |
| --- | --- |
| `.selection` | `path.pushUnique(.selection)` |
| `.installation` | `path.pushUnique(.installation)` |
| `.storageInfo` | `sheet = .storageInfo` |
| `.installationDetails` | `fullScreenCover = .installationDetails` |

### `DatasetSetupCoordinatorView`

`setupRoot` является корнем stack. Текущий placeholder-сценарий:

```text
Dataset Setup root
  ├── selection → installation → completed
  ├── storageInfo sheet
  └── completed
```

`finish(with: .completed)` передаёт результат в `AppCoordinator`, который
заменяет root на Main.

## Main flow

### Типы `MainStep.swift`

| Тип | Case | Назначение |
| --- | --- | --- |
| `MainStep` | `.frequency` | Push frequency destination |
| `MainStep` | `.profile` | Push profile destination |
| `MainStep` | `.settings` | Push settings destination |
| `MainStep` | `.about` | Показ about sheet |
| `MainStep` | `.onboarding` | Показ onboarding full-screen cover |
| `MainStep` | `.selectTab(MainTab)` | Переключение выбранной вкладки без push |
| `MainTab` | `.search` | Search tab и начальное значение |
| `MainTab` | `.frequency` | Frequency tab |
| `MainTab` | `.profile` | Profile tab |
| `MainCoordinatorResult` | `.logout` | Завершение Main из-за выхода пользователя |
| `MainCoordinatorResult` | `.sessionExpired` | Завершение Main из-за истечения сессии |
| `MainSheet` | `.about` | Typed state для about sheet |
| `MainFullScreenCover` | `.onboarding` | Typed state для onboarding cover |

### `MainCoordinator`

`MainCoordinator` дополнительно хранит:

```swift
var selectedTab: MainTab = .search
```

Таблица переходов:

| Step | Изменение состояния |
| --- | --- |
| `.frequency` | `path.pushUnique(.frequency)` |
| `.profile` | `path.pushUnique(.profile)` |
| `.settings` | `path.pushUnique(.settings)` |
| `.about` | `sheet = .about` |
| `.onboarding` | `fullScreenCover = .onboarding` |
| `.selectTab(tab)` | `selectedTab = tab` |

### `MainCoordinatorView`

В текущей реализации один `NavigationStack` оборачивает весь `TabView`:

```swift
NavigationStack(path: $coordinator.path) {
    TabView(selection: $coordinator.selectedTab) {
        // search, frequency, profile
    }
    .navigationDestination(for: MainStep.self) { step in
        destination(for: step)
    }
}
```

Следствия текущей структуры:

- у трёх tabs общий push path;
- push destination отображается поверх общего `TabView`;
- переключение tab само по себе не очищает path;
- независимых back stacks для каждой вкладки сейчас нет.

`.selectTab(.frequency)` только меняет selection. Это отличается от
`.frequency`, который добавляет push destination в общий path.

Main flow завершается двумя разными результатами:

```swift
coordinator.finish(with: .logout)
coordinator.finish(with: .sessionExpired)
```

Оба результата возвращают приложение к Authentication, но сохраняют различную
семантику события.

## `NavigationPlaceholderScreen`

`NavigationPlaceholderScreen<Actions>` — общий временный UI-компонент для
navigation scaffolding. Он принимает:

- локализованный title;
- локализованный subtitle;
- SF Symbol name;
- accessibility identifier заголовка;
- произвольный набор actions через `@ViewBuilder`.

Компонент не выполняет навигацию самостоятельно. Все кнопки передаются
конкретным CoordinatorView и вызывают нужный `handle` или `finish`.

Placeholder позволяет тестировать структуру flows до появления реальных feature
Views. По мере реализации features он должен заменяться конкретными экранами,
но navigation state и Coordinator contracts могут остаться прежними.

## Полные runtime-сценарии

### Запуск приложения

```text
LexickonApp.init
  → AppCoordinator(initialStep: .showAuthentication)
  → root изначально установлен в .authentication
  → handle(.showAuthentication)
  → replaceRoot(.authentication)
  → создаётся AuthCoordinator
  → AppCoordinatorView показывает AuthCoordinatorView
```

Начальное присваивание `root = .authentication` не мешает созданию child:
`activeChildExists(for:)` возвращает `false`, потому что `AuthCoordinator` ещё
не создан.

### Authentication → Dataset Setup

```text
AuthCoordinatorView
  → AuthCoordinator.finish(.authenticated)
  → onFinish callback
  → AppCoordinator.handle(AuthCoordinatorResult.authenticated)
  → AppCoordinator.handle(.showDatasetSetup)
  → releaseChildren() освобождает AuthCoordinator
  → root = .datasetSetup
  → rootRevision += 1
  → создаётся DatasetSetupCoordinator
  → SwiftUI пересоздаёт root subtree
```

### Dataset Setup → Main

```text
DatasetSetupCoordinator.finish(.completed)
  → AppCoordinator.handle(.showMain)
  → DatasetSetupCoordinator освобождается
  → создаётся MainCoordinator
  → root View заменяется без возможности Back в Dataset Setup
```

### Logout или session expiration

```text
MainCoordinator.finish(.logout | .sessionExpired)
  → AppCoordinator получает typed result
  → result преобразуется в AppStep
  → MainCoordinator освобождается вместе с path/modal/tab state
  → создаётся новый AuthCoordinator с чистым состоянием
```

## Инварианты текущей системы

При изменениях навигации должны сохраняться следующие правила:

1. Любое изменение navigation state выполняется на `MainActor`.
2. Каждый Coordinator принимает только собственный Step.
3. Child Coordinator не импортирует и не использует Step родителя.
4. Child flow завершается только typed Result через `finish(with:)`.
5. App flow преобразует Result ребёнка в собственный Step.
6. Root flow заменяется, а не добавляется в общий push stack.
7. При root replacement старый child Coordinator освобождается.
8. Повторный запрос уже активного root не создаёт новый Coordinator.
9. Повторный push Step не создаёт duplicate destination.
10. Coordinator не хранит View и не выполняет бизнес-/data-операции.
11. CoordinatorView отображает state, но не владеет lifecycle Coordinator.
12. Modal cases не должны вручную добавляться в push path.

## Тесты

### Unit-тесты Coordinator

`LexickonTests/Navigation/CoordinatorTransitionTests.swift` проверяет:

- таблицу path transitions каждого child Coordinator;
- отсутствие duplicate destinations и `popTo`-семантику `pushUnique`;
- установку sheet и full-screen state;
- изменение выбранной вкладки;
- преобразование child results в App root transitions;
- освобождение завершённого child Coordinator;
- очистку path вместе с освобождённым flow;
- идемпотентность повторного root Step;
- неизменность `rootRevision` при повторном запросе активного root.

### UI-тесты root replacement

`LexickonUITests/LexickonUITests.swift` проверяет полный placeholder-сценарий:

```text
Authentication → Dataset Setup → Main → Logout → Authentication
```

После logout тест дополнительно проверяет:

- отсутствие Main root;
- отсутствие кнопки Back;
- невозможность вернуться в Main жестом swipe right.

## Как расширять навигацию

### Добавление push destination в существующий flow

Пример для нового Auth destination `.resetPassword`.

1. Добавить case в `AuthStep`:

   ```swift
   case resetPassword
   ```

2. Сопоставить его с path в `AuthCoordinator.handle(_:)`:

   ```swift
   case .resetPassword:
       path.pushUnique(.resetPassword)
   ```

3. Добавить View в `AuthCoordinatorView.destination(for:)`:

   ```swift
   case .resetPassword:
       ResetPasswordView(...)
   ```

4. Передавать `.resetPassword` из UI или feature output в Coordinator.
5. Добавить transition case в `CoordinatorTransitionTests`.

### Добавление sheet

1. Добавить semantic Step, например `.terms`.
2. Добавить `.terms` в `AuthSheet`.
3. В `handle(_:)` установить `sheet = .terms`.
4. Добавить новый case в `.sheet(item:)` switch CoordinatorView.
5. Закрывать sheet установкой `sheet = nil` либо системным dismiss.
6. Проверить presentation state unit-тестом.

Step и modal enum остаются разными типами: Step является командой, а modal enum
является текущим presentation state.

### Добавление full-screen cover

Последовательность такая же, как для sheet, но используется отдельный
`*FullScreenCover` enum и `.fullScreenCover(item:)`.

### Добавление вкладки Main

1. Добавить case в `MainTab`.
2. Добавить tab content и `.tag(...)` в `MainCoordinatorView`.
3. При необходимости добавить Step для программного выбора tab.
4. Обработать Step присваиванием `selectedTab`.
5. Добавить тест выбранной вкладки.

Добавление вкладки само по себе не создаёт отдельный navigation path: текущий
Main flow использует один stack для всего `TabView`.

### Добавление нового root flow

Новый root flow требует согласованного изменения нескольких уровней:

1. Создать `FeatureStep`, `FeatureCoordinatorResult` и modal state types.
2. Создать `FeatureCoordinator` и `FeatureCoordinatorView`.
3. Добавить case в `AppRoot`.
4. Добавить semantic command в `AppStep`.
5. Добавить optional child property в `AppCoordinator`.
6. Обновить `handle(_ step: AppStep)`.
7. Обновить `replaceRoot(with:)`, `activeChildExists(for:)` и
   `releaseChildren()`.
8. Если flow завершается, добавить typed result overload в `AppCoordinator`.
9. Добавить ветку в `AppCoordinatorView`.
10. Добавить unit-тесты создания, перехода и освобождения child.
11. Добавить UI-тест невозможности вернуться в завершённый root flow.

## Текущие ограничения

Документируемые ограничения важны, чтобы существующий scaffolding не принимался
за уже реализованную универсальную navigation-инфраструктуру:

- экраны flows пока являются placeholders;
- deep links не реализованы;
- восстановление navigation path после перезапуска не реализовано;
- нет отдельного Router;
- Step одновременно служит командой и типом push destination;
- modal states представлены отдельными optional и не взаимоисключаются;
- Main tabs используют один общий path, а не независимые stacks;
- нет очереди последовательных modal presentations;
- нет отдельной политики анимации root replacement;
- root при запуске всегда начинается с Authentication, session bootstrap ещё не
  выбирает начальный flow.

При изменении любого из этих ограничений этот README должен обновляться вместе
с кодом и тестами.

## Карта исходников и тестов

- [`Core/Coordinator.swift`](Core/Coordinator.swift) — базовые протоколы и
  `pushUnique`.
- [`App/AppStep.swift`](App/AppStep.swift) — App commands и root state.
- [`App/AppCoordinator.swift`](App/AppCoordinator.swift) — root lifecycle и
  child ownership.
- [`App/AppCoordinatorView.swift`](App/AppCoordinatorView.swift) — отображение
  активного root.
- [`Authentication/AuthStep.swift`](Authentication/AuthStep.swift) — vocabulary
  Authentication flow.
- [`Authentication/AuthCoordinator.swift`](Authentication/AuthCoordinator.swift)
  — таблица Auth transitions.
- [`Authentication/AuthCoordinatorView.swift`](Authentication/AuthCoordinatorView.swift)
  — SwiftUI rendering Auth navigation.
- [`DatasetSetup/DatasetSetupStep.swift`](DatasetSetup/DatasetSetupStep.swift) —
  vocabulary Dataset Setup flow.
- [`DatasetSetup/DatasetSetupCoordinator.swift`](DatasetSetup/DatasetSetupCoordinator.swift)
  — таблица Dataset Setup transitions.
- [`DatasetSetup/DatasetSetupCoordinatorView.swift`](DatasetSetup/DatasetSetupCoordinatorView.swift)
  — SwiftUI rendering Dataset Setup navigation.
- [`Main/MainStep.swift`](Main/MainStep.swift) — vocabulary Main flow.
- [`Main/MainCoordinator.swift`](Main/MainCoordinator.swift) — таблица Main
  transitions и tab selection.
- [`Main/MainCoordinatorView.swift`](Main/MainCoordinatorView.swift) — Main
  `NavigationStack`, `TabView` и modal rendering.
- [`Views/NavigationPlaceholderScreen.swift`](Views/NavigationPlaceholderScreen.swift)
  — общий placeholder UI.
- [`../App/LexickonApp.swift`](../App/LexickonApp.swift) — точка создания
  `AppCoordinator`.
- [`../../LexickonTests/Navigation/CoordinatorTransitionTests.swift`](../../LexickonTests/Navigation/CoordinatorTransitionTests.swift)
  — unit-тесты navigation state transitions.
- [`../../LexickonUITests/LexickonUITests.swift`](../../LexickonUITests/LexickonUITests.swift)
  — UI-тесты root flow replacement.
