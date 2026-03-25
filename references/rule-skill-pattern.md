---
name: rule-skill-pattern
description: How skill-forge detects MUST/NEVER constraint patterns, auto-creates paired rule-skills using the rules-as-skills methodology, and packages them with setup.sh and README for distribution.
---

# Rule-Skill Pattern — Forge Integration

How skill-forge detects, creates, and packages rule-skills.

For the complete rule-skill methodology (three-layer model, anatomy, decision tree, platform adaptation), see [rules-as-skills](https://github.com/motiful/rules-as-skills).

## Execution Procedure

```
detect_and_create(skill_md) → rule_skill_spec | nothing

scan for 3+ MUST/NEVER constraint patterns
if found → auto-create paired <name>-rules skill
    invoke Skill("rules-as-skills") for methodology
    package with setup.sh + README
if not found → no action
```

## Detection

skill-forge detects constraints worth separating when:
- User explicitly states MUST/NEVER rules
- Skill content contains 3+ constraint patterns (must, never, always, forbidden, required)
- The skill imposes domain-specific boundaries
- Behavior limits exist ("max N", "must do X before Y")

## When forge creates a rule-skill

Detection-driven, not user-chosen:

| Detected | Forge action |
|----------|-------------|
| 3+ MUST/NEVER constraints that users may want to customize | Auto-create paired `<name>-rules` skill |
| Constraints need per-project customization | Auto-create |
| No constraints detected | Nothing created |

The user is not asked "do you want a rule-skill?" — forge detects and acts.

Before creating, load the methodology:

`Skill("rules-as-skills")` — owns rule-skill methodology (three-layer model, anatomy, description format).
skill-forge owns detection and packaging. Both apply.
Do not create a rule-skill without consulting rules-as-skills methodology.

## Packaging

In the generated capability skill:
- **SKILL.md Step 0**: declare `<name>-rules` as dependency, installed by `scripts/setup.sh`
- **README "Dependencies"**: list `<name>-rules` with `npx skills add <org>/<name>-rules`

In the generated rule-skill:
- Standalone README with own install instructions
- Self-contained SKILL.md with all constraint rules
- No dependency on forge or rules-as-skills to function

## Converting Existing Rules Files to Rule-Skills

This section covers **new skill creation** from detected constraints. For converting existing `.claude/rules/` or `CLAUDE.md` files during project audit, see `references/project-audit.md` — Rules Conversion section.

Key distinction: always-on rules (no `description`, or `alwaysApply: true`) must **not** be converted to skills. Skills are trigger-based; converting always-on rules changes their activation behavior. Project audit handles this classification before any conversion.

## Attribution

Generated rule-skills (published) should include in README:

> ### Further Reading
> This rule-skill follows the [rules-as-skills](https://github.com/motiful/rules-as-skills) methodology.
