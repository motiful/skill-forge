---
name: anti-graceful-skip
description: Default-execute principle and audit criteria for conditional branches in skills. Covers five principles (default execute, narrow skip conditions, no-downside enhancements, binary not gradual, resolvable conditions) and Step 3 audit patterns for detecting implicit skip paths on both action and condition sides.
---

# Anti-Graceful-Skip

Graceful skip = conditional branches that let capabilities be silently skipped, where the AI takes the implicit "do nothing" path.

## Execution Procedure

```
audit_conditional_branches(skill_md) → findings[]

for each conditional branch:
    check: both sides have explicit actions
    check: no "if applicable" / "optionally" suppressing capability
    check: no-downside enhancements default to execution
```

## Principles

### 1. Default Execute, Explicit Skip

Every conditional branch must have an explicit action on both sides. No implicit "do nothing" path.

Bad: "If logo exists, use `<picture>`" (no logo -> nothing happens)
Good: "Logo file found -> use `<picture>`. Not found -> generate candidates."

### 2. Skip Conditions Must Be Narrow and Justified

Bad: "if applicable" / "optionally" (always judgeable as not applicable)
Good: "Skip ONLY when: project is a CLI tool with no visual output"

### 3. No-Downside Enhancements Default to Execution

Users install a skill for its enhanced capabilities. If an enhancement has no downside, execute it by default.

Bad: "You may generate a logo if the project doesn't have one"
Good: "No logo file found -> generate 5 candidates, present to user for selection"

### 4. Binary Not Gradual

"Both apply" is not "consider applying both."
"Do not X" is not "avoid X when possible."
No wiggle room for the AI.

### 5. Conditional Conditions Must Be Resolvable

A conditional branch in EP pseudocode is only as effective as the condition the agent can evaluate. If the condition references a data field with no documented inference source, the agent cannot deterministically evaluate it — it defaults to false, takes the else branch, and silently skips the capability. **This is graceful skip on the condition side** (existing principles 1-4 cover graceful skip on the action side).

Bad:
```python
if answers.b2b and answers.high_price and answers.trust_critical:
    recommended = "authority"
```
(The `b2b`, `high_price`, `trust_critical` fields are not documented anywhere — no inference rule tells the AI how to populate them from user input. AI reading the EP has no anchor, defaults to false, falls through to the else branch. The authority recommendation never fires.)

Good: same conditional code, plus an inline or adjacent **Signal Inference section** documenting each field:

```markdown
### Signal Inference

- `b2b` — Q2 target user contains: enterprise / team / CISO / CIO / admin / legal / security / finance / compliance / IT / procurement
- `high_price` — Q3 alternatives priced $1K+/yr; intuition "requires purchase approval"
- `trust_critical` — Q1 mentions: security / compliance / audit / financial / medical / legal / privacy / data protection
```

Each field documents: source question(s), signal patterns, NEVER-ask constraint (the agent infers silently, does not ask the user directly).

**Related principle — field-level module references**: See `references/execution-procedure.md` §4 Module References for the parallel rule at the function-call level ("Decision-layer reference or 100% skip"). Field references follow the same logic: every data field referenced in EP must have a resolvable source, or it is dead code.

## Step 3 Audit Criteria

When reviewing a skill's SKILL.md, flag these patterns:

- Conditional branch with action on only one side — the other side implicitly skips
- "if applicable" / "optionally" / "if exists" suppressing a capability
- No-downside enhancement gated by a condition instead of defaulting to execution
- Capability gaps between modes (capability present in Mode A but absent in Mode C)
- Condition expressions in EP pseudocode (`if answers.X`, `if context.Y`) that reference data fields with no documented inference source — AI defaults to false, branch silently skips
