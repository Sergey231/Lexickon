# Lexickon iOS Client: план разработки MVP

## Статус документа

Документ фиксирует согласованный технический план iOS-клиента Lexickon. План
описывает архитектуру, навигацию, MVP UX, управление зависимостями, работу с
локальными датасетами и последовательность реализации.

## Цели MVP

iOS-клиент должен:

- зарегистрировать и авторизовать пользователя;
- получить профиль и пользовательские настройки;
- выбрать, скачать, проверить и установить SQLite-датасеты;
- определять частотность слова или фразы по локально установленному датасету;
- показывать и изменять настройки профиля;
- работать с установленными датасетами без запроса их содержимого к API.

Backend является control plane: он отвечает за авторизацию, профиль, настройки,
каталог датасетов, синхронизацию версий и временные ссылки на скачивание.
Содержимое датасетов клиент читает локально из immutable SQLite-паков.

## Принятые технические решения

- UI: SwiftUI.
- Минимальная версия: iOS 26.
- Асинхронность: Swift Concurrency (`async/await`, `Task`, actors).
- Наблюдаемое UI-состояние: Observation (`@Observable`).
- Навигация: иерархический Step-Driven Coordinator.
- Ресурсы: Asset Catalog и встроенная генерация Swift-символов Xcode.
- SwiftGen, R.swift и аналогичные генераторы ресурсов не используются.
- Сеть: `URLSession` с типизированным API client.
- Токен авторизации: Keychain.
- Локальные данные частотности: SQLite-паки, устанавливаемые приложением.
- DI: ручной Composition Root (`AppContainer`), без внешнего DI-фреймворка.

## Архитектура

### Выбранный подход

Используем pragmatic Clean Architecture с feature-oriented Presentation layer.
Архитектура сохраняет разделение бизнес-правил, внешних источников данных и UI,
но не разбивает MVP на большое количество framework-таргетов.

На старте достаточно трех таргетов:

- `LexickonApp`;
- `LexickonTests`;
- `LexickonUITests`.

Выделение features в отдельные Swift Package или framework-таргеты выполняется
только при появлении независимых команд, отдельных release cycles или заметного
роста времени сборки.

### Слои

```text
App
  Composition Root
  App lifecycle
  AppCoordinator

Navigation
  Coordinator protocols
  Steps
  Coordinator results

Domain
  Entities
  Repository protocols
  Use cases

Data
  API client and DTO
  Repository implementations
  Keychain storage
  Dataset manifest and sync
  Dataset downloader and installer
  Local SQLite access

Features
  Auth
  DatasetSetup
  Frequency
  Profile

Core
  Errors
  Logging
  Design system
  Shared utilities

Resources
  Assets.xcassets
  Localizable.xcstrings
```

### Направление зависимостей

```text
Features/Presentation -> Domain <- Data
              App/Composition Root
                      |
            связывает реализации
```

- Domain не зависит от SwiftUI, URLSession, Keychain или SQLite.
- Data реализует repository protocols, объявленные на границе Domain.
- View и ViewModel не работают напрямую с DTO и сетевым клиентом.
- Coordinator относится к Presentation и не содержит бизнес-правил.
- `Core` не используется как неограниченная папка для случайного общего кода.

### Основные зависимости

На уровне Domain потребуются как минимум:

- `AuthRepository`;
- `UserRepository`;
- `DatasetRepository`;
- `FrequencyRepository`;
- use cases для регистрации, логина, загрузки профиля, изменения настроек,
  синхронизации датасетов и определения частотности.

DTO API и Domain-модели должны быть раздельными. Преобразование выполняется в
Data layer.

## Навигация

### Выбранный вариант Coordinator

Используем иерархический Step-Driven Coordinator. Каждый Coordinator принимает
типизированный `Step`, который описывает следующее навигационное действие в
сценарии.

```swift
protocol CoordinatorStep {}

@MainActor
protocol Coordinator: AnyObject {
    associatedtype Step: CoordinatorStep

    func navigate(to step: Step)
}
```

Все Step-типы имеют одинаковую семантическую роль:

```swift
enum AppStep: CoordinatorStep { /* ... */ }
enum AuthStep: CoordinatorStep { /* ... */ }
enum DatasetSetupStep: CoordinatorStep { /* ... */ }
enum MainStep: CoordinatorStep { /* ... */ }
```

Step может:

- показать или закрыть экран;
- выполнить push, pop, sheet, full-screen presentation или замену root;
- запустить дочерний Coordinator;
- завершить текущий Coordinator;
- вернуть управление родительскому Coordinator;
- инициировать следующий Step родительского Coordinator.

