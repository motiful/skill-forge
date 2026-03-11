# State Management Pattern

Persistent state across sessions — preferences, history, registries. Unlike initialization (one-time), state evolves on every invocation. A skill can have either without the other.

## Storage Format

**Markdown** (default): AI agents read markdown natively. Human-readable, easy to inspect and edit manually. Best for preferences, simple registries, text-based state.

**JSON** (optional): Better for structured data — arrays of items, nested configs, data that other tools might parse programmatically. Use when the state has complex structure that markdown tables can't cleanly express.

The skill decides which format fits its data. Both are equally readable by AI agents.

## Storage Location

### Global State

```
~/.config/<skill-name>/
├── config.md          # preferences, settings
└── state.md           # dynamic state (registries, history)
```

Platform-agnostic — outside any agent's directory.

**Boundary rule:** `config.md` is for relatively stable preferences and settings. `state.md` is for forge-managed or runtime-managed data that changes over time: registries, histories, caches, last-run data, and similar evolving records.

Do not store mutable registries or histories in `config.md` just because they are human-readable markdown. If the data is owned by the skill at runtime and will keep changing, it belongs in `state.md` (or the JSON equivalent if structure demands it).

**Example split:** Skill Forge keeps `skill_root`, `github_org`, and `license` in `config.md`, and records its "Published Skills" registry in `state.md`.

### Project-Level State

When a skill needs per-project configuration:

**Team-shared state** (conventions, project rules that teammates should see):
- Store in a platform-agnostic location within the project, tracked in git
- Example: `<project>/.skill-config/<skill-name>/config.md`
- The skill documents that this file should be committed

**Personal/private state** (local paths, personal preferences):
- Store in the platform's config directory, gitignored
- Example: `<project>/.claude/config/<skill-name>.md` (CC), `<project>/.cursor/config/<skill-name>.md` (Cursor)
- These directories are typically already gitignored

**If the skill isn't sure** → default to gitignored (safety first). It's easier to share later than to un-share accidentally committed private config.

The skill's documentation must declare which state is shared and which is private.

### Project Identification

When using project-level state in `~/.config/`, identify projects by their root directory name or a stable hash of the path. The skill detects the current project from the working directory.

## Mutual Non-Interference

Each skill owns its own `~/.config/<skill-name>/` directory. Skills never write to each other's state. A skill may READ shared configs (e.g., skill-forge config for `github_org`) but never WRITE to them.
