---
title: 'DI Migration to Pure FactoryKit Registrations'
type: 'refactor'
created: '2026-09-24'
status: 'done'
route: 'dispatch'
review_loop_iteration: 0
baseline_commit: '2db90f0f1cf91a35031a27429517025063b05f13'
context:
  - 'apps/ios/docs/epic-di-migration.md'
  - 'apps/ios/Lexickon/Presentation/README.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Current iOS dependency injection uses manual `DataSourcesAssembly` / `RepositoriesAssembly` structs called from Factory closures. This creates maintenance burden, obscures the dependency graph, prevents FactoryKit scope optimization, and complicates test assembly configuration.

**Approach:** Replace all manual assembly with declarative FactoryKit registrations across the entire dependency graph. Remove `DataSourcesAssembly.swift`, `RepositoriesAssembly.swift`, and `AppInfrastructure.swift`. Simplify `ProductionAssembly.makeContainer()` to only config overrides. Refactor `TestAssembly.makeGraph()` to use `Container.shared` + `FactoryTesting` scopes exclusively.

## Boundaries & Constraints

**Always:**
- iOS architectural rules: Domain free of UI/infrastructure dependencies; Data maps wire DTOs to Domain; Presentation accesses data only through Domain use cases
- Dependencies assembled manually under App/DependencyInjection/; pass UseCases to UI code, not repositories, API clients, or dependency containers
- Preserve Step-Driven Coordinator flow: Views do not invoke coordinators directly
- FactoryKit already integrated via SPM; must use Factory scopes (singleton, cached, new) intentionally per dependency type
- Tests must use Container.shared + FactoryTesting only; no custom test assemblies with manual wiring
- `make -C apps/ios check` must pass (lint + unit tests + UI tests)
- DEBUG/UITest conditional for AuthRepository must work via `#if DEBUG || UITEST`
- No regression in Debug/Release builds (Release points to `https://api.lexickon.invalid`)

**Never:**
- Migrate to a different DI framework (FactoryKit stays)
- Change public API contracts of repositories, use cases, or data sources — migration is internal wiring only
- Introduce property-wrapper based injection (@Injected) — FactoryKit closure-based registration pattern is the standard
- Keep manual assembly structs after migration

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| DEBUG build auth | `--uitest-auth-repository` arg present | `UITestAuthRepository` injected | Falls back to `AuthRepositoryImpl` if arg missing |
| RELEASE build auth | No DEBUG flag | `AuthRepositoryImpl` injected | N/A |
| DEBUG device build | DEBUG=1, targetEnvironment(simulator)=false | `AuthRepositoryImpl` with device API URL | N/A |
| RELEASE with arg | RELEASE build, `--uitest-auth-repository` present | `AuthRepositoryImpl` injected (DEBUG=false) | N/A |
| Test setup | `TestAssembly.makeGraph()` called with stubs | All repositories resolve to provided stubs | N/A |
| Test re-entry | `makeGraph()` called twice without `reset()` | Second call overwrites registrations cleanly | N/A |
| Test teardown | `TestAssembly.reset()` called | Container fully reset for next test | N/A |
| Reset during resolution | `reset()` called while Factory closure executing | Undefined; avoid by design (reset only in setUp/tearDown) | Design-time prevention |
| Circular dependency | Factory detects cycle at runtime | Crash on resolution with clear error + cycle path | Review graph before merge |
| Transitive cycle | A→B→C→A through UseCases→Repos→DataSources→Config | Crash with full cycle path in error message | Automated cycle detection in CI |
| Parallel test reset | Two tests call `Container.shared.reset()` concurrently | Race condition; tests must run serially | Document serial test requirement |
| Config override precedence | ProductionAssembly overrides apiBaseURL/httpTransport | Overrides take precedence over Container defaults | N/A |
| Missing registration | Resolve type not registered in Container | FactoryKit throws clear "not registered" error | Add registration before resolution |
| Protocol witness mismatch | Factory closure returns wrong protocol type | Compile-time error (Swift type safety) | N/A |

## Decisions (resolved during planning)

- **Repository scopes:** All `.cached()` (default). `SessionController`, all repositories, and `InstalledDatasetRegistry` remain `.cached()` per decision.
- **Config scopes:** `httpTransport`, `apiBaseURL`, `tokenStore` remain `.singleton()`. Config is truly global; tests use `Container.shared.reset()`.
- **UnavailableXRepository placeholders:** Remove entirely. Replace `UseCases.unavailable` static property with concrete unavailable implementations that don't reference deleted types (e.g., inline closures returning `UnavailableRepository()` protocol witnesses).

</frozen-after-approval>

## Code Map

