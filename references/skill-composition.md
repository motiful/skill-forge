# Skill Composition

## TOC

- [Why Composition Matters](#why-composition-matters)
- [Decision: Monorepo vs Independent + Catalog](#decision-monorepo-vs-independent--catalog)
- [Catalog Pattern](#catalog-pattern)
- [Context Budget Constraint](#context-budget-constraint)
- [Current Tooling Landscape](#current-tooling-landscape)

## Why Composition Matters

Skills are code. Code has dependencies. Skills need dependencies.

A single skill solves a single problem. But users face workflows that span multiple skills — and those skills may overlap across product lines. Without composition, skills either become monoliths (cramming everything into one SKILL.md) or isolated silos (each skill reinvents shared logic).

The npm/pip ecosystems proved that dependency management is the unlock for exponential growth: users focus on their top-level concern, and the dependency graph handles everything underneath. Skills are on the same trajectory.

**Current ecosystem state (March 2026):** The Agent Skills spec has no `dependencies` field. Four open proposals exist (agentskills/agentskills #100, #110, #90→#160, #210). No tool has won the "npm for skills" position. The slot is open.

## Terminology

Three terms, no jargon:

| Term | Definition | Repo naming |
|------|-----------|------------|
| **Skill** | One capability, one repo. The atomic unit. | `<org>/<skill-name>` |
| **Kit** | A curated bundle of skills for a specific workflow. | `<org>/<domain>-kit` |
| **Catalog** | An org-level directory listing all available skills. | `<org>/skills` |

Use these terms in conversation with the user. Avoid "monorepo" and "hybrid" — they are implementation details, not user-facing concepts.

## Decision: Kit vs Collection

When a user publishes multiple related skills, ask which model fits:

### Kit (recommended default)

Each skill is its own repo. A Kit bundles them for a specific audience or workflow.

**Choose when:**
- Skills can be consumed in different combinations
- You want the same skill in multiple Kits (multi-to-multi distribution)
- Skills have different release cycles or maintainers
- You want each skill to have its own GitHub presence (stars, issues, SEO)

**Trade-off:** Users run `install.sh` (or multiple `npx skills add` commands) instead of one. Acceptable today; solved by dependency tooling in the future.

### Collection

All skills in one repo under `skills/<name>/SKILL.md`. For users who prefer simplicity over flexibility.

**Choose when:**
- Skills are ALWAYS consumed together (no standalone use case)
- Single team, single release cycle
- You value one-command install over distribution flexibility

**Trade-off:** Skills are locked to this repo. They can't appear in multiple Kits without duplication.

### Decision prompt for skill-forge

```
How do you want to organize these skills?

1. Kit — each skill gets its own repo, bundled by workflow
   Best for: skills that can be mixed and matched

2. Collection — all skills in one repo
   Best for: tightly coupled skills always used together

(Default: Kit)
```

Present both options. The user decides. If they choose Collection, support it fully — don't push them to switch.

## Catalog Pattern

A catalog repo is NOT a skill. It's a **composition layer** — a bundle that references independent skill repos.

### Structure

```
<org>/<catalog-name>/
├── README.md          — What problem this collection solves, who it's for
├── install.sh         — One-command installer (calls npx skills add per skill)
├── LICENSE
└── .gitignore
```

### install.sh template

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Installing <catalog-name> skills..."
echo ""

skills=(
  "<org>/skill-a"
  "<org>/skill-b"
  "<org>/skill-c"
)

for skill in "${skills[@]}"; do
  echo "→ $skill"
  npx skills add "$skill" -y
done

echo ""
echo "✓ All skills installed."
```

### README template

```markdown
# <Catalog Name>

> <One line: what workflow this collection supports>

## What's Included

| Skill | Description | Standalone install |
|-------|-------------|--------------------|
| [skill-a](<url>) | ... | `npx skills add <org>/skill-a` |
| [skill-b](<url>) | ... | `npx skills add <org>/skill-b` |
| [skill-c](<url>) | ... | `npx skills add <org>/skill-c` |

## Install All

```bash
curl -fsSL https://raw.githubusercontent.com/<org>/<catalog>/main/install.sh | bash
```

Or install individually — each skill works on its own.

## Why These Together

<2-4 sentences explaining why this combination is useful>
```

### Naming

- Catalog repos: `<problem-domain>-toolkit` or `<problem-domain>-kit`
- NOT `<org>-skills` (too vague) or `<org>/<org>` (zero information)
- The name should tell a stranger what workflow this collection supports

### Key property: skills are first-class, Kits are views

The same skill can appear in multiple Kits. Kits are views over the skill graph, not containers. This enables multi-to-multi distribution:

```
skill-a ──→ catalog-X (for workflow X)
skill-b ──→ kit-X
skill-b ──→ kit-Y (for workflow Y)
skill-c ──→ kit-Y
```

## Context Budget Constraint

This is what makes skill dependencies fundamentally different from npm/pip.

Each activated skill consumes context tokens. npm packages load into memory (effectively unlimited); skills load into context windows (200K tokens, shared with user conversation and tool results).

**Practical limits:**
- A typical SKILL.md: 200-500 lines ≈ 2K-5K tokens
- References loaded on-demand: 100-200 lines each
- Safe active skill budget: 3-5 skills simultaneously ≈ 15K-25K tokens
- Beyond that: skills compete with each other and with the user's task

**Implications for composition:**
- A catalog should not install 20 skills that all auto-activate
- Prefer skills that load on-demand (triggered by specific phrases) over always-active skills
- Future dependency resolvers must be context-budget-aware — this is the differentiator vs npm

## Current Tooling Landscape

As of March 2026, no tool fully solves skill composition.

| Tool | Dependencies | Transitive | GitHub-native | Context-aware |
|------|-------------|-----------|--------------|--------------|
| `npx skills add` | No | No | Yes | No |
| `skillpm` | Yes (npm) | Yes (npm) | No (npm registry) | No |
| `skills-supply` (`sk`) | Package-level | No | Yes | No |
| `install.sh` (catalog) | Manual | Manual | Yes | No |
| Discussion #210 proposal | Yes (skills.json) | Yes (proposed) | Yes | No |

**Our recommendation today:** Use the catalog pattern (install.sh) for composition. It's simple, works everywhere, and doesn't require users to install extra tooling.

**Future:** When the spec adds dependency support (or a tool wins the "npm for skills" slot), catalogs can evolve into declarative manifests. The catalog-as-install-script pattern degrades gracefully.
