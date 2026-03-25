---
name: onboarding
description: Interactive first-use guidance pattern for skills that require user decisions before operation. Covers the distinction between installation, onboarding, and configuration; detection-first approach (auto-discover before asking); when to use vs skip; and the detect → ask → confirm → write flow.
---

# Onboarding

Interactive first-use guidance that helps users set up their environment for a skill.

## Execution Procedure

```
assess_and_guide(skill_scope) → onboarded | skipped

if zero-config needed → skipped
if config missing → trigger first-use flow:
    detect what can be auto-discovered (gh api, platform roots)
    ask only what can't be detected
    summarize detected + collected → confirm once (HITL)
    write config file → onboarded
```

## TOC

- [What Onboarding Is](#what-onboarding-is)
- [When to Use](#when-to-use)
- [When NOT to Use](#when-not-to-use)
- [Relationship with Installation and Configuration](#relationship-with-installation-and-configuration)
- [Onboarding Can Include](#onboarding-can-include)
- [Detection: When to Trigger](#detection-when-to-trigger)
- [Guidelines](#guidelines)
- [Examples](#examples)
- [Cross-References](#cross-references)

## What Onboarding Is

Onboarding is the **user-facing, interactive experience** when someone uses a skill for the first time. It orients the user, collects necessary input, and ensures the skill is ready to deliver value.

| Layer | Nature | Example |
|-------|--------|---------|
| **Installation** | Automated, no user input | `scripts/setup.sh` installs tools and skills |
| **Onboarding** | Interactive, user participates | Set Chrome profile, configure GitHub org, walk through features |
| **Configuration** | Data layer, persisted | `~/.config/<skill-name>/config.md` |

Onboarding may trigger Installation steps (e.g., "you need gh CLI — installing now") and may create Configuration files (e.g., "saving your GitHub org to config"). But it is a distinct concept: **the user experience of getting started.**

## When to Use

A skill needs onboarding when:

- First-time setup requires **user decisions** (which Chrome profile? which GitHub org?)
- The skill needs **credentials or tokens** the user must provide
- There's a **learning curve** that a guided walkthrough reduces
- The skill's value isn't obvious without a **quick demo or orientation**

## When NOT to Use

- Skill is zero-config — works immediately with no user input
- All setup is automated (handled entirely by `scripts/setup.sh`)
- Skill is pure methodology — reading instructions IS the onboarding

## Relationship with Installation and Configuration

```
Step 0 flow:

  1. Run scripts/setup.sh        ← Installation (automated)
  2. First use?                   ← Onboarding trigger
     Yes → run onboarding flow
     No  → skip to step 3
  3. Check config exists          ← Configuration (data)
     Missing → create with defaults (or onboarding already created it)
  4. Proceed to Step 1
```

**Key distinctions:**

| | Installation | Onboarding | Configuration |
|---|---|---|---|
| Runs when | Every invocation | First use (or config missing) | Every invocation (read) |
| User input | None | Yes — decisions, credentials | None (already saved) |
| Automated | Fully | Partially — guided but interactive | Fully |
| Defined in | `scripts/setup.sh` | SKILL.md Step 0 instructions | `~/.config/<skill-name>/config.md` |
| Reference | `installation.md` | This file | `skill-configuration.md` |

## Onboarding Can Include

| Activity | Example |
|----------|---------|
| **Profile selection** | Playwright: "Which Chrome profile should I use?" |
| **Account configuration** | GitHub skill: "What's your default org?" → detect via `gh api user` |
| **Credential setup** | Figma skill: "Create an API token at figma.com/settings → paste here" |
| **Feature walkthrough** | Complex skill: "Here's what I can do — want a quick demo?" |
| **Preference collection** | "Default verbosity: minimal or detailed?" |

## Detection: When to Trigger

Onboarding triggers when the skill detects it hasn't been set up for this user:

```
Onboarding needed?
  1. Config file exists at ~/.config/<skill-name>/config.md? → No onboarding
  2. Config missing → run onboarding, then create config
```

The config file doubles as the onboarding-complete marker. No separate "setup_done" flag needed.

## Guidelines

- **Detect first, ask second** — auto-discover what you can (`gh api user`, platform detection, directory scanning), only ask what you can't detect
- **One confirmation** — present a summary of detected + collected values, confirm once, write config
- **Don't interrogate** — 3+ sequential questions feels like a form. Bundle into one summary
- **Onboarding is not a tutorial** — orient the user, don't lecture. They'll learn by using
- **Idempotent** — if config gets deleted, onboarding re-triggers naturally (config missing → onboard again)

## Examples

### Playwright skill onboarding

```
First use detected (no config at ~/.config/playwright-cli/config.md).

Scanning Chrome profiles...
  - Default (Jack) — last used 2h ago
  - Profile 1 (Leslie J.) — last used 3d ago
  - Profile 14 (Work) — last used 1d ago

Which profile should I use by default? [Default]
> Default

Saving to ~/.config/playwright-cli/config.md:
  chrome_profile: Default

Ready. Use `--pw-profile="Work"` to override per-session.
```

### skill-forge onboarding

```
First use detected (no config at ~/.config/skill-forge/config.md).

Detecting defaults...
  - GitHub org: motiful (from gh api user)
  - License: MIT (default)

Where should new skills live? [~/skills/]
> [Enter]

Config:
  - skill_workspace: ~/skills/
  - github_org: motiful
  - license: MIT

Saving to ~/.config/skill-forge/config.md...
```

## Cross-References

- `installation.md` — automated dependency installation (runs before onboarding)
- `skill-configuration.md` — config file format, location, litmus test
