---
name: execution-procedure
description: Pseudocode + plan-as-checklist + GATE assertion pattern for structuring workflow skills. Defines when a skill needs an Execution Procedure, covers nine core components (pseudocode, plan-as-checklist, GATE, module references, EP comment discipline, step granularity, batch principle, non-overlapping ownership, EP vs content separation), five attention principles (observe-then-act, attention budget, batch execution, assert as checkpoint, phase output as rigid artifact), and common anti-patterns.
---

# Execution Procedure Pattern

How to structure workflow skills so agents execute multi-step procedures instead of absorbing them as knowledge.

## Execution Procedure

```
assess_procedure_need(skill_md) → needs_ep (default) | reference_only (exemption)

# Default: every skill gets an EP.
# EP forces execution fidelity — agents follow steps instead of absorbing
# them as knowledge. The burden of proof is on NOT having EP.

default → needs_ep
if purely reference material (no ordering constraint) → reference_only
# reference_only = content can be consulted in any order.
# A methodology with "Step 1 → Step 2 → Step 3" where reordering breaks correctness
# is NOT reference_only, even without Skill() calls or external tool orchestration.

# NOT valid exemptions:
# - "Natural language steps are clear enough"
# - "Skill isn't complex enough"
# - "Functional workflow format, works correctly without EP"
# - "Steps are already numbered and readable"
# These are all forms of graceful skip. If it has steps, it gets EP.

# Consequence: no EP + no valid exemption → Warning, must fix.
```

## TOC

