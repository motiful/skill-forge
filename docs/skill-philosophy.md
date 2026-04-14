# Skill Philosophy

The ideas behind skill-forge — what skills are, why they need engineering discipline, and the technical choices that follow.

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

## Three-Dimension Mental Model

When structuring, packaging, and delivering a skill, three orthogonal dimensions must be resolved separately. Confusing them is the most common source of packaging mistakes.

| Dimension | Question | Options |
|-----------|----------|---------|
| **A. Entry** | How does the agent encounter this skill? | Capability (explicit invocation like "review my skill") vs Constraint (auto-activated when the body's trigger scenario matches) |
| **B. Dependency** | What other skills does this one require? | Runtime (must load to execute) vs Informational (reference material only), crossed with Independent vs Coupled |
| **C. Publishing** | How does this skill ship? | Single-skill repo / Peer Collection (unrelated skills co-located for install convenience) / Augmented Skill Collection (primary capability + paired rule-skills that must ship together) |

The dimensions are orthogonal. Decisions in one do not constrain decisions in another: a capability skill (A) can have a coupled runtime dependency (B) and still publish as a Peer Collection (C). Questions like "should my rule-skill be its own repo?" conflate A (it's a constraint) with C (a publishing decision) and produce confusion.

**How this mental model emerged**: April 2026 dogfooding against `design-playbook` and `rules-as-skills`. Earlier packaging decisions had silently conflated the three dimensions — "we need rule-skill packaging" was being used to answer three different questions at once. Separating them fixed the design and revealed that not every rule-skill candidate needs a separate Augmented Skill Collection; some are better inlined as documentation within the capability they constrain.

See [`references/publishing-strategy.md`](../references/publishing-strategy.md) for the full Dimension C decision framework and [`references/skill-composition.md`](../references/skill-composition.md) for Dimension B dependency tiers.

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

## On Behavioral Testing

Some tools test whether a skill changes agent output — "does it have an effect?" This is useful but:
- Expensive (~100K+ tokens per eval session)
- Platform-specific (requires a particular CLI to spawn subagents)
- Model-dependent (results shift as models improve)
- Often unnecessary (a well-written description + validation catches most problems)

skill-forge tests whether a skill is ready to publish — "is it engineered well?" This is cheap (the agent reads files and judges), platform-agnostic, and model-independent.

**For description quality specifically:** forge checks coverage during validation — does the description mention the key trigger scenarios from the SKILL.md body? This catches most description problems at near-zero cost. Telling a user "your description should mention X scenario" is more actionable than running 20 queries to prove the description is suboptimal.
