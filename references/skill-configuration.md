---
name: skill-configuration
description: User preferences pattern for skills that need configurable behavior. Covers config location convention (~/.config/<skill-name>/), the litmus test (delete config → skill rebuilds defaults), stateless skill principle (skill directory is read-only), first-run initialization flow (detect → ask → confirm → write), and boundary between config and infrastructure.
---

# Skill Configuration

Engineering pattern: giving a skill user-adjustable preferences that persist across sessions.

## Execution Procedure

```
assess_config_needs() → config_spec | none

if no user-adjustable behavior → none
location: ~/.config/<skill-name>/config.md
litmus test: delete config → skill rebuilds defaults → still works?
first-run: detect auto-discoverable values → ask remainder → confirm (HITL) → write
skill directory = read-only, config lives outside
```

## TOC

- [When to Use](#when-to-use)
- [When NOT to Use](#when-not-to-use)
- [Boundary Principle: Skill Directory = Read-Only](#boundary-principle-skill-directory--read-only)
- [Location Convention](#location-convention)
- [Config File Format](#config-file-format)
- [The Litmus Test](#the-litmus-test)
- [Skills Are Stateless](#skills-are-stateless)
- [First-Run Initialization](#first-run-initialization)
- [Guidelines](#guidelines)
- [Cross-References](#cross-references)

## When to Use

Include a configuration pattern when the skill has preferences that:

- Cannot be auto-discovered every run (e.g., `github_org`, `skill_workspace`)
- Should persist across sessions (e.g., `license: MIT`, `verbosity: minimal`)
- Have sensible defaults but users may want to change them

## When NOT to Use

- Skill is pure methodology with no user-adjustable behavior
- All parameters can be auto-detected from the environment every run
- The skill runs once and doesn't need to remember anything

## Boundary Principle: Skill Directory = Read-Only

The skill directory (`~/.claude/skills/<name>/`) is a **read-only published artifact**. All runtime data lives outside:

| Data type | Location | Belongs to |
|-----------|----------|------------|
| User preferences / config | `~/.config/<skill-name>/config.md` | Skill's Configuration layer |
| Business data / state | Project directory, database, cloud | User's application, not the skill |
| Runtime cache | `~/.cache/<skill-name>/` or project dir | Temporary, deletable |

**If data is written to the skill directory** (e.g., `.claude/skills/<name>/data/`), it is an abnormal pattern and should trigger a validation warning.

## Location Convention

```
~/.config/<skill-name>/
└── config.md          # user preferences (stable)
```

Platform-agnostic — outside any agent's directory. Each skill owns its own `~/.config/<skill-name>/` directory.

## Config File Format

Markdown with sections. Example from skill-forge itself:

```markdown
# Skill Forge Config

## Defaults

- skill_workspace: ~/skills/
- github_org: motiful
- license: MIT
```

Keep it flat and readable. Use markdown format (AI-native) unless complex structure demands JSON.

## The Litmus Test

> If you delete the config file, can the skill automatically rebuild it with defaults and keep working? If yes — it's config (self-healing). If no — you've crossed the line into infrastructure.

Config makes a skill convenient. A skill without its config file must still complete its job — by recreating the config with built-in defaults and continuing.

## Skills Are Stateless

A skill itself does not have state. The only "state" a skill has is its configuration (data layer).

- Skills **can serve** stateful scenarios (PostgreSQL management, cloud deployment)
- But the skill itself **does not own or manage** that state
- Business data belongs to the user's application, not to the skill
- If a skill needs to track something across runs (e.g., a published-skills registry), that goes in `~/.config/<skill-name>/` as config data, not as "state"

## First-Run Initialization

When config is not found, the skill should:

1. **Detect** — auto-discover sensible defaults (`gh api user -q .login` for GitHub org, platform detection for paths)
2. **Summarize** — show the user exactly what will be written and where
3. **Confirm once** — ask for approval before writing
4. **Write** — create the config file

Don't interrogate the user with multiple questions. Detect what you can, present a single summary, confirm once.

This naturally fits inside the skill's Step 0. See `onboarding.md` for the full first-use experience (onboarding may include config creation as one of its steps).

## Guidelines

- Config is optional — most skills don't need it
- The skill must work without config (recreate with defaults)
- Prefer auto-detection over asking the user
- Don't interrogate — detect, summarize, confirm
- Skills never write to each other's config
- All config lives in `~/.config/<skill-name>/`, never in the skill directory
