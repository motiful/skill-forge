# Skill Quality Principles

The single source of truth for all skill-forge decisions.

**Audience**: AI agents maintaining skill-forge. Loaded during maintenance and self-review, NOT during runtime execution (Steps 0-4). This document guides what features to add, what PRs to accept, and what direction to take.

## TOC

- [Vision](#vision)
- [What Is a Good Skill](#what-is-a-good-skill)
- [What Skills Are](#what-skills-are)
- [Skills Deserve Engineering Discipline](#skills-deserve-engineering-discipline)
- [Skill Engineering Patterns](#skill-engineering-patterns)
- [Skill-Forge's Identity](#skill-forges-identity)
- [Technical Route](#technical-route)
- [Boundaries](#boundaries)
- [Decision Test](#decision-test)

## Vision

Skills are the next unit of reusable intelligence. They give AI agents domain knowledge, workflows, and judgment patterns that the base model doesn't have.

As skills mature from prompt snippets to installable extensions, they need engineering discipline — not just at publish time, but across the entire lifecycle: how to structure them, how to make them configurable, how to validate them, and how to distribute them.

skill-forge exists to define and practice that discipline.

## What Is a Good Skill

A skill is good when it makes an AI agent measurably better at solving a specific class of problems.

Six quality dimensions:

| # | Dimension | Test |
|---|-----------|------|
| 1 | **Discoverable** | Can an agent find it from description alone? |
| 2 | **Reliable** | Does it work consistently across scenarios? |
| 3 | **Efficient** | Does it respect context budget? Load only what's needed? |
| 4 | **Trustworthy** | No security risks? Auditable? Honest claims? |
| 5 | **Bounded** | Does it know what it IS and ISN'T responsible for? |
| 6 | **Valuable** | Does it solve a real, repeated problem? |

## What Skills Are

Skills are **loadable capability extensions for AI agents** — combining domain knowledge, procedural expertise, and quality standards into composable packages that an agent interprets at runtime.

They are not software (software executes independently and has state). They are not just prompts (prompts lack structure, configuration, and composability). They are closest to **expert system knowledge bases + standard operating procedures, packaged as agent extensions**.

Parallels from established disciplines:

| Discipline | Closest analogy | What skills share with it |
|-----------|----------------|--------------------------|
| Computer science | Plugin / extension | Extends a host's capabilities, loaded on demand, composable |
| Knowledge engineering | Expert system knowledge base | Domain rules + heuristics, interpreted by an inference engine (the agent) |
| HCI | Interface layer | Lowers interaction cost for complex operations (AI replaces GUI) |
| Organizational theory | Standard Operating Procedure | Step-by-step process for consistent quality outcomes |

**One-sentence definition**: A skill is an AI agent's professional competency package — like a board certification for a doctor, it gives the agent structured expertise in a specific domain.

## Skills Deserve Engineering Discipline

Skills started as prompt snippets. The ecosystem has moved past that. The Agent Skills open standard (adopted by 30+ products, 88K+ published skills) now treats skills as installable, distributable, composable units. Active community RFCs address secrets management, versioning, signatures, and packaging.

Skills are not software, but they deserve the same engineering discipline as software:

| Capability | Example | Mechanism |
|------------|---------|-----------|
| **Configuration** | User preferences, org defaults, verbosity | `~/.config/<skill-name>/config.md` — absent → create with defaults |
| **Dependencies** | Tools (git, gh), skills (readme-craft), packages (npm) | `scripts/setup.sh` — absent → install. Can't install → block with error |

These capabilities don't make skills stateful. Config is not state. Preferences are not sessions. A skill that reads `~/.config/self-review/config.md` to know its defaults is no more stateful than a CLI tool that reads a dotfile.

**The litmus test:** if you delete the config file, can the skill automatically rebuild it with defaults and keep working? If yes — it's config (self-healing). If no — you've crossed the line into infrastructure.

## Skill Engineering Patterns

skill-forge defines engineering patterns for skill authors. These are optional — most skills need none of them. But when a skill grows complex enough, the patterns should be clear and standardized.

| Pattern | When to use |
|---------|------------|
| **Configuration** | Skill has user-adjustable behavior that persists across invocations |
| **Installation** | Skill needs external tools or runtimes to function |
| **Rule-Skill split** | Skill has hard MUST/NEVER constraints that users may want to customize |

Each pattern is:
- **Optional** — don't force-fit. Most skills are simple instruction packages and that's fine
- **Self-contained** — the generated skill works without skill-forge installed. This means independent from forge, not independent from all other skills or tools — skills may declare and install their own dependencies
- **Prompt-driven** — implemented as SKILL.md instructions, not as scripts or binaries
- **Practically tested** — skill-forge itself uses the configuration pattern (Step 0). We don't prescribe what we don't practice

## Skill-Forge's Identity

**skill-forge = skill engineering methodology + publishing pipeline.**

The methodology defines how to build skills that score high on the 6 quality dimensions. The pipeline automates validation and publishing. Both are valuable independently — a user can reference the methodology without ever running the pipeline, and vice versa.

| Layer | What it does | When it helps |
|-------|-------------|---------------|
| **Methodology** | Engineering patterns, quality standards, format spec | While writing or improving skills |
| **Validation** | Format, security, structure, description coverage, claim consistency | Before publish, or as standalone audit |
| **Publishing** | Git init, GitHub push, platform registration, README generation | When ready to share |

### What skill-forge is

- A definition of what "well-engineered skill" means
- A validation suite for format, security, structure, and claims
- A publishing pipeline from local files to installable GitHub repo
- A reference library of engineering patterns for skill authors
- Platform-agnostic — works wherever Agent Skills work

### What skill-forge is NOT

- Not an IDE or authoring tool — we validate and publish, not write content
- Not a package manager — we don't resolve transitive dependency trees or arbitrate version conflicts. Installing declared direct dependencies is normal engineering, not package management
- Not a behavioral test framework — we check engineering quality, not domain effectiveness
- Not a platform feature — we are a skill about skills, not infrastructure

### On behavioral testing

Some tools test whether a skill changes agent output — "does it have an effect?" This is useful but:
- Expensive (~100K+ tokens per eval session)
- Platform-specific (requires a particular CLI to spawn subagents)
- Model-dependent (results shift as models improve)
- Often unnecessary (a well-written description + validation catches most problems)

skill-forge tests whether a skill is ready to publish — "is it engineered well?" This is cheap (the agent reads files and judges), platform-agnostic, and model-independent.

**For description quality specifically:** forge checks coverage during validation — does the description mention the key trigger scenarios from the SKILL.md body? This catches most description problems at near-zero cost. Telling a user "your description should mention X scenario" is more actionable than running 20 queries to prove the description is suboptimal.

## Technical Route

**Prompt-driven. Platform-agnostic. No runtime dependencies for core logic.**

| Choice | Rationale |
|--------|-----------|
| Pure markdown instructions | Skills are instruction packages. A skill about skills should be one too |
| No scripts for core logic | No Python/Node runtime needed. Install = git clone. Simplest possible |
| Agent-executed validation | The AI reads files and judges — same capability it uses for everything else |
| Platform-agnostic | Works on Claude Code, Codex, Cursor, Windsurf, Copilot, and future platforms |
| Scriptable scanning as exception | If deterministic regex scanning (leaked keys) ever needs a script, that's the one exception |

**Why prompts over scripts?**

A skill that requires Python to validate other skills has a dependency problem. A skill that uses SKILL.md instructions to validate other skills is self-consistent. Our technical route is also our philosophical advantage — we prove that complex engineering workflows can be expressed as agent instructions, not code.

This keeps skill-forge:
- Installable in one command (`npx skills add`)
- Maintainable by editing markdown
- Portable across every Agent Skills platform
- Honest about what skills can be

## Boundaries

| Inside skill-forge's scope | Outside skill-forge's scope |
|---------------------------|----------------------------|
| Defining skill quality dimensions | Writing skill content for users |
| Engineering pattern definitions | Behavioral eval / A/B testing |
| Format and structure validation | Transitive dependency resolution / version conflict arbitration |
| Security scanning (leaked keys, credentials) | Package management |
| README claim discipline | Platform-specific runtime tooling |
| Description coverage checking | Model-specific optimization |
| Publishing automation (git → GitHub → register) | Session or state management infrastructure |
| Cross-platform compatibility guidance | Commercial distribution or marketplace |

## Decision Test

For any proposed feature or capability in skill-forge:

1. **Does it help the user's skill score higher on the 6 dimensions?** → Keep
2. **Is it simple enough that an AI agent will reliably follow it?** → If not, simplify or remove
3. **Can it be expressed as prompts instead of scripts?** → Use prompts
4. **Does it impose an architectural opinion that most skills don't need?** → Remove
5. **Is it a platform or infrastructure concern, not a skill quality concern?** → Remove
6. **Does the ecosystem actually use this pattern?** → If no, demote to optional reference at most
7. **Do we practice it ourselves?** → If we prescribe it, we must use it in skill-forge. Not practicing is a gap to fix, not a reason to avoid prescribing
