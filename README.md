# Lexickon

## BMAD

The repository tracks BMAD project knowledge, planning artifacts, and shared
configuration, but not the installer-generated skill and IDE integration
files.

Tracked BMAD content:

- `AGENTS.md` — repository-wide instructions for coding agents.
- `_bmad/config.toml` — shared installer configuration.
- `_bmad/custom/` — team customizations and templates. Files ending in
  `.user.toml` are personal and ignored.
- `_bmad-output/` — briefs, research, specifications, architecture, stories,
  and other project artifacts.

The current BMAD version is `6.12.0`. To restore or update the local
installation, run from the repository root:

```sh
npx bmad-method@6.12.0 install
```

For a fresh non-interactive installation matching the current module and tool
selection, use:

```sh
npx bmad-method@6.12.0 install --yes --modules bmm --tools opencode,claude-code
```

The generated `.agents/`, `.opencode/`, `.claude/skills/bmad-*`, and installer-owned `_bmad/`
subdirectories remain local and are excluded from Git. After installation,
invoke `bmad-help` to verify that the integration is available. In Claude Code
the BMAD skills are available as slash commands (for example `/bmad-help`,
`/bmad-agent-pm`, `/bmad-build`). Claude Code reads `AGENTS.md` directly (v2.1.277+),
so no `CLAUDE.md` is needed.