- [Default: Every Skill Gets EP](#default-every-skill-gets-ep)
- [The Pattern](#the-pattern)
- [Anti-Patterns](#anti-patterns)

## Default: Every Skill Gets EP

**EP is the default.** Every skill has an Execution Procedure unless it qualifies for the single exemption below.

**Exemption: purely reference material.** Lookup tables, style guides, data catalogs — content with no ordering constraints, consultable in any order. If removing or reordering any section would change the skill's correctness, it is NOT purely reference.

**Common signals that confirm EP is needed** (non-exhaustive):
- Ordered, multi-step flow (not just a list of checks)
- Steps have dependencies (step N requires output from step N-1)
- External tool calls at specific points (`Skill()`, API calls, script execution)
- Step order matters — skipping or reordering causes failure

These signals are **confirmations**, not prerequisites. A skill does not need to match any of these to require EP — EP is the default. It only needs to match the exemption to NOT have EP.

## The Pattern

Nine core components (§1-9) plus five attention principles (§10-14) for workflow skills:

### 1. Pseudocode Procedure

Python-like pseudocode under a `## Execution Procedure` heading. Both SKILL.md and reference files use this same heading — the heading is the identifier, not position.

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

**Signature naming convention:**
- Use descriptive verb (or compound verb for multi-step): `discover_and_classify`, `detect_and_create`, `validate_and_apply` — not `lookup`, `check`, `run`
- Declare explicit result type: `→ installed | blocked`, `→ rule_skill_spec | nothing` — not `→ bool`, `→ result`
- Multi-step flows use compound verbs: `validate_and_apply` (not just `validate` when it also applies)
- Name should tell the caller what happens without reading the body

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

**Decision-layer reference or 100% skip.** A reference that is not called from the EP (via function call or explicit `read()`) will never be read during execution — regardless of how valuable its content is. Listing a reference in a `## References` index or mentioning it in prose is NOT a decision-layer reference. Only EP pseudocode function calls and `read()` instructions cause the agent to actually enter the module. Consequence: when adding a reference, always add a corresponding EP call. When auditing, any reference without an EP call is dead code. **Field-level resolvability** — same rule at the data field level. Every field in EP pseudocode (`answers.X`, `context.Y`, `brief.Z`) must have a documented inference source in the same reference file or an adjacent Signal Inference section. A field without an inference rule defaults to "AI will figure it out" = graceful skip = dead branch. When adding a field reference, add a corresponding inference rule; when auditing, any field without inference documentation is a must-fix. See `references/anti-graceful-skip.md` §Principle 5.

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

### 10. Observe-Then-Act in Parallel Workflows

When an EP delegates work to parallel sub-agents (e.g., validating N items), separate the observation phase from the action phase:

```
# Phase A: gather (parallel, no side effects)
for item in items:
    findings[item] = observe(item)     # agents return data, do NOT act

# Phase B: aggregate (parent, full picture)
patterns = cross_item_analysis(findings)

# Phase C: act (after user sees full picture)
for item in items:
    fix(item, findings[item], patterns)
```

**Why:** When observation and action are mixed in a single parallel loop, each agent acts in isolation — it never sees findings from sibling agents. Collection-wide patterns (terminology drift, missing conventions, inconsistent depth) go undetected because no single agent has the full picture.

**When to apply:** Any EP step that processes multiple independent items in parallel AND needs cross-item consistency. If items are truly independent with no need for cross-comparison, a single-phase loop is fine.

**Isomorphic for N=1:** Phase B becomes a no-op — same behavior as a single-phase loop, zero overhead.

### 11. Attention Budget

Every EP line competes for the agent's finite attention. More lines = less attention per line. Design EPs with this budget in mind: high-priority checks as EP lines, lower-priority checks in tables (read on demand).

### 12. Batch Execution for Multi-Item Steps

When N items > 5, process in batches of up to 5 with 1:1 agent-per-item within each batch. Wait for completion before starting the next batch. This works with the LLM's natural capacity (~3-5 parallel agents) instead of fighting it.

### 13. Assert as Attention Checkpoint

`assert` creates a moment where the agent must evaluate a condition before proceeding. Without it, the agent flows from step to step without verifying. The assert forces a pause — and that pause IS the attention allocation.

**Assert effectiveness depends on standard clarity:**

| Type | Example | Skip risk | Why |
|------|---------|-----------|-----|
| No assert | (step just runs) | High | No checkpoint, no pause |
| Semantic assert | `assert plan.is_well_structured` | Medium | Agent can rationalize "yes it is" |
| Arithmetic assert | `assert count >= 17` | Low | Number comparison is non-negotiable |

**Placement:** Assert at phase boundaries only (between major steps). Too many asserts compete for the same attention budget they're trying to protect.

**M × N delegation:** Coarse asserts (M items exist) belong in the parent EP where attention is scarce. Fine asserts (N checks per item covered) belong in sub-modules where attention is fresh. Each assert level matches the attention budget of its execution context.

### 14. Phase Output as Rigid Artifact

When a workflow transitions between phases with different cognitive demands (assess → modify, validate → fix, plan → execute), Phase N's output must be a **concrete, enumerable artifact** that Phase N+1 consumes mechanically.

```
Phase N (intelligence)  →  Rigid Artifact  →  Phase N+1 (mechanics)
validate(items)         →  plan.fix_actions →  execute(actions)
discover(target)        →  items[]          →  validate(items)
assess(findings)        →  plan.checklist   →  fix(checklist)
```

**Why:** Phase N+1 typically has MORE context pressure (it carries N's context plus its own work). Re-interpreting intent under higher pressure → graceful skip. A concrete artifact removes interpretation.

**Requirements for the rigid artifact:**
1. **Enumerable** — each item in the artifact maps to exactly one action in the next phase
2. **Assertable** — `assert artifact.count >= expected` verifies completeness at the boundary
3. **Self-contained** — the next phase reads the artifact, not the original context that produced it

**When to apply:** Any EP with phases that have different cognitive demands. If Phase N reads and Phase N+1 writes, a rigid artifact MUST bridge them. If both phases are read-only or both write, a rigid bridge is optional.

**HITL boundaries are stricter.** When the phase transition passes through a human (report → user decision → next phase), the artifact doubles as the user's decision surface. Summary-level output ("N issues found") forces bulk approve/reject — the user cannot judge individual items. Per-item output (one row per finding) lets the user accept, reject, or modify each one. If the user cannot enumerate what they approved, the approval is meaningless.

**Failure modes without rigid artifact:**
| Phase boundary | Weak artifact | What happens |
|---------------|--------------|--------------|
| AI → AI (validate → fix) | Prose summary of findings | Fix phase re-interprets, drops items it finds hard to address |
| AI → Human (report → approval) | Per-group counts | User approves blind — cannot distinguish systemic issues from typos |
| Human → AI (approval → execute) | Vague "fix what was found" | Execute phase picks easy items, skips complex ones |

**Relationship to other principles:**
- Generalizes #12 (Batch Execution) — batch execution is one form of rigid artifact (the manifest)
- Complements #10 (Observe-Then-Act) — observation produces the artifact, action consumes it
- Enables #13 (Assert as Attention Checkpoint) — the artifact is what gets asserted against

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
| Opt-in EP framing ("does this need EP?") | Agent finds reasons to skip — "works correctly", "steps are clear enough" | Opt-out framing: EP is default, exemption requires proof of no ordering constraints |
| Flagging missing EP then accepting it | Warning exists but reviewer soft-skips the fix — "functional, keep as-is" | No EP + no valid exemption = must fix, not "accepted" |
