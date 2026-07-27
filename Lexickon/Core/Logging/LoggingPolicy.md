# Logging policy

- Use `AppLogger` categories instead of `print`.
- Never log access or refresh tokens, passwords, authorization headers, complete
  request/response bodies, or user-entered content.
- Treat identifiers and personal data as private. Prefer counts, durations,
  state names, and sanitized error categories.
- Use `.debug` for development diagnostics, `.info` for significant lifecycle
  transitions, and `.error` for actionable failures.
- A release build must remain useful without enabling private-data collection.
