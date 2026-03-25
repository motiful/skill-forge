---
name: skill-invocation
description: Runtime invocation reliability pattern ensuring AI agents actually call dependent skills instead of skipping them. Covers the three-element pattern (explicit Skill() call, output capture, output gate), call site format, writing principles (position=timing, boundary not capability, binary not gradual), and anti-patterns with fixes.
---

# Skill Invocation Reliability

How to make an AI agent **actually call** a dependent skill at runtime — not just have it installed.

## Execution Procedure

```
validate_invocations(skill_md, dependencies) → findings[]

for each dependency invocation in skill_md:
    check: uses explicit Skill("name", "args") syntax
    check: captures output (downstream step references it)
    check: has output gate (assert)
    if natural-language invocation ("invoke X") → finding(Warning)

write_call_site(dependency, location) → call_pattern

generate: Skill("name", "args") + output capture + assert gate
position: at the exact EP line where the dependency is needed
```

## The Pattern

Three lines. Use at every point a skill calls another skill.

Why this pattern exists: agents skip skill calls for three reasons — self-sufficiency bias (believes it can do the task itself), no downstream gate (skipping costs nothing), and high-freedom instructions ("invoke X" has multiple interpretations).

```markdown
Run: `Skill("<name>", "<args>")`
Do not substitute with manual <action>.
Record output — <downstream step> requires it.
```

Line 1: **Explicit tool call** (low freedom — one valid action).
Line 2: **Block the alternative** (close the "I'll do it myself" escape).
Line 3: **Output gate** (downstream step breaks if skipped).

Use at least line 1 + line 3. Line 2 is insurance for skills whose domain overlaps with the agent's general ability (text analysis, code review, formatting).

### Call Site Format

When a skill declares a dependency on another skill, the call site uses this compact format:

```
`Skill("<name>", "<args>")` — <boundary: what it owns>.
<host> owns <what host brings>. <combination rule>.
<one guardrail>.
```

Example (skill-forge calling readme-craft):
```
`Skill("readme-craft", "review <path>")` — owns universal README quality.
skill-forge owns skill-specific README standards (`references/readme-quality.md`). Both apply, domain wins.
Do not manually fix what readme-craft handles.
```

#### Writing Principles

| Principle | Rule |
|-----------|------|
| Position = timing | Place the call site at the workflow step where invocation happens. Do not add a separate "when to invoke" line |
| Boundary not capability | Describe the division of ownership, not what each side does. Capabilities are described in each skill's own SKILL.md |
| Binary not gradual | "Both apply, domain wins" not "consider applying both." No wiggle room |
| One guardrail | Block the specific shortcut the AI would take for this dependency. Each dependency has a different escape route |

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

