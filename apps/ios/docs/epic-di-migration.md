# Epic: DI Migration to Pure Factory

## Goal
Replace manual `DataSourcesAssembly` / `RepositoriesAssembly` with declarative Factory (FactoryKit) registrations across the dependency graph.

## Scope
- `apps/ios/Lexickon/App/DependencyInjection/`
- Test assemblies in `LexickonTests/DependencyInjection/`

## Current State
- FactoryKit already integrated via SPM
- `Container+Registrations.swift` — 167 lines of Factory registrations
- `DataSourcesAssembly.swift` / `RepositoriesAssembly.swift` — manual structs called from Factory closures
- `ProductionAssembly` / `TestAssembly` configure `Container.shared`

## Target State
- Zero manual assembly structs in `DependencyInjection/`
- All dependencies declared as `var x: Factory<Type> { self { ... } }`
- Scopes (`singleton`, `cached`, `new`) used intentionally
- Tests use `Container.shared` + `FactoryTesting` only
- `ProductionAssembly` only overrides config values (baseURL, transport)

## Features (Planned)

### Feature 1: Migrate DataSources to Factory Registrations
- Move `APIClient`, `SessionController`, `SessionRefreshing`, `InstalledDatasetRegistry` creation into `Container+Registrations`
- Use appropriate scopes (likely `singleton` for `SessionController`, `cached` for `APIClient`)

### Feature 2: Migrate Repositories to Factory Registrations
- Move all repository implementations into `Container+Registrations`
- Preserve DEBUG/UITest override for `AuthRepository`
- Keep `UnavailableXRepository` placeholders for unimplemented domains

### Feature 3: Remove Manual Assembly Structs
- Delete `DataSourcesAssembly.swift`
- Delete `RepositoriesAssembly.swift`
- Delete `AppInfrastructure.swift` (if no longer referenced)

### Feature 4: Simplify ProductionAssembly & TestAssembly
- `ProductionAssembly.makeContainer()` → only registers config overrides
- `TestAssembly.makeGraph()` → uses `Container.shared` + `FactoryTesting` scopes

### Feature 5: Update Tests
- `AppContainerTests` passes with new structure
- All unit/UI tests pass (`make -C apps/ios check`)

## Stories (Backlog)

- [ ] Story: Register `httpTransport`, `apiBaseURL`, `tokenStore` as Factory singletons
- [ ] Story: Register `SessionController` with `tokenStore` dependency
- [ ] Story: Register `APIClient` with `baseURL`, `transport`, `session` dependencies
- [ ] Story: Register `sessionRefresher`, `datasetRegistry` 
- [ ] Story: Register `AuthRepository` with DEBUG/UITest conditional
- [ ] Story: Register remaining repositories (`User`, `DatasetCatalog`, `InstalledDataset`, `Frequency`)
- [ ] Story: Register all UseCases with repository dependencies
- [ ] Story: Delete `DataSourcesAssembly.swift`, `RepositoriesAssembly.swift`, `AppInfrastructure.swift`
- [ ] Story: Simplify `ProductionAssembly` to config-only overrides
- [ ] Story: Refactor `TestAssembly` to use Factory scopes
- [ ] Story: Run full test suite (`make -C apps/ios check`)

## Acceptance Criteria
- [ ] `apps/ios/Lexickon/App/DependencyInjection/` contains only:
  - `AppContainer.swift`
  - `Container+Registrations.swift`
  - `UseCases.swift`
  - `ProductionAssembly.swift`
  - `UITestAuthRepository.swift`
- [ ] No manual assembly structs remain
- [ ] All tests pass: `make -C apps/ios lint && make -C apps/ios test`
- [ ] No regression in Debug/Release builds

## Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| Test breakage | Migrate incrementally, run tests after each Story |
| Scope mistakes (singleton vs cached) | Start with `cached` (default), promote to `singleton` where needed |
| Circular deps | Factory detects at runtime; review graph before merge |

## Related
- FactoryKit docs: https://github.com/hmlongco/Factory
- Current registrations: `Container+Registrations.swift:1`
- Architecture rules: `apps/ios/Lexickon/Presentation/README.md`