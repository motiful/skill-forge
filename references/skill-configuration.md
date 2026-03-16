# Skill Configuration

Optional engineering pattern: giving a skill user-adjustable preferences that persist across sessions.

## When to Use

Include a configuration pattern when the skill has preferences that:

- Cannot be auto-discovered every run (e.g., `github_org`, `skill_root`)
- Should persist across sessions (e.g., `license: MIT`, `verbosity: minimal`)
- Have sensible defaults but users may want to change them

## When NOT to Use

- Skill is pure methodology with no user-adjustable behavior
- All parameters can be auto-detected from the environment every run
- The skill runs once and doesn't need to remember anything

## Location Convention

```
~/.config/<skill-name>/
├── config.md          # user preferences (stable)
└── state.md           # dynamic data (see state-management.md)
```

Platform-agnostic — outside any agent's directory. Each skill owns its own `~/.config/<skill-name>/` directory.

## Config File Format

Markdown with sections. Example from skill-forge itself:

```markdown
# Skill Forge Config

## Defaults

- skill_root: ~/skills/
- github_org: motiful
- license: MIT
```

Keep it flat and readable. Use markdown format (AI-native) unless complex structure demands JSON.

## The Litmus Test

From `quality-principles.md`:

> If you delete the config file, does the skill still work (just with defaults)? If yes — it's config. If no — you've crossed the line into infrastructure.

Config makes a skill convenient. Config should never make a skill required. A skill without its config file must still complete its job using built-in defaults.

## First-Run Initialization

When config is not found, the skill should:

1. **Detect** — auto-discover sensible defaults (`gh api user -q .login` for GitHub org, platform detection for paths)
2. **Summarize** — show the user exactly what will be written and where
3. **Confirm once** — ask for approval before writing
4. **Write** — create the config file

Don't interrogate the user with multiple questions. Detect what you can, present a single summary, confirm once.

This check naturally fits inside the skill's Step 0 alongside precondition checks. See `precondition-checks.md` for how Step 0 handles both concerns.

## Guidelines

- Config is optional — most skills don't need it
- The skill must work without config (using defaults)
- Prefer auto-detection over asking the user
- Don't interrogate — detect, summarize, confirm
- Use `config.md` for stable preferences, `state.md` for dynamic data (see `state-management.md`)
- Skills never write to each other's config

## Cross-References

- `quality-principles.md` — the litmus test for config vs infrastructure
- `state-management.md` — config vs state distinction, storage convention
- `precondition-checks.md` — first-run initialization as part of Step 0
