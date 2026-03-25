---
name: execution-procedure
description: Pseudocode + plan-as-checklist + GATE assertion pattern for structuring workflow skills. Defines when a skill needs an Execution Procedure, the nine components (pseudocode, plan-as-checklist, GATE, module references, EP comment discipline, step granularity, batch principle, non-overlapping ownership, EP vs content separation), and common anti-patterns.
---

```
assess_procedure_need(skill_md) → workflow_skill | reference_only

# Purpose: EP forces execution fidelity — agents follow steps instead of absorbing
# them as knowledge. The question is: would EP significantly improve instruction-following
# and prevent graceful skip? If any criterion below matches → workflow_skill.
# "Natural language steps are clear enough" is NOT a valid reason to skip EP.
# "Skill isn't complex enough" is NOT a valid reason to skip EP.

if ordered multi-step flow with dependencies → workflow_skill
if external tool calls at specific points → workflow_skill
if step order matters (reorder causes failure) → workflow_skill
if purely reference material (lookup, checklist) → reference_only
# reference_only = NO ordering constraint. Content can be consulted in any order.
# A methodology with "Step 1 → Step 2 → Step 3" where reordering breaks correctness
# is workflow_skill, even without Skill() calls or external tool orchestration.

# Consequence: workflow_skill + no EP → Warning minimum.
# Present cost-benefit (what skips EP would prevent, what restructuring costs) to user.
```

# Execution Procedure Pattern

How to structure workflow skills so agents execute multi-step procedures instead of absorbing them as knowledge.

## TOC

