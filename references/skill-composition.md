# Skill Composition

Why some skills mention companion tools, and when multiple skills belong in one repo.

## Why Composition Matters

A single skill solves a single problem. But users face workflows that span multiple skills — and those skills may overlap across product lines. Without composition guidance, skills either become monoliths (cramming everything into one SKILL.md) or isolated silos (each skill reinvents shared logic).

**Current ecosystem state (March 2026):** The Agent Skills spec has no `dependencies` field. Multiple proposals exist but none have been adopted. The spec is deliberately minimal by design.

## Context Budget Constraint

This is what makes skill composition fundamentally different from npm/pip.

Each activated skill consumes context tokens. npm packages load into memory (effectively unlimited); skills load into context windows (200K tokens, shared with user conversation and tool results).

**Practical limits:**
- A typical SKILL.md: 200-500 lines ~ 2K-5K tokens
- References loaded on-demand: 100-200 lines each
- Safe active skill budget: 3-5 skills simultaneously ~ 15K-25K tokens
- Beyond that: skills compete with each other and with the user's task

**Implications for composition:**
- Don't install 20 skills that all auto-activate
- Prefer skills that load on-demand (triggered by specific phrases) over always-active skills
- Future dependency resolvers must be context-budget-aware — this is the differentiator vs npm

## Publishing Models

Two models, simple decision:

| Model | When | Trade-off |
|-------|------|-----------|
| **Skill** (one repo) | Default. Independent, discoverable, star-able | Each skill installs separately |
| **Collection** (one repo) | Skills always consumed together, same team, same release cycle | Locked together, can't mix-and-match |

**Our recommendation:** Default to a single Skill repo. If companion tools strengthen specific steps, mention them inline with fallback behavior and mirror in README's "Works Better With" section. Use Collection only when skills are genuinely locked together (WordPress 13 skills, Vercel 5 skills, Anthropic 17 skills).

## Current Tooling Landscape

As of March 2026, no tool fully solves skill composition.

| Tool | Dependencies | Transitive | GitHub-native | Context-aware |
|------|-------------|-----------|--------------|--------------|
| `npx skills add` | No | No | Yes | No |
| `skillpm` | Yes (npm) | Yes (npm) | No (npm registry) | No |
| `skills-supply` (`sk`) | Package-level | No | Yes | No |
| Discussion #210 proposal | Yes (skills.json) | Yes (proposed) | Yes | No |

**Future:** When the spec adds dependency support (or a tool wins the "npm for skills" slot), composition can evolve from "mention in README" to "declare in manifest." The simple approach degrades gracefully.
