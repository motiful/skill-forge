# State Management Pattern

## What It Is

Persistent state across sessions. A skill may need to remember preferences, track history, or maintain registries between invocations. State evolves over the skill's lifetime — unlike initialization which runs once.

## Relationship to Initialization

| | Initialization | State Management |
|---|---|---|
| **When** | Once (first use) | Ongoing |
| **Direction** | Write initial values | Read + write + update |
| **Trigger** | Config file absent | Every invocation |

A skill can have either without the other:
- Initialization without state management → one-time setup, then auto-discovers each time
- State management without initialization → creates state on demand, no onboarding needed

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
