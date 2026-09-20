<!-- bmad:context -->
<!-- Verified 2026-09-20 against 30302a62ef2ff4fd2945f2ded745e6bb9d72cf56. Managed by bmad-project-context; edits inside this block are replaced on refresh. Keep anything you want preserved outside the markers. -->

## Lexickon

Lexickon is a monorepo containing a Python/FastAPI backend and a native Swift iOS client; a native Android client is planned but not present yet. Backend architecture and API contracts live in `backend/docs/`. iOS architecture rules live in the focused READMEs under `apps/ios/Lexickon/` and the implementation plan in `apps/ios/docs/`.

## Policy

- In `apps/ios`, log through `AppLogger`, never `print`; never log tokens, passwords, authorization headers, request/response bodies, signed URLs, user-entered content, or personal identifiers.

## Where things are

- Backend ASGI entry point: `backend/app/main.py`; development runbook: `backend/docs/development_runbook.md`
- iOS entry point: `apps/ios/Lexickon/App/LexickonApp.swift`; project configuration: `apps/ios/Configurations/`
- `apps/android/` is planned but absent at this revision; do not assume a Gradle layout or commands before it is scaffolded.
- Changing an HTTP or dataset contract? Start with `backend/docs/api_contract.md`, then inspect the matching backend schemas/tests and iOS request, DTO, mapping, and repository tests.

## Running and verifying

- There is no root task runner or checked-in CI; run the component commands below from the repository root.
- Prepare the backend with Python 3.12+: `make -C backend install`.
- Verify the backend with `make -C backend test`, then `cd backend && .venv/bin/ruff check .`; tests use in-memory SQLite and fake storage, so PostgreSQL, MinIO, and Docker are not required.
- Run the local backend stack with `make -C backend dev`; `make -C backend db-down` stops the entire Compose stack, including PostgreSQL and MinIO.
- The backend has no established artifact-build, formatter, or type-check command; do not invent one.
- Build iOS Debug with `make -C apps/ios build`; build Release with `make -C apps/ios build CONFIGURATION=Release`.
- Verify iOS with `make -C apps/ios lint`, `make -C apps/ios test`, or `make -C apps/ios check`; `check` runs lint plus both unit and UI tests.
- iOS tests default to the latest `iPhone 17 Pro` simulator; when unavailable, use `make -C apps/ios test SIMULATOR='Exact Available Name'`.
- Preserve the declared Swift 6 strict-concurrency and iOS 26 deployment settings.
- TODO after the native Android project and wrapper are committed: verify and record its build, unit-test, device-test, lint, and formatting commands.

## Conventions that differ from defaults

- Keep backend dataset generation outside this repository: the backend receives ready `.sqlite.gz` packs and manages metadata, authorization, and signed download URLs.
- Treat published dataset objects as immutable and PostgreSQL as the metadata source of truth; mobile clients must verify SHA-256 before installing a pack.
- Keep backend response schemas, `backend/docs/api_contract.md`, and iOS requests/DTO mappings/tests synchronized in the same change.
- In `apps/ios`, keep Domain free of UI and infrastructure dependencies; Data maps wire DTOs to Domain, and Presentation accesses data only through Domain use cases. See `LexickonTests/Architecture/DomainArchitectureTests.swift`.
- Assemble iOS dependencies manually under `App/DependencyInjection/`; pass `UseCases` to UI code, not repositories, API clients, or dependency containers.
- Preserve the Step-Driven Coordinator flow documented in `apps/ios/Lexickon/Presentation/README.md`; Views do not invoke coordinators directly.

## Known pitfalls

- iOS Debug uses local API URLs, while Release deliberately points to `https://api.lexickon.invalid`; confirm production configuration before testing Release networking.
- Do not rely on `apps/ios/buildServer.json` until it is regenerated; it contains an obsolete absolute path from the pre-monorepo workspace.

<!-- /bmad:context -->