- `apps/ios/Lexickon/App/DependencyInjection/Container+Registrations.swift` -- All Factory registrations (167 lines); source of truth for dependency graph; contains `dataSourcesAssembly` and `repositoriesAssembly` to remove
- `apps/ios/Lexickon/App/DependencyInjection/DataSourcesAssembly.swift` -- Manual assembly struct for data sources; DELETE in Phase 3
- `apps/ios/Lexickon/App/DependencyInjection/RepositoriesAssembly.swift` -- Manual assembly struct for repositories; DELETE in Phase 3
- `apps/ios/Lexickon/App/DependencyInjection/AppInfrastructure.swift` -- Config + `AppInfrastructure` struct; DELETE `AppInfrastructure` in Phase 3, keep `AppConfiguration` enum
- `apps/ios/Lexickon/App/DependencyInjection/ProductionAssembly.swift` -- Simplify `makeContainer()` to only config overrides (baseURL, transport)
- `apps/ios/Lexickon/App/DependencyInjection/UseCases.swift` -- UseCases struct + EnvironmentKey; keep, update `unavailable` if UnavailableX removed
- `apps/ios/Lexickon/App/DependencyInjection/AppContainer.swift` -- Composition root output; keep both init() and test init(useCases:)
- `apps/ios/Lexickon/App/DependencyInjection/UITestAuthRepository.swift` -- Test double for AuthRepository; keep, referenced by Container+Registrations
- `apps/ios/LexickonTests/DependencyInjection/TestAssembly.swift` -- Refactor to use Container.shared + FactoryTesting scopes; remove manual repo registrations
- `apps/ios/LexickonTests/DependencyInjection/AppContainerTests.swift` -- Integration test verifying full graph; must pass after migration; ADD singleton identity assertions
- `apps/ios/Lexickon/App/LexickonApp.swift` -- App entry point; calls `ProductionAssembly.makeContainer()`; unchanged
- `migration-plan.md` -- 7-phase migration plan with dependency graph; Phase 3 updated to .cached() for all repos

## Tasks & Acceptance

**Execution — Phase Tasks (from migration-plan.md):**

- [x] `apps/ios/Lexickon/App/DependencyInjection/Container+Registrations.swift` -- Add explicit `.cached()` to `sessionController`, `authRepository`, `userRepository`, `datasetCatalogRepository`, `installedDatasetRepository`, `frequencyRepository`, `apiClient`, `sessionRefresher`, `datasetRegistry`, `installedDatasetRegistry` registrations -- RATIONALE: All repositories, SessionController, and DataSources are cached (Factory default); explicit scopes prevent accidents
- [x] `apps/ios/Lexickon/App/DependencyInjection/Container+Registrations.swift` -- Remove `dataSourcesAssembly` and `repositoriesAssembly` Factory registrations (lines 45-55, 88-98) -- RATIONALE: Replaced by declarative registrations; grep confirms no external references
- [x] `apps/ios/Lexickon/App/DependencyInjection/Container+Registrations.swift` -- Verify all 20+ registrations have explicit scope (`.singleton()`, `.cached()`, or `.new()`) -- RATIONALE: Prevents accidental default scope; enforce via script in verification
- [x] `apps/ios/Lexickon/App/DependencyInjection/DataSourcesAssembly.swift` -- DELETE file -- RATIONALE: Replaced by declarative Factory registrations
- [x] `apps/ios/Lexickon/App/DependencyInjection/RepositoriesAssembly.swift` -- DELETE file -- RATIONALE: Replaced by declarative Factory registrations
- [x] `apps/ios/Lexickon/App/DependencyInjection/AppInfrastructure.swift` -- DELETE `AppInfrastructure` struct; KEEP `AppConfiguration` enum -- RATIONALE: No external references (grep verified); config enum still used
- [x] `apps/ios/Lexickon/App/DependencyInjection/ProductionAssembly.swift` -- Simplify `makeContainer()` to only register `apiBaseURL` and `httpTransport`; tokenStore uses singleton default (KeychainTokenStore); tests override via TestAssembly -- RATIONALE: Config-only overrides per spec; tokenStore is singleton but tests override with InMemoryTokenStore
- [x] `apps/ios/Lexickon/App/DependencyInjection/UseCases.swift` -- Replace `UseCases.unavailable` static property to use inline unavailable implementations (protocol witnesses via closures) instead of UnavailableXRepository types -- RATIONALE: UnavailableX types deleted; UseCases.unavailable must still compile
- [x] `apps/ios/LexickonTests/DependencyInjection/TestAssembly.swift` -- Refactor `makeGraph()` to use `FactoryTesting.register { stub }` for all repositories; add `Container.shared.reset()` in `setUp()`/`tearDown()` (create BaseTestCase) -- RATIONALE: Pure FactoryKit test setup per spec; enables test isolation
- [x] `apps/ios/Lexickon/App/DependencyInjection/UITestAuthRepository.swift` -- Keep unchanged; verify DEBUG/UITest conditional works in Factory registration -- RATIONALE: Test double preserved

**Execution — Verification Tasks:**

