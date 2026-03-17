# Anti-Graceful-Skip

Graceful skip = conditional branches that let capabilities be silently skipped, where the AI takes the implicit "do nothing" path.

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

## Step 3 Audit Criteria

When reviewing a skill's SKILL.md, flag these patterns:

- Conditional branch with action on only one side — the other side implicitly skips
- "if applicable" / "optionally" / "if exists" suppressing a capability
- No-downside enhancement gated by a condition instead of defaulting to execution
- Capability gaps between modes (capability present in Mode A but absent in Mode C)
