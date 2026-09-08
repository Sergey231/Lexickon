# API и сетевой слой Lexickon

Этот файл является точкой входа в документацию удалённого источника данных.
API-инфраструктура находится в `Data/DataSources/Remote/API`, а управление
сессией и локальное хранение токена отделены от неё.

## Слои и зависимости

```text
Presentation
    ↓ Domain use case
Domain repository protocol
    ↓ реализация
Data/Repositories
    ├── DataSources/Remote/API
    │       ├── Client/APIClient
    │       ├── DTO
    │       └── Transport
    └── Session/SessionController
            └── TokenStore
                    └── DataSources/Local/Keychain/KeychainTokenStore

App/DependencyInjection/ProductionAssembly собирает весь граф
```

- `Presentation` работает только с use case и Domain-моделями. Она не видит
  `APIClient`, DTO, `URLSession` и токены.
- `Domain` объявляет протоколы репозиториев и бизнес-модели, но не зависит от
  сети.
- `Data/Repositories` вызывает API и преобразует DTO в Domain-модели. Для ещё
  не подключённых зависимостей используются fail-fast реализации
  `Unavailable...`.
- `Data/DataSources/Remote/API` содержит HTTP-клиент и wire-модели backend.
- `Data/DataSources/Local` содержит локальные источники, включая Keychain и
  будущую базу данных.
- `Data/Session` отвечает за токен и состояние сессии, не завися от конкретного
  способа его хранения.
- `App/DependencyInjection` создаёт production-реализации и связывает их между
  собой.

Зависимость направлена внутрь: инфраструктура знает о контрактах Domain, но
Domain и Presentation не знают об инфраструктуре.

## Сущности `DataSources/Remote/API`

### `APIRequest`

Типизированное описание endpoint. Каждый запрос объявляет:

- `Response` — ожидаемый `Decodable & Sendable` DTO;
- `method` и `path`;
- необязательные `queryItems` и `headers`;
- `authorization`: `.none` или `.bearer`;
- кодирование body через `encodeBody(using:)`.

Значения по умолчанию позволяют не объявлять пустые query, headers и body.
`EmptyResponse` используется для успешных ответов без тела.

### `HTTPMethod`

Поддерживаемые методы: `GET`, `POST`, `PATCH`, `PUT` и `DELETE`.

### `APIClient`

Центральная точка подготовки запроса и декодирования ответа:

1. объединяет `baseURL`, path и query;
2. устанавливает `Accept: application/json`;
3. кодирует body через общий `JSONEncoder`;
4. для `.bearer` получает актуальный токен у `SessionAuthorizing`;
5. передаёт `URLRequest` в `HTTPTransport`;
6. декодирует 2xx общим `JSONDecoder`;
7. преобразует остальные ответы в `NetworkError`.

Encoder и decoder используют ISO 8601 для дат и преобразование между
`camelCase` и `snake_case`. Endpoint не может установить `Authorization`
самостоятельно: такой запрос отклоняется как `invalidRequest`.

### `HTTPTransport` и `URLSessionTransport`

`HTTPTransport` изолирует клиент от конкретного HTTP-движка.
`URLSessionTransport` является production-реализацией и возвращает пару
`(Data, HTTPURLResponse)`. Отмена родительского Swift task доходит до
`URLSessionTask` и нормализуется в `.cancelled`.

В тестах transport перехватывается через `URLProtocolStub`, поэтому запущенный
backend не требуется.

### `NetworkError`

Единый набор сетевых ошибок:

| Источник | Результат |
| --- | --- |
| отмена task | `.cancelled` |
| timeout | `.timedOut` |
| нет сети | `.offline` |
| другая `URLError` | `.transport(code:)` |
| некорректный запрос или response | `.invalidRequest` / `.invalidResponse` |
| повреждённый успешный JSON | `.decoding` |
| нет токена перед отправкой | `.unauthenticated` |
| HTTP 400 | `.badRequest(code:)` |
| HTTP 401 | `.unauthorized` и инвалидация сессии |
| HTTP 403 / 404 | `.forbidden` / `.notFound` |
| HTTP 5xx | `.server(statusCode:code:)` |
| другой статус | `.unexpectedStatus(statusCode:code:)` |

Автоматического retry нет. В частности, 401 обрабатывается один раз и не
запускает повторный запрос.

### `SessionAuthorizing` и `SessionRefreshing`

`SessionAuthorizing` предоставляет `APIClient` актуальный access token и
принимает событие 401. Его реализует `SessionController`.

`SessionRefreshing` изолирует будущую refresh-стратегию. Пока backend-контракт
не определён, используется `RefreshNotConfigured`, который не выполняет
сетевых запросов и бросает `SessionRefreshError.notConfigured`.

### Безопасное логирование

`NetworkLogMessage` формирует диагностическое сообщение без body и значений
headers. `LogRedactor` скрывает:

- Bearer, access и refresh token;
- пароль;
- параметры подписи;
- весь query URL, включая signed URL.

Исходный `URLRequest`, response body и DTO логировать нельзя.

## DTO

Общие transport-модели находятся в `DataSources/Remote/API/DTO`, а модели
конкретного feature — рядом с использующим их репозиторием. Все они имеют
суффикс `DTO`.

`APIErrorDTO` поддерживает несколько форматов backend error body и извлекает
машинный `code`. DTO не должны выходить из Data: репозиторий преобразует
response DTO в Domain-модель, а Domain input — в request DTO.

## Сессия и Keychain

- `AccessToken` не принимает пустые значения, пробелы и управляющие символы;
  его `description` и `debugDescription` всегда равны `<redacted>`.
- `TokenStore` — протокол, который объявляет сохранение, чтение и удаление
  токена.
- `KeychainTokenStore` находится в `DataSources/Local/Keychain` и хранит токен
  как generic-password item с режимом
  `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.
- `SessionController` — actor и единственный владелец токена в памяти.

Результат `SessionController.bootstrap()`:

- `.absent` — токена нет, сессия `.signedOut`;
- `.potentiallyValid` — токен восстановлен, но ещё не подтверждён backend;
- `.invalid` — запись повреждена и удалена из Keychain.

При 401 контроллер удаляет токен из памяти и Keychain и переводит сессию в
`.invalid(.unauthorized)`.

## Сборка графа

`ProductionAssembly` создаёт `DataSourcesAssembly`. Внутри него собираются
`KeychainTokenStore`, `SessionController`, `URLSessionTransport` и `APIClient`,
после чего они объединяются в `AppInfrastructure`. Bootstrap запускается из
корня приложения.

Пока production URL не подтверждён, Debug использует
`http://127.0.0.1:8000`, а Release — намеренно нерабочий
`https://api.lexickon.invalid`. Само наличие base URL не запускает запрос:
сеть вызывается только конкретным репозиторием.

## Как добавить endpoint

1. Добавить request/response DTO в `DataSources/Remote/API/DTO`.
2. Создать тип, реализующий `APIRequest`.
3. В реализации Domain-репозитория вызвать `APIClient.send(_:)`.
4. Преобразовать DTO в Domain-модель до возврата результата.
5. Передать репозиторию `APIClient` через `RepositoriesAssembly`.
6. Добавить тесты URL, headers, body, decoding и mapping ошибок через
   `URLProtocolStub`.
