# Migration Plan: DI Migration to Pure FactoryKit Registrations

This companion documents the technical sequence for migrating from manual assembly structs to pure FactoryKit declarative registrations. It is derived from the capabilities and stories in the source epic.

## Phase 1: Foundation Registrations (Config & Infrastructure)

Register base configuration and infrastructure dependencies as Factory singletons.

- `httpTransport` — URLSession-based transport, singleton
- `apiBaseURL` — Environment-derived base URL, singleton
- `tokenStore` — Secure token storage, singleton

**Verification**: Each registration compiles; `Container.shared.httpTransport()` resolves without crash.

## Phase 2: DataSource Registrations

Migrate DataSource layer from `DataSourcesAssembly` into `Container+Registrations`.

| Dependency | Scope | Rationale |
|------------|-------|-----------|
| `SessionController` | `cached` | Factory default; no mutable state held at this layer |
| `APIClient` | `cached` | Default Factory scope; safe for stateless HTTP client |
| `SessionRefreshing` | `cached` | Depends on SessionController; refreshed per resolution |
| `InstalledDatasetRegistry` | `cached` | Reads from disk; cached acceptable |

**Steps**:
1. Add each as `var x: Factory<Type> { self { ... } }` in `Container+Registrations`
2. Wire dependencies (e.g., `APIClient` needs `baseURL`, `transport`, `session`)
3. Remove corresponding creation logic from `DataSourcesAssembly`
4. Run `make -C apps/ios test` — confirm no regressions

## Phase 3: Repository Registrations

Migrate Repository layer from `RepositoriesAssembly` into `Container+Registrations`.

| Repository | Scope | Notes |
|------------|-------|-------|
| `AuthRepository` | `cached` | DEBUG/UITest override via `#if DEBUG \|\| UITEST` |
| `UserRepository` | `cached` | |
| `DatasetCatalogRepository` | `cached` | |
| `InstalledDatasetRepository` | `cached` | |
| `FrequencyRepository` | `cached` | |

**Steps**:
1. Add each repository as Factory registration with `.cached()` scope (explicit)
2. Preserve `UITestAuthRepository` for DEBUG/UITest builds
3. **Remove** `UnavailableXRepository` stubs (decided: delete entirely)
4. Remove corresponding creation logic from `RepositoriesAssembly`
5. Run `make -C apps/ios test`

## Phase 4: UseCase Registrations

Register all UseCases with their repository dependencies.

| UseCase | Dependencies |
|---------|-------------|
| `AuthUseCase` | `AuthRepository` |
| `UserUseCase` | `UserRepository` |
| `DatasetCatalogUseCase` | `DatasetCatalogRepository` |
| `InstalledDatasetUseCase` | `InstalledDatasetRepository` |
| `FrequencyUseCase` | `FrequencyRepository` |

**Steps**:
1. Add each UseCase as Factory registration
2. Wire repository dependencies through Factory closure parameters
3. Run `make -C apps/ios test`

## Phase 5: Delete Manual Assembly Structs

Remove the now-obsolete manual assembly files.

**Files to delete**:
- `apps/ios/Lexickon/App/DependencyInjection/DataSourcesAssembly.swift`
- `apps/ios/Lexickon/App/DependencyInjection/RepositoriesAssembly.swift`
- `apps/ios/Lexickon/App/DependencyInjection/AppInfrastructure.swift` (if no external references)

**Steps**:
1. Search codebase for imports/references to these files
2. Delete files
3. Run `make -C apps/ios build` — confirm clean compile
4. Run `make -C apps/ios test`

## Phase 6: Simplify ProductionAssembly & TestAssembly

### ProductionAssembly
- `makeContainer()` → only config overrides: `httpTransport`, `apiBaseURL`, `tokenStore`
- Remove all DataSource/Repository/UseCase registrations

### TestAssembly
- `makeGraph()` → use `Container.shared` + `FactoryTesting` scopes
- Leverage `Container.shared.reset()` in `setUp()` / `tearDown()`
- Use `FactoryTesting` scoped registrations for test doubles

**Steps**:
1. Refactor both assemblies
2. Run full test suite: `make -C apps/ios check`

## Phase 7: Full Verification

Execute the canonical verification command:

```bash
make -C apps/ios check
```

**Expected outcome**:
- `lint` passes (ruff/swiftlint)
- `test` passes (unit + UI tests)
- Debug build succeeds
- Release build succeeds (points to `https://api.lexickon.invalid`)

## Dependency Graph Overview (Post-Migration)

```
Container+Registrations
├── Config (singleton)
│   ├── httpTransport
│   ├── apiBaseURL
│   └── tokenStore
├── DataSources (cached)
│   ├── SessionController (cached) ← tokenStore
│   ├── APIClient (cached) ← baseURL, transport, session
│   ├── SessionRefreshing (cached) ← SessionController
│   └── InstalledDatasetRegistry (cached)
├── Repositories (cached)
│   ├── AuthRepository ← APIClient, SessionController
│   ├── UserRepository ← APIClient
│   ├── DatasetCatalogRepository ← APIClient
│   ├── InstalledDatasetRepository ← APIClient, InstalledDatasetRegistry
│   └── FrequencyRepository ← APIClient
└── UseCases (cached)
    ├── AuthUseCase ← AuthRepository
    ├── UserUseCase ← UserRepository
    ├── DatasetCatalogUseCase ← DatasetCatalogRepository
    ├── InstalledDatasetUseCase ← InstalledDatasetRepository
    └── FrequencyUseCase ← FrequencyRepository
```

## Risk Mitigations (from Source)

| Risk | Mitigation |
|------|------------|
| Test breakage | Migrate incrementally; run tests after each phase |
| Scope mistakes (singleton vs cached) | All scopes explicitly declared in SPEC.md Decisions; verified by scope audit script |
| Circular deps | Factory detects at runtime; review graph before merge; config → DataSources → Repositories → UseCases is strictly layered |

## Open Questions — **ALL RESOLVED**

1. **Repository scopes:** All `.cached()` (default), SessionController and InstalledDatasetRegistry also `.cached()` (decided in SPEC.md)
2. **Config scopes:** `httpTransport`, `apiBaseURL`, `tokenStore` remain `.singleton()` (decided in SPEC.md)
3. **UnavailableXRepository:** Remove entirely (decided in SPEC.md)
4. **AppInfrastructure.swift references:** Zero external references (grep verified)
5. **Circular dependencies:** No cycles found in Container+Registrations (layered graph)