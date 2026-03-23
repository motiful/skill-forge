---
name: execution-procedure
description: Pseudocode + plan-as-checklist + GATE assertion pattern for structuring workflow skills. Defines when a skill needs an Execution Procedure, the five required components (pseudocode, plan-as-checklist, GATE, inline references, directing vs content separation), and common anti-patterns.
---

```
detect(skill_md) → needs_procedure (bool)

if ordered multi-step flow with dependencies → true
if external tool calls at specific points → true
if step order matters (reorder causes failure) → true
if purely reference material (lookup, checklist) → false
```

# Execution Procedure Pattern

How to structure workflow skills so agents execute multi-step procedures instead of absorbing them as knowledge.

## When to Detect

A skill needs an Execution Procedure when:
- It defines an **ordered, multi-step flow** (not just a list of checks)
- Steps have **dependencies** (step N requires output from step N-1)
- It uses **external tool calls** that must happen at specific points (e.g., `Skill()`, API calls)
- Step order matters — **skipping or reordering causes failure**

Skills that are purely reference material (lookup tables, style guides, validation checklists) do NOT need this pattern.

## The Pattern

Five components, all required for workflow skills:

### 1. Pseudocode Procedure

Python-like pseudocode at the **top** of the SKILL.md body, before any reference sections.

```python
def main_workflow(input):
    # STEP 1: Setup
    result = setup()                              # references/installation.md
    assert result.success                         # GATE — must pass before Step 2

    # STEP 2: Process
    plan_path = f"/tmp/{name}-plan.md"
    write_plan(plan_path, result)
    assert file_exists(plan_path)                 # GATE

    # STEP 3: Execute
    for item in plan.items:
        process(item)
        assert checkpoint(plan_path, item, "processed")

        Skill("other-skill", item.path)           # explicit Skill() call
        assert checkpoint(plan_path, item, "reviewed")

        assert done(item)
        checkpoint(plan_path, item, "done")
```

### 2. Plan = Checklist

The runtime plan file IS the execution checklist. Not two separate concepts.

| Concept | Role |
|---------|------|
| **Procedure** (in SKILL.md) | Template — defines what steps exist |
| **Plan** (runtime file) | Instance — tracks progress through those steps |

The plan is created fresh each run with per-item sub-steps matching the checkpoint boundaries:

```markdown
- [ ] 1. Item A
  - [ ] validated
  - [ ] readme-craft
  - [ ] self-review
  - [ ] done
```

Plan sub-steps correspond 1:1 to `checkpoint()` calls in the EP. Each checkpoint reads the plan, updates status, and asserts success before the next major step begins.

### 3. GATE Assertions and Checkpoints

`assert` statements between dependent steps force completion before proceeding:

```python
write_plan(plan_path, data)
assert file_exists(plan_path)          # cannot proceed without plan
```

GATEs prevent the most common drift pattern: skipping prerequisite steps and jumping to execution.

**Checkpoints** are GATEs applied to plan progress. Place `assert checkpoint()` at **major step boundaries only** — between phases that produce distinct deliverables (e.g., validation → readme-craft → self-review), not between every sub-task.

```python
# checkpoint = read plan + update status + assert success
assert checkpoint(plan_path, item, "validated")   # after all validation + fixes
assert checkpoint(plan_path, item, "readme-craft") # after readme-craft completes
assert checkpoint(plan_path, item, "self-review")  # after self-review completes
checkpoint(plan_path, item, "done")                # final — no assert needed
```

**Why checkpoints work**: LLMs reliably follow `assert` (GATE) but skip suggestions. `review_plan()` and `update_plan()` without assert are suggestions — they will be ignored when conversation momentum carries the agent forward. Wrapping plan updates in `assert` makes them mandatory.

**Where to place checkpoints**: between steps that each take significant effort and produce a distinct result. If two steps always run back-to-back with no decision point between them, a single checkpoint after both is sufficient.

### 4. Inline References (One-Hop)

Comments in pseudocode point directly to reference files:

```python
config = read_or_create_config()       # references/onboarding.md
findings = core_validate(item)         # see Core Validation section
```

One hop: pseudocode → reference file. No intermediate layer.

### 5. Execution Procedure vs Content Separation

Both live in the same file (SKILL.md or reference), but in different formats. This is the three-layer model applied to workflow structure:

| Layer | Format | Position | Agent behavior |
|-------|--------|----------|----------------|
| **Execution Procedure** | Pseudocode | Top (after frontmatter) | Executed as procedure |
| **Content** | Tables, prose, sections | Below EP | Referenced on demand, each section serves an EP line |

The agent follows the pseudocode (Execution Procedure) and consults Content sections when the pseudocode references them. This pattern applies to both SKILL.md and reference files.

## Anti-Patterns

| Anti-pattern | Why it fails | Fix |
|-------------|-------------|-----|
| Natural language numbered steps | Treated as knowledge, not instructions | Convert to pseudocode |
| Separate "output checklist" from "plan" | Duplication → one drifts | Plan IS the checklist |
| Two-hop references (step → intermediate section → reference file) | Information loss at each hop | One-hop: pseudocode → reference |
| Methodology explanation mixed with execution instructions | Agent absorbs execution as knowledge | Pseudocode at top, explanation below |
| Resumable plan files across runs | Stale state from previous context | Fresh plan each run |
| `review_plan()` / `update_plan()` as suggestions | LLM skips non-GATE actions when conversation momentum carries forward | Use `assert checkpoint()` — makes plan update mandatory |
| Checkpoint on every sub-task | High friction, low value — agent starts skipping all of them | Checkpoint only at major step boundaries (distinct deliverables) |
