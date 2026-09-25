---
id: SPEC-ios-presentation-di-refactor
companions: []
sources: []
---

> **Canonical contract.** This SPEC and the files in `companions:` are the complete, preservation-validated contract for what to build, test, and validate. Source documents listed in frontmatter are for traceability — consult them only if you need narrative rationale or prose color this contract intentionally omits.

# iOS Presentation DI Refactor: Remove UseCases Environment, Use FactoryKit at Composition Boundary

## Why

The current iOS Presentation layer passes a `UseCases` aggregate through SwiftUI `Environment`, creating a global container dependency that leaks into Coordinator Views and makes View Models difficult to test in isolation. This refactor eliminates the Environment-based DI, restricts FactoryKit to Coordinator Views as the sole composition boundary, and enforces constructor injection for View Models — preserving testability while removing the global `Container.shared` and `UseCases` aggregate from the Presentation layer.

## Capabilities

- **CAP-1**
  - **intent:** Coordinator Views resolve individual Use Cases via FactoryKit `@Injected` at the UI composition boundary
  - **success:** All Coordinator Views use `@Injected(\.someUseCase)` for each needed Use Case; no Coordinator View references `EnvironmentValues.useCases` or a `UseCases` aggregate

- **CAP-2**
  - **intent:** View Models receive Use Cases exclusively through constructor injection (`init`)
  - **success:** Every View Model declares Use Cases as `init` parameters; zero View Models use `@Injected`, `Container.shared`, or any FactoryKit API

- **CAP-3**
  - **intent:** Regular SwiftUI Views have zero knowledge of FactoryKit or DI infrastructure
  - **success:** No non-Coordinator View imports FactoryKit, references `@Injected`, `Container`, or any DI type

- **CAP-4**
  - **intent:** Domain and Data layers remain independent of FactoryKit
  - **success:** Zero imports of FactoryKit in Domain or Data modules; no FactoryKit types appear in their public interfaces

- **CAP-5**
  - **intent:** UseCases aggregate and AppContainer are removed if no longer referenced after migration
  - **success:** `UseCases` struct and `AppContainer` class are deleted from codebase; `ProductionAssembly.makeContainer()` renamed or removed accordingly

- **CAP-6**
  - **intent:** Stateless Use Cases registered with `.unique` scope in FactoryKit
  - **success:** All stateless Use Case registrations in `ProductionAssembly` (or equivalent) declare `.unique` scope; DI tests verify scope behavior

- **CAP-7**
  - **intent:** DI tests validate new FactoryKit structure and architectural constraints
  - **success:** Test suite covers: `@Injected` only in Coordinator Views, constructor injection in View Models, absence of `EnvironmentValues.useCases`, absence of `UseCases` aggregate and `AppContainer`

## Constraints

- Coordinator Views receive individual Use Cases via `@Injected(\.someUseCase)`, never an aggregate
- View Models receive Use Cases exclusively through `init` parameters; no `@Injected`, no `Container.shared`
- Regular SwiftUI Views must not know about FactoryKit or any DI infrastructure
- Domain and Data layers must not depend on FactoryKit
- Repositories, APIClient, and Container must never be passed to Views or View Models
- Existing app behavior preserved; no changes to repository or Use Case APIs
- Repository scopes unchanged in this refactor
- `@Injected` allowed only in Coordinator Views (architectural rule enforced by tests)
- View Models accept Use Cases only through `init` parameters (architectural rule enforced by tests)
- No `EnvironmentValues.useCases` exists in project after refactor (architectural rule enforced by tests)
- UseCases aggregate and AppContainer must be absent if no longer needed (architectural rule enforced by tests)

## Non-goals

- Changing repository or Use Case APIs
- Changing repository scopes or lifecycles
- Introducing new DI frameworks or patterns beyond FactoryKit
- Modifying Domain or Data layer implementations
- Adding feature functionality — purely structural refactor

## Success signal

All verification commands pass: `make -C apps/ios lint`, `make -C apps/ios test`, `make -C apps/ios build`, `make -C apps/ios build CONFIGURATION=Release`, `make -C apps/ios check`. Zero references to `EnvironmentValues.useCases`, `UseCases` aggregate, `AppContainer`, or FactoryKit outside Coordinator Views. All View Models testable with plain constructor-injected Use Case mocks.

## Assumptions

- FactoryKit is already integrated and functional in the iOS project
- Current `ProductionAssembly` or equivalent exists and registers Use Cases
- Coordinator Views are identifiable as the UI composition boundary (per existing architecture docs)
- View Models currently receive Use Cases via `init` (constructor injection already established)
- No View Model currently uses `@Injected` or `Container.shared`
- No Coordinator View passes `UseCases` aggregate to children; they read from Environment and pass individual Use Cases to View Model `init`
- `ProductionAssembly.makeContainer()` used by `LexickonApp` and `AppContainerTests.testProductionAssemblyUsesRemoteAuthAdapter()`
- Tests depend on `AppContainer` and `UseCases` aggregate; `TestAssembly` constructs `AppContainer`, `AppContainerTests` exercises `container.useCases`; these must be refactored to resolve individual FactoryKit registrations

## Incremental Verification

After each Coordinator View migration, run `make -C apps/ios lint && make -C apps/ios test` to catch regressions. After all migrations complete, run full `make -C apps/ios check`.