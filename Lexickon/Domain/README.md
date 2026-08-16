# Domain

Domain contains product concepts and application rules. It has no dependency on
Presentation or infrastructure.

## Structure

- `Entities` contains domain objects with a stable product identity or meaning,
  such as `User`, `Dataset`, and `FrequencyResult`.
- `ValueObjects` contains small immutable domain values, identifiers, and
  classifications, such as `UserID`, `DatasetKey`, and `UserSettings`.
- `UseCases/<Feature>` contains feature operations and their input/output models.
  Requests such as `LoginRequest`, `DatasetSyncRequest`, and `FrequencyQuery`
  describe a use-case contract, not a transport payload.
- `Repositories` contains the protocols required by use cases.
- `Errors` contains typed application errors shared across feature boundaries.

Domain types are not API DTOs and must not mirror JSON merely for decoding
convenience. Transport DTOs belong in `Data/API/DTO`; Data maps them explicitly:

`API DTO -> Data mapper -> Domain entity/value/use-case model`

## Dependency direction checklist

- `Presentation` may depend on Domain use cases and entities.
- `Data` may depend on and implement Domain repository protocols.
- Domain entities and value objects do not depend on Data DTOs.
- Domain must not import `SwiftUI`, `UIKit`, `Security`, or `SQLite3`.
- Domain must not reference `URLSession`, Keychain, SQLite records, API DTOs, or
  feature ViewModels.
- Values crossing concurrency boundaries conform to `Sendable`.
- Repository implementations own synchronization; Domain protocols do not
  force work onto `MainActor`.
- Infrastructure errors are normalized to `AppError` before leaving Data.

The frequency metric identifier remains opaque until the SQLite query and metric
contracts are finalized.
