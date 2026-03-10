# Skill Composition

Why skills need composition, what makes it different from npm/pip, and where the ecosystem stands today.

## Why Composition Matters

Skills are code. Code has dependencies. Skills need dependencies.

A single skill solves a single problem. But users face workflows that span multiple skills — and those skills may overlap across product lines. Without composition, skills either become monoliths (cramming everything into one SKILL.md) or isolated silos (each skill reinvents shared logic).

The npm/pip ecosystems proved that dependency management is the unlock for exponential growth: users focus on their top-level concern, and the dependency graph handles everything underneath. Skills are on the same trajectory.

**Current ecosystem state (March 2026):** The Agent Skills spec has no `dependencies` field. Four open proposals exist (agentskills/agentskills #100, #110, #90→#160, #210). No tool has won the "npm for skills" position. The slot is open.

## Context Budget Constraint

This is what makes skill dependencies fundamentally different from npm/pip.

Each activated skill consumes context tokens. npm packages load into memory (effectively unlimited); skills load into context windows (200K tokens, shared with user conversation and tool results).

**Practical limits:**
- A typical SKILL.md: 200-500 lines ≈ 2K-5K tokens
- References loaded on-demand: 100-200 lines each
- Safe active skill budget: 3-5 skills simultaneously ≈ 15K-25K tokens
- Beyond that: skills compete with each other and with the user's task

**Implications for composition:**
- A Kit should not install 20 skills that all auto-activate
- Prefer skills that load on-demand (triggered by specific phrases) over always-active skills
- Future dependency resolvers must be context-budget-aware — this is the differentiator vs npm

## Current Tooling Landscape

As of March 2026, no tool fully solves skill composition.

| Tool | Dependencies | Transitive | GitHub-native | Context-aware |
|------|-------------|-----------|--------------|--------------|
| `npx skills add` | No | No | Yes | No |
| `skillpm` | Yes (npm) | Yes (npm) | No (npm registry) | No |
| `skills-supply` (`sk`) | Package-level | No | Yes | No |
| `install.sh` (Kit) | Manual | Manual | Yes | No |
| Discussion #210 proposal | Yes (skills.json) | Yes (proposed) | Yes | No |

**Our recommendation today:** Use the Kit pattern (install.sh) for composition. It's simple, works everywhere, and doesn't require users to install extra tooling.

**Future:** When the spec adds dependency support (or a tool wins the "npm for skills" slot), Kits can evolve into declarative manifests. The Kit-as-install-script pattern degrades gracefully.
