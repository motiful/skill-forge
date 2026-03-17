# Skill Invocation Reliability

How to make an AI agent **actually call** a dependent skill at runtime — not just have it installed.

## The Gap: Installation ≠ Invocation

`skill-composition.md` solves installation (`scripts/setup.sh`). But installation does not guarantee invocation.

> "Claude tends to handle simple tasks on its own without consulting Skills, defaulting to not triggering them."
> — Anthropic, Skill authoring best practices (2026)

| Instruction style | Activation rate |
|-------------------|----------------|
| Natural language ("invoke X") | 20% |
| Explicit tool call + structural gate | 84–100% |

Source: Scott Spence, activation reliability study (2026).

## Why Agents Skip

1. **Self-sufficiency bias** — agent believes it can do the task itself, skips the tool call
2. **No downstream gate** — nothing references the skill's output, so skipping costs nothing
3. **High-freedom instruction** — "invoke X" has multiple valid interpretations; agent picks the easiest

## The Pattern

Three lines. Use at every point a skill calls another skill.

```markdown
Run: `Skill("<name>", "<args>")`
Do not substitute with manual <action>.
Record output — <downstream step> requires it.
```

Line 1: **Explicit tool call** (low freedom — one valid action).
Line 2: **Block the alternative** (close the "I'll do it myself" escape).
Line 3: **Output gate** (downstream step breaks if skipped).

Use at least line 1 + line 3. Line 2 is insurance for skills whose domain overlaps with the agent's general ability (text analysis, code review, formatting).

### Do NOT couple to dependency internals

Bad: "X applies a 35-point checklist across 5 dimensions"
Good: "Do not substitute with manual evaluation"

The invoking skill should not describe the dependency's implementation. It changes independently. If you name specific features, you create a sync obligation between two independent repos.

## Validation (Step 3)

| Check | Criteria | Severity |
|-------|---------|----------|
| Invocation reliability | For each skill dependency: does every invocation point use explicit `Skill(...)` syntax + output gate? Natural-language invocations ("invoke X", "run X") without these are flagged | Warning |

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| "Invoke X to do Y" | High-freedom, 20% activation | `Skill(...)` syntax |
| "See X for details" | Agent reads the file instead of invoking the skill | Distinguish "read file" vs "invoke skill" |
| "Optionally invoke X" | Agent always skips optional calls | If needed, make it mandatory |
| Describing dependency internals | Creates sync obligation | Just say "do not substitute" |

## Relationship to Other References

| Reference | Covers | This document adds |
|-----------|--------|--------------------|
| `skill-composition.md` | Installation, context budget | Runtime invocation reliability |
| `installation.md` | setup.sh, dependency detection | Ensuring installed skills are actually called |
| `skill-format.md` | SKILL.md structure | Invocation patterns within the body |
