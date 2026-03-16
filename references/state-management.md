# State Management

Most skills are stateless instruction packages and do not need this pattern. This reference is for the rare skill that genuinely needs to persist data across sessions (e.g., skill-forge stores its own config and published-skills registry).

**Important:** State management is NOT a universal skill capability. It's an implementation detail for specific skills. Do not bake this into generated skills unless the skill's own requirements demand it.

## When a Skill Needs Persistent Data

- The skill has user preferences that cannot be auto-discovered every run (e.g., `github_org`, `skill_root`)
- The skill maintains a registry or history that accumulates over time
- The skill needs to know "did this happen before?" to avoid redundant work

## Storage Convention

```
~/.config/<skill-name>/
├── config.md          # preferences, settings
└── state.md           # dynamic data (registries, history)
```

Platform-agnostic — outside any agent's directory.

- `config.md` — relatively stable preferences
- `state.md` — data that changes over time (registries, histories, caches)

## Config vs State

These two files serve different purposes. The litmus test from `quality-principles.md`:

> If you delete the config file, does the skill still work (just with defaults)? If yes — it's config. If no — you've crossed the line into infrastructure.

| | Config (`config.md`) | State (`state.md`) |
|---|---|---|
| **Examples** | `github_org: motiful`, `license: MIT` | published skills registry, operation history |
| **Changes** | Rarely (user edits deliberately) | Frequently (updated by skill operations) |
| **If deleted** | Skill works with defaults, recreates on next run | Accumulated data lost, skill still functions |
| **Who writes** | User or skill (first-run init only) | Skill (every operation) |

For the full configuration pattern (location, format, first-run initialization), see `skill-configuration.md`.

## Guidelines

- Each skill owns its own `~/.config/<skill-name>/` directory
- Skills never write to each other's state
- A skill may READ shared configs (e.g., skill-forge config for `github_org`) but never WRITE to them
- Default to gitignored locations for private/personal state
- Use markdown format (AI-native) unless complex structure demands JSON

## Cross-References

- `quality-principles.md` — the litmus test for config vs infrastructure
- `skill-configuration.md` — full configuration pattern (location, format, guidelines)