- [x] Add `testCachedScope()` to `AppContainerTests.swift` (or new DI test file): resolve `sessionController`, each repository (Auth, User, DatasetCatalog, InstalledDataset, Frequency), `apiClient`, and `installedDatasetRegistry` twice → assert `!==` (different instances) -- RATIONALE: Verifies cached scope for all DataSources and repositories
- [x] Add `testFactoryTestingIsolation()`: `TestAssembly.makeGraph()` with stubs → verify stubs injected; `TestAssembly.reset()` → verify clean container on next call -- RATIONALE: Verifies FactoryTesting adoption works
- [x] Grep verification: `grep -r "DataSourcesAssembly\|RepositoriesAssembly\|AppInfrastructure" --include="*.swift" apps/ios/` returns zero results -- RATIONALE: Confirms no references to deleted types remain
- [x] Scope verification script: parse `Container+Registrations.swift` and assert every registration has explicit scope call -- RATIONALE: Prevents missing `.singleton()`/`.cached()` regressions

**Execution — Build Verification:**

- [x] Verify `make -C apps/ios check` passes (lint + unit tests + UI tests) -- RATIONALE: Canonical verification command
- [x] Verify Debug build succeeds and Release build succeeds (points to `https://api.lexickon.invalid`) -- RATIONALE: No regression in builds

**Acceptance Criteria:**

- **AC1 (Build):** Given clean repo, when running `make -C apps/ios check`, then all lint, unit tests, and UI tests pass
- **AC2a (Cached SessionController):** Given Debug build, when resolving `sessionController` twice, then resolutions return different instances (`!==`)
- **AC2b (Cached Repositories):** Given Debug build, when resolving each repository (Auth, User, DatasetCatalog, InstalledDataset, Frequency) twice, then resolutions return different instances (`!==`)
- **AC2c (APIClient Cached):** Given Debug build, when resolving `apiClient` twice, then resolutions return different instances (`!==`)
- **AC2d (InstalledDatasetRegistry Cached):** Given Debug build, when resolving `installedDatasetRegistry` twice, then resolutions return different instances (`!==`)
- **AC2e (Assembly Removal):** Given Debug build, when searching codebase for `DataSourcesAssembly`, `RepositoriesAssembly`, `AppInfrastructure`, then zero references found
- **AC3 (Test Stubs):** Given test run, when `TestAssembly.makeGraph()` called with stubs, then all repositories resolve to provided stubs via `FactoryTesting` scopes; `TestAssembly.reset()` clears container for next test
- **AC4 (Release Config):** Given Release build, when checking `AppConfiguration.apiBaseURL`, then it equals `https://api.lexickon.invalid`

## Design Notes

Migration follows 7 phases from `migration-plan.md` (Phase 3 updated to `.cached()` for all repos):

1. Foundation registrations (config & infrastructure) — already mostly in Container+Registrations
2. DataSource registrations — `sessionController` as `.cached()`; `apiClient` as `.cached()`; add `sessionRefresher`, `datasetRegistry` as `.cached()`
3. Repository registrations — wire all repos directly with `.cached()` scope; preserve DEBUG/UITest AuthRepository override inline
4. UseCase registrations — already complete in Container+Registrations
5. Delete manual assembly structs — DataSourcesAssembly, RepositoriesAssembly, AppInfrastructure (struct only; grep confirms zero external references)
6. Simplify ProductionAssembly & TestAssembly — config-only overrides; FactoryTesting in tests
7. Full verification — `make -C apps/ios check` + migration-specific verification (singleton identity, FactoryTesting, scope audit)

Key insight: Current Container+Registrations already has most registrations but delegates to manual assemblies for construction. The migration removes the assembly layer and makes scopes explicit.

Circular dependency review: Container+Registrations.swift shows no cycles — config → DataSources → Repositories → UseCases is strictly layered.

All registrations use `.cached()` scope (Factory default) — stateless repositories (Auth, User, DatasetCatalog, InstalledDataset, Frequency), DataSources (APIClient, SessionController, SessionRefreshing, InstalledDatasetRegistry), and UseCases don't hold mutable state; Config (httpTransport, apiBaseURL, tokenStore) remains `.singleton()`.

## Verification

**Automated (run in CI / local):**

- `make -C apps/ios lint` -- expected: exits 0 (swiftlint)
- `make -C apps/ios test` -- expected: all unit + UI tests pass (includes new cached/FactoryTesting tests)
- `make -C apps/ios build` -- expected: Debug build succeeds
- `make -C apps/ios build CONFIGURATION=Release` -- expected: Release build succeeds
- `make -C apps/ios check` -- expected: all of above pass (canonical verification)
- `grep -r "DataSourcesAssembly\|RepositoriesAssembly\|AppInfrastructure" --include="*.swift" apps/ios/` -- expected: zero results
- Scope audit script: verify every registration in Container+Registrations.swift has explicit `.singleton()`/`.cached()`/`.new()`

**Manual:**

- Verify DependencyInjection folder contains only: AppContainer.swift, Container+Registrations.swift, UseCases.swift, ProductionAssembly.swift, UITestAuthRepository.swift
- Verify no imports of deleted files remain in `apps/ios/`
- Verify `sessionController`, all 5 repositories, `apiClient`, and `installedDatasetRegistry` use `.cached()` scope explicitly in Container+Registrations.swift
- Verify Release build network requests target `https://api.lexickon.invalid` (mock transport or network capture)