- [When to Detect](#when-to-detect)
- [The Pattern](#the-pattern)
- [Anti-Patterns](#anti-patterns)

## When to Detect

A skill needs an Execution Procedure when **any** of the following are true:
- It defines an **ordered, multi-step flow** (not just a list of checks)
- Steps have **dependencies** (step N requires output from step N-1)
- It uses **external tool calls** that must happen at specific points (e.g., `Skill()`, API calls)
- Step order matters — **skipping or reordering causes failure**

Skills that are purely reference material (lookup tables, style guides, validation checklists) do NOT need this pattern. "Purely reference" means no ordering constraints — content can be consulted in any order. A methodology with numbered steps where order matters is a workflow skill, even if the content reads like documentation.

## The Pattern

Nine components, all required for workflow skills:

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
        assert review_and_update_plan(plan_path, item, "processed")

        Skill("other-skill", item.path)           # explicit Skill() call
        assert review_and_update_plan(plan_path, item, "reviewed")

        assert done(item)
        review_and_update_plan(plan_path, item, "done")
```

### 2. Plan = Checklist

The runtime plan file IS the execution checklist. Not two separate concepts.

| Concept | Role |
|---------|------|
| **Procedure** (in SKILL.md) | Template — defines what steps exist |
| **Plan** (runtime file) | Instance — tracks progress through those steps |

The plan is created fresh each run with per-item sub-steps matching the `review_and_update_plan` boundaries:

```markdown
- [ ] 1. Item A
  - [ ] step-1-label    # matches first review_and_update_plan() call
  - [ ] step-2-label    # matches second
  - [ ] done
```

Plan sub-steps correspond 1:1 to `review_and_update_plan()` calls in the EP.

### 3. GATEs and Plan Progress

`assert` statements between dependent steps force completion before proceeding:

```python
write_plan(plan_path, data)
assert file_exists(plan_path)          # cannot proceed without plan
```

**`review_and_update_plan`** — GATEs applied to plan progress. The name IS the instruction: read the plan file, update the checkbox, assert success. Place at **major step boundaries only** — between phases that produce distinct deliverables, not between every sub-task.

```python
assert review_and_update_plan(plan_path, item, "step-1")   # after first major phase
assert review_and_update_plan(plan_path, item, "step-2")   # after second major phase
review_and_update_plan(plan_path, item, "done")             # final — no assert needed
```

**Where to place**: between steps that each take significant effort and produce a distinct result. If two steps always run back-to-back with no decision point between them, a single review_and_update_plan after both is sufficient.

### 4. Module References

Pseudocode references two kinds of targets:

```python
findings = validate_format(item)       # references/skill-format.md  (reference file)
findings = validate(item)              # see Validation section  (inline section)
template = read("references/templates.md")
```

**Reference file** — an independent module. Read the file and follow its three-layer structure: if it has an EP, follow the EP; if it only has content, read the content. Function name in parent aligns with the module's EP entry signature.

**Inline section** — an implementation block in the same file. The EP line says "see X section"; the section provides the domain knowledge that EP line needs.

Both are one hop from the EP line. No intermediate layer. No inline summary of a module's standards — the module's own EP is the authority.

**Sub-module EP = complete business flow.** Skills share one context window — the AI retains parent context when entering a sub-module. Sub-module EPs should own their entire domain: validate → gate → execute. Parent orchestrates sequence (when to call); sub-module owns domain logic (what to check, what to do).

### 5. EP Comment Discipline

EP pseudocode comments are **annotations**, not instructions. If removing a comment would change the EP's behavior, it is not a comment — it is pseudocode or section content in disguise.

**Allowed comments:**
- Reference pointer: `# references/X.md` or `# see Section Name`
- Constraint: `# exit non-zero → STOP`
- Calibrating hint (≤ 2 lines): helps the AI execute the adjacent EP line more accurately

**Not allowed as comments — extract to pseudocode or section:**
- Decision logic spanning 3+ lines (classification maps, dispatch tables)
- Inline summaries of what a sub-module checks
- Multi-line instructions the AI must follow

### 6. Step Granularity

When to split one EP step into two:

```
Does step B depend on step A's result (gate between them)?
  YES → two EP steps: A, assert, B
  NO  → one EP step, detail in section
```

A section can contain ordered sub-steps within one EP step (e.g., "fix critical, then fix warnings"). But if those sub-steps have independent gates, conditions, or Skill() calls that the parent EP needs to know about → elevate them to the EP.

**Corollary — categorize findings, not execution.** When one EP step produces multiple types of findings (e.g., structural issues, quality issues, publishing issues), don't split into separate EP steps per finding type. Run one pass, tag each finding by category. Categories organize the **report** (grouped findings for the user) and **fix priority** (which category to fix first), not the execution flow. Separate EP steps are only justified when a gate separates them.

### 7. Batch Principle

When an EP step processes multiple independent items (e.g., 30 validation checks), put them in **one section table** rather than 30 separate EP lines or 30 separate references. The AI reads the table once and processes all items — more efficient than navigating 30 individual modules.

Extract individual items to references only when an item has its own complex logic (multi-step EP, conditional branches, its own domain knowledge).

### 8. Non-Overlapping Ownership

When multiple EP steps touch the same type of target (e.g., two validation phases both checking reference files), each target must be **owned by exactly one step**. No file or artifact should be checked by two different steps for the same concern.

If two steps overlap on a target:
- **Consolidate** the checks into one step, or
- **Split by target**: each file type owned by one step (e.g., Step A owns SKILL.md, Step B owns all other files), or
- **Split by concern**: structural checks vs semantic checks — but only when a gate separates the two steps (Step A must pass before Step B starts)

### 9. Execution Procedure vs Content Separation

Both live in the same file (SKILL.md or reference), but in different formats. In the module model: EP is the interface, sections are the implementation.

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
| Two-hop references (step → intermediate section → reference file) | Information loss at each hop | One-hop: pseudocode → section or reference |
| Methodology explanation mixed with execution instructions | Agent absorbs execution as knowledge | Pseudocode at top, explanation below |
| Resumable plan files across runs | Stale state from previous context | Fresh plan each run |
| Plan update without `assert` wrapper | Skipped when conversation momentum carries forward | `assert review_and_update_plan()` — assert makes it mandatory |
| review_and_update_plan on every sub-task | High friction — agent starts skipping all of them | Major step boundaries only (distinct deliverables) |
| Parent EP summarizes sub-module standards inline | Agent uses summary, never enters sub-module — precision loss | Reference the module; its own EP is the authority |
| Decision logic as EP comments (3+ lines) | Looks optional, AI may skip comments | Convert to pseudocode (if/elif) or extract to section table |
