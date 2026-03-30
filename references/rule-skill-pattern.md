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

Three detection modes. All are detection-driven, not user-chosen.

### Mode A: Classify — Is the current skill itself a rule-skill?

Check BEFORE structural/quality validation. If the skill IS a rule-skill, validation must apply rule-skill standards (description format, Layer 1/2/3 model).

```
classify_as_rule_skill(skill_md) → bool

count MUST/NEVER/ALWAYS/FORBIDDEN/REQUIRED in body
if count >= 3 AND skill's primary value is the constraints (not a side effect):
    check: originated from a rule file? (commit history, user context)
    check: constraints are the core — remove them and the skill loses its reason to exist?
    check: domain-specific, not universal?
    if any → classify as rule-skill
    run decision-tree.md assess() to confirm mechanism
    validate against rules-as-skills three-layer model:
        Layer 1: description has MUST/NEVER summary + trigger conditions
        Layer 2: body has full rules + optional EP for applying them
        Layer 3: if critical, thin platform rule file exists as fallback
    report classification in findings
```

| Signal | Weight |
|--------|--------|
| Originated from a `.claude/rules/` or `AGENTS.md` file | Strong — almost certainly a rule-skill |
| 3+ MUST/NEVER statements where constraints ARE the deliverable | Strong |
| Has EP but EP exists to APPLY constraints, not to produce a separate artifact | Moderate |
| Removing the MUST/NEVER rules leaves nothing of value | Confirms rule-skill |

### Mode B: Separate — Extract constraints from a capability skill

Detects constraints worth separating into a paired `-rules` skill:

skill-forge detects constraints worth separating when:
- User explicitly states MUST/NEVER rules
- Skill content contains 3+ constraint patterns (must, never, always, forbidden, required)
- The skill imposes domain-specific boundaries
- Behavior limits exist ("max N", "must do X before Y")

### Mode C: Convert — Transform rule files into rule-skills

See §Converting Existing Rules Files to Rule-Skills below.

## When forge creates a rule-skill

Detection-driven, not user-chosen:

| Detected | Forge action |
|----------|-------------|
| Mode A: Skill IS a rule-skill but not classified as one | Report finding — validate against rule-skill standards, suggest fixes |
| Mode B: 3+ MUST/NEVER constraints that users may want to customize | Auto-create paired `<name>-rules` skill |
| Mode B: Constraints need per-project customization | Auto-create |
| Mode C: Existing rule files that should be portable | Convert to rule-skill |
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
