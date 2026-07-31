# Navigation

Navigation uses a Step-Driven Coordinator hierarchy on `MainActor`.

- `AppCoordinator` owns the active root flow and replaces it instead of pushing
  a new root onto a shared stack.
- `AuthCoordinator`, `DatasetSetupCoordinator`, and `MainCoordinator` accept
  only their own typed `Step` values.
- Child coordinators emit typed results. They never reference `AppStep` or their
  parent coordinator.
- Each child owns its `NavigationStack` path and modal presentation state.
  `MainCoordinator` additionally owns the selected tab.
- Repeating an active destination reuses it or pops back to its existing path
  position; it never appends a duplicate.
- Root replacement releases the completed child coordinator and its navigation
  state, preventing a system back gesture from reopening the finished flow.

Coordinators contain navigation state only. Network, session, Keychain, SQLite,
and product operations remain in use cases and repositories.