### Иерархия Coordinator

```text
AppCoordinator / AppStep
├── AuthCoordinator / AuthStep
├── DatasetSetupCoordinator / DatasetSetupStep
└── MainCoordinator / MainStep
```

`AppCoordinator` управляет корневыми сценариями приложения:

```swift
enum AppStep: CoordinatorStep {
    case start
    case showAuthentication
    case authenticationCompleted
    case showDatasetSetup
    case datasetSetupCompleted
    case showMain
    case logout
}
```

Названия финальных cases могут быть уточнены при реализации, но их роль должна
оставаться одинаковой: каждый case является следующим действием навигации для
соответствующего Coordinator.

### Жизненный цикл дочернего Coordinator

- Родитель создаёт и удерживает дочерний Coordinator.
- Родитель передаёт дочернему Coordinator начальный Step.
- Дочерний Coordinator выполняет собственный сценарий.
- При завершении дочерний Coordinator возвращает типизированный result.
- Родитель освобождает дочерний Coordinator.
- Родитель преобразует result в собственный Step и продолжает сценарий.

Пример результатов авторизации:

```swift
enum AuthCoordinatorResult {
    case authenticated
    case cancelled
}
```

`AuthCoordinator` не должен зависеть от `AppStep`. Связь выполняет
`AppCoordinator`, преобразуя `AuthCoordinatorResult.authenticated` в
`AppStep.authenticationCompleted`.

### Интеграция со SwiftUI

Coordinator работает на `@MainActor` и хранит наблюдаемое presentation state:

- path для `NavigationStack`;
- активный sheet;
- active full-screen cover;
- выбранный tab;
- ссылки на активные дочерние Coordinator.

`NavigationStack.path`, sheet и full-screen cover являются внутренним механизмом
отображения выполненного Step. Step не обязан соответствовать экрану и не должен
безусловно использоваться как элемент path.

При необходимости Coordinator может хранить внутренний тип `Screen` или
`Destination`, предназначенный только для SwiftUI path. Этот тип не заменяет
Step и не участвует в обмене между Coordinator.

Для MVP отдельный Router не вводится. Технические операции с path остаются
внутренней частью Coordinator. Общий untyped Step bus также не используется:
каждый Coordinator принимает собственный строго типизированный Step.

### Ответственность Coordinator

Coordinator отвечает за:

- последовательность экранов и сценариев;
- запуск и завершение дочерних Coordinator;
- преобразование результата дочернего сценария в следующий Step;
- root replacement после авторизации и logout;
- обработку внешних navigation intents и deep links, когда они появятся.

Coordinator не отвечает за:

- сетевые запросы;
- валидацию бизнес-правил;
- хранение токенов;
- чтение SQLite;
- скачивание и установку датасетов;
- вычисление частотности.

Эти операции выполняют use cases и repositories. Coordinator получает
результат операции и принимает только навигационное решение.

## MVP UX

### Общий сценарий запуска

```text
Launch
  -> восстановление локальной сессии
  -> Authentication, если сессии нет или она недействительна
  -> Dataset Setup, если обязательный датасет не установлен
  -> Main
```

Переходы между Authentication, Dataset Setup и Main выполняются заменой
корневого flow. Пользователь не должен возвращаться свайпом назад из Main к
логину или первичной настройке.

### Регистрация и логин

Authentication Flow включает:

- экран логина;
- экран регистрации;
- состояния loading, validation error и API error;
- сохранение access token в Keychain после успешного логина;
- восстановление сессии при следующем запуске;
- очистку токена и пользовательского состояния при logout.

MVP использует email и пароль. Восстановление пароля, Sign in with Apple и
социальная авторизация не входят в текущий API-контракт.

Текущий backend-контракт возвращает пользователя после регистрации и access
token после логина. Поэтому после успешной регистрации клиент возвращает
пользователя к логину, если backend-контракт не будет расширен.

### Первичная настройка датасета

Dataset Setup Flow включает:

- выбор предпочитаемого языка;
- выбор доступных доменов;
- отображение размера скачивания;
- учёт настройки `sync_over_cellular`;
- состояния download, checksum verification, installation, ready и error;
- retry после сетевой ошибки или ошибки установки;
- переход в Main только после установки датасета, необходимого для поиска.

Сценарий установки:

```text
Manifest
  -> Sync decision
  -> Signed download URL
  -> Download to temporary location
  -> SHA-256 verification
  -> Decompression to staging location
  -> SQLite/schema validation
  -> Atomic installation
  -> Local installed-dataset metadata update
```

Повреждённый, неподходящий по schema version или не прошедший checksum pack не
должен заменять рабочую локальную версию.

### Определение частотности

Для MVP основной экран Frequency объединяет ввод запроса и результат. Это
ускоряет повторный поиск и не создаёт обязательный push на каждый запрос.

Экран содержит:

- поле ввода слова или фразы;
- действие запуска поиска;
- loading state;
- найденное значение частотности;
- единицу или способ нормализации метрики;
- язык, домен и версию использованного датасета;
- состояния empty query, not found, dataset unavailable и incompatible dataset;
- переход к управлению датасетами, если нужный pack отсутствует.

Поиск выполняется локально через `FrequencyRepository`. UI и ViewModel не
работают с SQLite напрямую.

История запросов, избранное, сравнение слов, графики и расширенная аналитика не
входят в первый MVP.

### Профиль

Main содержит как минимум две вкладки:

- Frequency;
- Profile.

Profile показывает:

- email пользователя;
- `preferred_language`;
- `selected_domains`;
- `offline_mode`;
- `sync_over_cellular`;
- установленные датасеты и их версии;
- наличие доступных обновлений;
- действие ручной синхронизации;
- logout.

Изменение серверных настроек выполняется через `PATCH /me/settings`. Локальное
состояние обновляется только после успешного ответа либо использует явно
описанную optimistic-update стратегию с rollback.

## Dependency Injection

### Решение

Внешний DI-контейнер для MVP не используется. Зависимости собираются вручную в
`AppContainer`, который является Composition Root приложения.

```swift
@MainActor
final class AppContainer {
    let apiClient: APIClient
    let tokenStore: TokenStore
    let authRepository: AuthRepository
    let userRepository: UserRepository
    let datasetRepository: DatasetRepository
    let frequencyRepository: FrequencyRepository
}
```

Конкретный состав контейнера уточняется по мере реализации. Feature types
получают зависимости через initializer injection. `AppContainer` не передаётся
вниз как глобальный service locator.

Ручной Composition Root нужен для:

- централизованной сборки production-зависимостей;
- управления lifetime shared-сервисов;
- подмены repositories и use cases в тестах;
- создания Coordinator и ViewModel с явными зависимостями;
- исключения глобальных singleton.

Swinject, Needle, Resolver и аналогичные решения не добавляются. Возвращение к
этому решению оправдано только при значительном росте dependency graph,
появлении нескольких конфигураций приложения или независимых feature-модулей.

## Swift Concurrency

- Coordinator и UI-bound ViewModel работают на `@MainActor`.
- Сетевой слой использует async API `URLSession`.
- Изменяемое shared state изолируется actor'ами.
- Dataset download/install и SQLite access не выполняются на MainActor.
- Прогресс скачивания и установки передаётся в UI через безопасный
  concurrency-aware интерфейс.
- Длительные операции поддерживают cancellation.
- Неструктурированный `Task.detached` не используется без доказанной
  необходимости.
- Типы, пересекающие isolation boundaries, должны быть `Sendable` либо иметь
  явную actor isolation.
- Ошибки преобразуются в типизированные Domain/Presentation errors до показа UI.

Кандидаты для actor isolation:

- session/token state;
- dataset installer;
- local dataset registry;
- SQLite connection or query executor.

## Assets и локализация

- Изображения, цвета и app icon хранятся в `Assets.xcassets`.
- Используются генерируемые Xcode Swift-символы для asset catalog.
- Генерация asset symbol extensions должна быть включена в build settings.
- Строки интерфейса хранятся в String Catalog (`Localizable.xcstrings`).
- SwiftGen, R.swift и собственная генерация констант не используются.
- Raw string asset names в feature-коде не допускаются, если Xcode может
  предоставить типизированный символ.

## Сеть и безопасность

- API client использует типизированные request/response DTO.
- Bearer access token добавляется централизованным authentication interceptor
  или request builder.
- Access token хранится только в Keychain.
- Пароль не сохраняется.
- Логи не содержат пароль, access token и signed download URL.
- Ошибка авторизации инвалидирует локальную сессию и возвращает управление
  `AppCoordinator` на соответствующий `AppStep`.
- Signed URL используется только для скачивания конкретной версии датасета и
  не сохраняется как постоянная ссылка.

## Локальные датасеты

Клиент хранит отдельно:

- установленный SQLite-файл;
- `dataset_key`;
- data version;
- SQLite schema version;
- checksum;
- дату установки;
- состояние текущего обновления.

Установка должна быть атомарной: рабочий pack заменяется только после скачивания,
проверки checksum, распаковки и проверки совместимости нового файла.

`sync_over_cellular` запрещает автоматическое скачивание по cellular, но не
мешает локальному поиску по уже установленному pack. Поведение `offline_mode`
необходимо согласовать отдельно на уровне продукта и API-контракта.

## Обработка ошибок

Для MVP должны быть определены отдельные пользовательские состояния:

- нет сети;
- неверные credentials;
- истёкшая или недействительная сессия;
- API временно недоступен;
- недостаточно свободного места;
- checksum mismatch;
- неподдерживаемая SQLite schema version;
- датасет revoked или deprecated;
- доступ к датасету запрещён;
- локальная SQLite-база повреждена;
- запрос частотности не найден.

Техническая ошибка логируется, а UI получает понятное действие: retry, login,
dataset selection, update или local fallback.

## Тестирование

### Unit tests

- переходы каждого Coordinator по Step;
- создание и освобождение дочерних Coordinator;
- преобразование child result в Step родителя;
- use cases;
- DTO-to-Domain mapping;
- ViewModel state transitions;
- dataset sync decisions;
- checksum и atomic installation;
- локальные SQLite-запросы на fixture pack.

### Integration tests

- login и авторизованный запрос профиля;
- manifest, sync и download URL;
- загрузка тестового pack;
- проверка, установка и локальный frequency query;
- обработка несовместимой schema version.

### UI smoke tests

```text
Register -> Login -> Dataset Setup -> Frequency Search -> Profile -> Logout
```

Дополнительно проверяются:

- повторный запуск с сохранённой сессией;
- запуск без сети с установленным датасетом;
- ошибка скачивания и retry;
- отсутствие возврата в завершённый root flow через системный back gesture.

## Этапы реализации

1. Создать Xcode project, targets, build settings, Asset Catalog и String
   Catalog.
2. Добавить структуру слоёв, `AppContainer` и базовые test doubles.
3. Реализовать Coordinator protocol, Step types и `AppCoordinator`.
4. Реализовать API client, DTO, обработку ошибок и Keychain token storage.
5. Реализовать Auth Flow: регистрация, логин, session bootstrap и logout.
6. Реализовать manifest/sync repositories и локальный реестр установленных
   датасетов.
7. Реализовать безопасный download, checksum verification, decompression и
   atomic installation.
8. Реализовать Dataset Setup Flow.
9. Реализовать SQLite access layer и `FrequencyRepository`.
10. Реализовать Frequency UX.
11. Реализовать Profile и изменение настроек.
12. Добавить unit, integration и UI smoke tests.
13. Провести end-to-end проверку с локальным FastAPI backend.

## Критерии готовности MVP

- Пользователь может зарегистрироваться и войти.
- Access token безопасно сохраняется и восстанавливается.
- Завершённые root flows не остаются в back stack.
- Coordinator transitions покрыты unit tests.
- Клиент получает manifest и sync actions.
- SQLite-pack скачивается, проверяется и устанавливается атомарно.
- Частотность определяется локально без dataset-content запроса к API.
- Приложение выполняет локальный поиск без сети при наличии установленного pack.
- Настройки профиля читаются и изменяются.
- Cellular download учитывает `sync_over_cellular`.
- Logout очищает пользовательскую сессию и возвращает Authentication Flow.
- Основной smoke-сценарий проходит на iOS 26 simulator.

## Открытые вопросы перед реализацией

1. Зафиксировать SQLite schema и точный SQL-контракт frequency query.
2. Определить смысл метрики частотности, единицы измерения, округление и
   отображаемый источник.
3. Определить обязательный минимальный dataset для входа в Main.
4. Уточнить срок жизни access token и стратегию refresh/повторной авторизации.
5. Зафиксировать продуктовое поведение `offline_mode`.
6. Определить требования к фоновому и возобновляемому скачиванию больших packs.
7. Решить, требуется ли state restoration для navigation path в MVP.

## Связанные документы

- [API contract](api_contract.md)
- [Backend architecture](architecture.md)
- [FastAPI server MVP plan](fastapi_server_mvp_plan.md)
- [Apple: Understanding the navigation stack](https://developer.apple.com/documentation/swiftui/understanding-the-navigation-stack)
- [Apple: Asset management](https://developer.apple.com/documentation/xcode/asset-management)
