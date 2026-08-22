# Сеть и сессия

Инфраструктура этапа 4 находится в `Lexickon/Data`: удалённый источник — в
`DataSources/Remote/API`, Keychain — в `DataSources/Local/Keychain`, управление
состоянием — в `Session`. Граф собирается только в `ProductionAssembly`.

## Выполнение запроса

1. Endpoint реализует `APIRequest` и объявляет тип ответа, HTTP-метод, путь,
   query, дополнительные headers и необходимость Bearer-авторизации.
2. `APIClient` строит URL относительно base URL, кодирует body через
   `JSONEncoder` и централизованно добавляет стандартные headers.
3. Для `.bearer` клиент запрашивает актуальный access token у
   `SessionController`. Без токена запрос не передаётся в transport.
4. `URLSessionTransport` выполняет запрос. Отмена родительского Swift task
   отменяет `URLSessionTask` и возвращается как `NetworkError.cancelled`.
5. `APIClient` декодирует только 2xx. Остальные статусы преобразуются в
   устойчивые случаи `NetworkError`.

Клиент не повторяет запросы автоматически. На 401 он уведомляет
`SessionController`, который удаляет токен из памяти и Keychain и переводит
сессию в `.invalid(.unauthorized)`. После этого клиент возвращает
`.unauthorized` вызывающему репозиторию.

Endpoint не может самостоятельно передать header `Authorization`: такой запрос
отклоняется как `invalidRequest`. Это сохраняет единственную точку добавления
Bearer token и исключает случайное использование устаревшего токена.

## Состояние сессии

`SessionController` — actor и единственный владелец текущего токена в памяти.
Постоянное хранение реализовано через generic-password item в Keychain с
`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.

Результаты `bootstrap()`:

- `.absent` — записи в Keychain нет, состояние `.signedOut`;
- `.potentiallyValid` — токен восстановлен, но backend ещё не подтвердил его;
- `.invalid` — запись повреждена, удалена из Keychain, состояние
  `.invalid(.corruptedToken)`.

Приложение запускает bootstrap при появлении корневого view. Проверка токена
через `/me` появится вместе с продуктовым auth-репозиторием.

## Refresh

Backend-контракт пока не определяет refresh endpoint и формат refresh token.
Эта неопределённость изолирована протоколом `SessionRefreshing`. Текущая
реализация `RefreshNotConfigured` всегда завершает операцию без сетевого retry.
После подтверждения контракта достаточно добавить новую реализацию и заменить
её в `ProductionAssembly`; feature-код менять не потребуется.

## Base URL

Пока домен production API не подтверждён, Debug использует
`http://127.0.0.1:8000`, а Release — зарезервированный нерабочий домен
`https://api.lexickon.invalid`. Подтверждённый URL следует передать в
`ProductionAssembly.makeContainer(baseURL:)` из конфигурации приложения.

## DTO и ошибки

Wire-модели имеют суффикс `DTO` и остаются в
`DataSources/Remote/API/DTO`. Репозитории обязаны преобразовывать response DTO
в модели `Domain` до возврата результата use case.
Presentation не импортирует и не хранит DTO, `APIClient` или `AccessToken`.

Нормализация ошибок:

- cancellation, timeout и отсутствие сети имеют отдельные случаи;
- 400 сохраняет только машинный `code`, если backend его прислал;
- 401 инвалидирует сессию без retry;
- 403 и 404 имеют отдельные случаи;
- 5xx сохраняет status code и необязательный машинный code;
- не-HTTP response и повреждённый успешный JSON различаются как
  `invalidResponse` и `decoding`.

## Безопасное логирование

`NetworkLogMessage` никогда не включает body или значения headers. URL и
описания ошибок дополнительно проходят через `LogRedactor`. В URL целиком
скрывается query, а в произвольном тексте скрываются пароли, Bearer token,
access/refresh token и параметры подписи URL.
`AccessToken.description` и `debugDescription` всегда возвращают
`<redacted>`.

Не следует логировать исходные DTO, `URLRequest`, response body или token store
errors вместе с входными данными пользователя.
