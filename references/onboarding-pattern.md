# First-Use Onboarding Pattern

One-time setup flow on first invocation. Config file (`~/.config/<skill-name>/config.md`) is the **initialization marker** — exists means "onboarding complete."

## Detection Mechanism

```
~/.config/<skill-name>/config.md exists?
├── Found    → read stored preferences, proceed normally
└── Not found → run onboarding flow, create config when done
```

## What Onboarding Can Include

Depends entirely on the skill. Examples:

- **Preference gathering** — ask user for defaults the skill can't guess (e.g., preferred org name, default license, output format)
- **Dependency check** — verify external tools the skill needs are installed (e.g., `gh` CLI for GitHub operations)
- **Directory setup** — create working directories, register paths
- **Recommended skill discovery** — check if related skills are installed, mention them if not (soft, once)
- **First-use guidance** — explain what the skill does and suggest a first action

No fixed time limit or question count — each skill determines what its onboarding needs. The flow runs once; after that the config exists and the skill proceeds directly.

## When to Include

Include onboarding when the skill needs information it **cannot auto-discover from the project context or runtime environment**:

- User preferences that have no discoverable default (e.g., "which GitHub org?")
- External tool dependencies that need verification (e.g., "is `gh` installed?")
- Complex workflows where a first-use walkthrough prevents confusion

## When NOT to Include

- Skill auto-discovers everything from project files (e.g., self-review scans for anchors — no setup needed)
- Skill is pure methodology with no persistent state (e.g., rules-as-skills — just read and apply)
- Skill is a constraint/rule — just needs to be loaded, not configured
- Information is available from the runtime environment (agent platform, OS, working directory — don't ask what the agent already knows)

## Reusing Existing Configs

If the new skill could reuse values from an existing config (e.g., `~/.config/skill-forge/config.md` has `github_org` and `platforms`), read that config instead of re-asking. Don't make users repeat themselves across skills.
