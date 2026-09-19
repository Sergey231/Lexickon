# Auth repository

Эта директория содержит реализацию `AuthRepository` и transport-модели
authentication API. Код здесь соединяет Domain-сценарии авторизации с
`APIClient` и `SessionController`.

## Файлы

- `AuthRepositoryImpl.swift` — production-реализация Domain-контракта,
  управление auth flow и преобразование инфраструктурных ошибок в `AppError`;
- `AuthAPIRequests.swift` — типизированные API-запросы, request/response DTO и
  преобразование user DTO в Domain-модели.

## Поток данных

```text
Auth use case
      ↓
AuthRepository
      ↑ implements
AuthRepositoryImpl
      ├── APIClient
      └── SessionController
              └── TokenStore
```

`AuthRepositoryImpl` не хранит токен самостоятельно. Владельцем токена в памяти
является `SessionController`, а способ постоянного хранения скрыт за
`TokenStore`.

## Сценарии

### Registration

`register(_:)` отправляет credentials в `/auth/register`, преобразует
`UserProfileDTO` в `User` и не создаёт локальную сессию.

### Login

`login(_:)` отправляет credentials в `/auth/login`, проверяет полученный access
token через `AccessToken` и передаёт его в `SessionController`. Успешный вход
возвращает `.signedIn`.

### Logout

`logout()` очищает локальную сессию через `SessionController`. Backend logout
endpoint сейчас не вызывается.

### Authentication state

`authenticationState()` восстанавливает token из хранилища, если это требуется,
и проверяет потенциально валидную сессию запросом `/me`. Отсутствующий,
повреждённый или отклонённый token приводит к `.signedOut`.

## Ошибки

Репозиторий не выпускает `NetworkError` и `TokenStoreError` за границу Data.
Они преобразуются в `AppError` с учётом сценария:

- неверные credentials — `.authorization(.invalidCredentials)`;
- конфликт аккаунта — `.authorization(.accountConflict)`;
- истёкшая или отклонённая сессия — `.authorization(.sessionExpired)`;
- отсутствие сети и timeout — соответствующие transport errors;
- ошибка чтения или записи token — соответствующая local-storage error;
- неизвестная инфраструктурная ошибка — `.unexpected(.invariantViolation)`.

## Правила безопасности

- Password, access token, request body и authorization headers нельзя
  логировать.
- `AuthTokenDTO` и остальные DTO не должны выходить из слоя Data.
- Репозиторий не обращается к Keychain напрямую.
- Bearer token добавляет только `APIClient` для запросов с authorization policy.
- Значение access token проверяется до передачи в `SessionController`.

## Тестирование

`AuthRepositoryImplTests` проверяет URL и body запросов, сохранение и удаление
token, восстановление сессии и mapping ошибок. HTTP перехватывается через
`URLProtocolStub`, поэтому запущенный backend не требуется.
