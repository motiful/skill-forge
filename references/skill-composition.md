---
name: skill-composition
description: How skills declare dependencies and manage context budget. Covers the context budget constraint (~15K-25K tokens safe), collection risks (context flooding, name collision, unenforced internal deps), publishing model decision (skill vs collection), two dependency tiers (must-install vs informational), and current tooling landscape.
---

```
decide(skill_count, usage_pattern) → composition_strategy

assess context budget: 3-5 active skills ~ 15K-25K tokens safe
if collection 15+ skills → warn context flooding
if all skills auto-activate → critical warning
default: separate repos, dependencies via Step 0 + setup.sh
two tiers only: Dependencies (must install) or Informational (README only)
```

# Skill Composition

How skills declare dependencies, manage context budget, and when multiple skills belong in one repo.

## TOC

- [Why Composition Matters](#why-composition-matters)
- [Context Budget Constraint](#context-budget-constraint)
- [Collection Risks](#collection-risks)
- [Publishing Models](#publishing-models)
- [Dependency Tiers](#dependency-tiers)
- [Current Tooling Landscape](#current-tooling-landscape)

## Why Composition Matters

A single skill solves a single problem. But users face workflows that span multiple skills — and those skills may overlap across product lines. Without composition guidance, skills either become monoliths (cramming everything into one SKILL.md) or isolated silos (each skill reinvents shared logic).

**Current ecosystem state (March 2026):** The Agent Skills spec has no `dependencies` field. Multiple proposals exist but none have been adopted. The spec is deliberately minimal by design.

## Context Budget Constraint

This is what makes skill composition fundamentally different from npm/pip.

Each activated skill consumes context tokens. npm packages load into memory (effectively unlimited); skills load into finite context windows (typically 200K–1M tokens depending on model, shared with user conversation and tool results).

**Practical limits:**
- A typical SKILL.md: 200-500 lines ~ 2K-5K tokens
- References loaded on-demand: 100-200 lines each
- Safe active skill budget: 3-5 skills simultaneously ~ 15K-25K tokens
- Beyond that: skills compete with each other and with the user's task

**Implications for composition:**
- Don't install 20 skills that all auto-activate
- Prefer skills that load on-demand (triggered by specific phrases) over always-active skills
- Future dependency resolvers must be context-budget-aware — this is the differentiator vs npm

## Collection Risks

Large collections (10+ skills) create problems that single skills don't:

### Context flooding

`npx skills add <org>/<collection>` installs ALL skills as flat peers. Each skill's description is always loaded (~100 tokens each). A 50-skill collection burns ~5K tokens on descriptions alone — before any skill body is loaded.

**Why this matters for forge:** Most platforms (2026) cannot disable individual skills after installation — only install/uninstall. Codex has `enabled = false`; Claude Code requires manual deny rules in settings.json. The rest have no toggle. So the README forge generates must guide users to install selectively, because they can't easily turn skills off later.

**What forge should do:**
- Generated README must warn about total skill count and recommend selective install
- Primary install example: `npx skills add <org>/<collection> --skill <name>` (not bare `npx skills add`)
- Group skills by category in README so users can pick what they need
- Step 3: if collection has 15+ skills, warn author and suggest splitting into smaller repos

**Guidance for forge (Step 3 validation):**
- Collection with 15+ skills → warn about context budget
- Collection where all skills auto-activate (no specific triggers) → critical warning

### Name collision

A collection skill named `code-review` will collide with any standalone `code-review` skill the user already has. `npx skills add` overwrites without warning.

**Guidance for collection authors:**
- Namespace skill names: `startup-code-review` instead of `code-review`
- Or accept that generic names will collide and document this in README

### Internal dependencies without enforcement

Collections often have a shared foundation skill (e.g., `startup-context`) that all other skills depend on. Custom frontmatter fields like `reads: [startup-context]` declare this intent but have no installation or runtime enforcement — the AI may or may not read it.

**Guidance for collection authors:**
- If a foundation skill is required, each dependent skill should check for it in its own Step 0
- Or use `scripts/setup.sh` at the collection level to verify the foundation is installed
- Don't rely on custom frontmatter fields — they're invisible to most platforms

## Publishing Models

Two models, simple decision:

| Model | When | Trade-off |
|-------|------|-----------|
| **Skill** (one repo) | Default. Independent, discoverable, star-able | Each skill installs separately |
| **Collection** (one repo) | Skills always consumed together, same team, same release cycle | Locked together, can't mix-and-match |

**Our recommendation:** Default to a single Skill repo. Dependencies are declared in SKILL.md Step 0 and installed by `scripts/setup.sh`. Mirror in README's "Dependencies" section. Use Collection only when skills are genuinely locked together (WordPress 13 skills, Vercel 5 skills, Anthropic 17 skills).

## Dependency Tiers

| Tier | Declared in | Behavior |
|------|-------------|----------|
| **Dependencies** | SKILL.md Step 0 + `scripts/setup.sh` | Must install. Missing → install. Can't install → block |
| **Informational** | README.md only | Human reading. AI does not act on it |

No middle ground. "Works better with" is not a tier — if the skill needs it, declare it as a dependency.

## Current Tooling Landscape

As of March 2026, no tool fully solves skill composition.

| Tool | Dependencies | Transitive | GitHub-native | Context-aware |
|------|-------------|-----------|--------------|--------------|
| `npx skills add` | No | No | Yes | No |
| `skillpm` | Yes (npm) | Yes (npm) | No (npm registry) | No |
| `skills-supply` (`sk`) | Package-level | No | Yes | No |
| Discussion #210 proposal | Yes (skills.json) | Yes (proposed) | Yes | No |

**Current approach:** `scripts/setup.sh` handles direct dependency installation today. When the spec adds native dependency support, setup.sh remains a valid mechanism — it's the standard entry point, regardless of how the ecosystem evolves.
