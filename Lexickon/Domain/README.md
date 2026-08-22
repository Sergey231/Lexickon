# Domain

Domain содержит продуктовые понятия и правила приложения. Он не зависит от
Presentation или инфраструктуры.

## Структура

- `Entities` содержит доменные объекты со стабильной продуктовой идентичностью
  или смыслом, например `User`, `Dataset` и `FrequencyResult`.
- `ValueObjects` содержит небольшие неизменяемые значения, идентификаторы и
  классификации, например `UserID`, `DatasetKey` и `UserSettings`.
- `UseCases/<Feature>` содержит операции сценариев и их input/output модели.
  Запросы вроде `LoginRequest`, `DatasetSyncRequest` и `FrequencyQuery`
  описывают контракт use case, а не transport payload.
- `Repositories` содержит протоколы, которые нужны use case.
- `Errors` содержит типизированные ошибки приложения, общие для разных
  сценариев.

Domain-типы не являются API DTO и не должны повторять JSON только ради удобного
декодирования. Transport DTO находятся в `Data/API/DTO`; Data явно преобразует
их:

`API DTO -> Data mapper -> Domain entity/value/use-case model`

## Проверка направлений зависимостей

- `Presentation` может зависеть от Domain use case и entities.
- `Data` может зависеть от протоколов Domain repository и реализовывать их.
- Domain entities и value objects не зависят от Data DTO.
- Domain не должен импортировать `SwiftUI`, `UIKit`, `Security` или `SQLite3`.
- Domain не должен ссылаться на `URLSession`, Keychain, SQLite records, API DTO
  или feature ViewModel.
- Значения, которые пересекают concurrency boundaries, соответствуют `Sendable`.
- Реализации репозиториев сами отвечают за синхронизацию; Domain-протоколы не
  принуждают выполнять работу на `MainActor`.
- Инфраструктурные ошибки нормализуются в `AppError` до выхода из Data.

Идентификатор frequency metric остаётся opaque, пока не финализированы контракты
SQLite query и metric.
