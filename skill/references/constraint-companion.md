# Constraint Companion Pattern

## What It Is

When a skill has user-customizable constraints (MUST/NEVER rules, domain boundaries), those constraints are separated into a **companion rule-skill**. This ensures constraint visibility even when the capability skill isn't loaded — the rule-skill's description is always visible in the skill listing.

## Detection

The skill has constraints worth separating if:
- User explicitly states MUST/NEVER rules
- Skill description or content contains constraint patterns (must, never, always, forbidden, required)
- The skill imposes domain-specific boundaries ("no direct DB access", "must use parameterized queries")
- Behavior limits exist ("max N tabs", "must do X before Y")

## When to Create a Rule-Skill vs Use Native Rules

Not every constraint needs a rule-skill. Decision tree:

```
Is this constraint cross-project reusable?
├── Yes → create a rule-skill (publishable, portable)
└── No → project-level constraint
    ├── Platform has native rules? (.claude/rules/, AGENTS.md, .cursorrules)
    │   ├── Yes → use native rules (lowest friction)
    │   └── No → project-internal rule-skill
    └── Might become cross-project later?
        ├── Yes → start with native rules, graduate to rule-skill when mature
        └── No → native rules are sufficient
```

**Rule-skills are best for**: cross-project reusable constraints, constraints that need cross-platform portability, domain-specific boundaries complex enough to warrant their own documentation.

**Native rules are best for**: simple single-project constraints, team-specific conventions, constraints that only make sense in one codebase.

## Creating a Rule-Skill

1. **Name**: `<skill-name>-rules` (e.g., `database-rules` for `database-access`)
2. **Move** all MUST/NEVER statements into the rule-skill
3. **Reference**: capability skill says "Use with `<name>-rules` for enforcement"
4. **Methodology**: follows the [rules-as-skills](https://github.com/motiful/rules-as-skills) three-layer model

## Self-Containment

Critical: generated skills must work for **end users who don't have skill-forge or rules-as-skills installed.** The end user just runs `npx skills add` (or manual clone + symlink as fallback).

In the generated capability skill:
- **README**: "For constraint enforcement, also install `<name>-rules`" with `npx skills add <org>/<name>-rules` as primary install command
- **SKILL.md body**: "Pairs with `<name>-rules`. If not installed, suggest to user."

In the generated rule-skill:
- Standalone README with own install instructions
- Self-contained SKILL.md with all constraint rules
- No dependency on forge or rules-as-skills to function

## Dependency Ethics

The 2026 Agent Skills community has established clear norms around skill dependencies:

**Do:**
- Mention companions in README (transparent, user decides)
- Reference companions in SKILL.md body (agent sees once when loaded)
- Provide standalone install instructions (no special tooling required)

**Don't:**
- Auto-install companions without user consent
- Force bundling — each skill must function independently
- Repeatedly recommend the same companion across sessions

This follows the "informed opt-in" principle: recommend transparently, once, and respect the user's decision. The ecosystem is young; aggressive dependency management creates supply chain risk and erodes trust.
