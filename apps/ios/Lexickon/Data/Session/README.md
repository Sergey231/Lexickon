# Session

Папка `Session` содержит модель access token, контракты работы с токеном и
actor, который хранит текущее состояние сессии в памяти.

Она не содержит конкретное защищённое хранилище. Production-хранилище
`KeychainTokenStore` находится в `DataSources/Local/Keychain` и подключается к
`SessionController` через протокол `TokenStore`.

## Состав

- `AccessToken` — value object для access token. Не принимает пустые строки,
  пробелы и управляющие символы. `description` и `debugDescription` всегда
  возвращают `<redacted>`.
- `TokenStore` — протокол для чтения, сохранения и удаления access token.
  Ошибки хранилища описаны в `TokenStoreError`.
- `SessionAuthorizing` — минимальный контракт, который нужен `APIClient`: взять
  текущий bearer token и сообщить о `401 Unauthorized`.
- `SessionRefreshing` — контракт будущей refresh-стратегии. Текущая реализация
  `RefreshNotConfigured` всегда бросает `SessionRefreshError.notConfigured`.
- `SessionController` — actor и единственный владелец текущего токена в памяти.

## Состояние

`SessionController` хранит два значения:

- `token: AccessToken?` — текущий токен в памяти;
- `state: SessionState` — состояние сессии.

Возможные состояния:

- `.signedOut` — токена нет;
- `.potentiallyValid` — токен есть, но backend ещё не подтвердил его;
- `.invalid(.unauthorized)` — backend вернул `401`;
- `.invalid(.corruptedToken)` — сохранённая запись токена повреждена.

## Основные сценарии

### Bootstrap

`bootstrap()` читает токен через `TokenStore`.

- Если записи нет, очищает токен в памяти и возвращает `.absent`.
- Если токен прочитан, кладёт его в память и возвращает `.potentiallyValid`.
- Если хранилище вернуло `TokenStoreError.corrupted`, удаляет запись, очищает
  память и возвращает `.invalid`.

Проверки токена через backend здесь нет. Поэтому восстановленный токен считается
только потенциально валидным.

### Установка сессии

`establishSession(with:)` сохраняет новый access token через `TokenStore`,
кладёт его в память и переводит состояние в `.potentiallyValid`.

### Выход

`signOut()` удаляет token из `TokenStore`, очищает память и переводит состояние
в `.signedOut`.

### 401 Unauthorized

`didReceiveUnauthorized()` вызывается сетевым клиентом после ответа `401`.
Контроллер пытается удалить токен из хранилища, очищает токен в памяти и
переводит сессию в `.invalid(.unauthorized)`.

## Границы ответственности

- `Session` не выполняет HTTP-запросы.
- `Session` не знает о Keychain напрямую.
- `Session` не декодирует DTO и не зависит от backend-моделей.
- `APIClient` получает токен только через `SessionAuthorizing`, а не через
  `TokenStore` напрямую.
