---
name: attention-feedback
description: Attention budget management and feedback loop design for EP execution. Defines why EPs degrade at scale (attention scarcity, not capability gap), the validate-check-retry pattern for detecting graceful skip, and the compile-then-execute principle for knowledge-control fusion. Applies to any EP that processes multiple items.
---

# Attention Management and Feedback Design

How to prevent graceful skip in multi-item EP execution, and how to design feedback loops that detect and correct attention failures at minimum cost.

## Execution Procedure

```
validate_with_feedback(items, checks) → all_findings, patterns

# Phase A: validate each item (parallel, independent attention pools)
for item in items:
    findings[item] = validate(item, checks)          # one agent per item = fresh attention

    # Phase A+: coverage feedback (per-item, immediate)
    covered = extract_covered_checks(findings[item])
    missing = checks - covered
    if missing:
        extra = validate_focused(item, missing)      # retry with focused attention
        findings[item].merge(extra)

# Phase B: cross-item analysis (parent context, all findings visible)
patterns = cross_item_analysis(findings)

return findings, patterns
```

## Core Principles

### 1. EP = Attention Budget Allocation

An EP is not a control flow diagram. It is an **attention budget allocation scheme**.

Every line of pseudocode tells the LLM: "right now, focus your attention HERE." The model already has the capability to plan, evaluate, and iterate — what it lacks is the discipline to allocate finite attention correctly when context is large.

**Why EP works for 1 item but degrades for N items:**

```
Attention budget ≈ constant (bounded by context window and Transformer architecture)

1 item:  budget / 1 = sufficient → every EP line gets executed
N items: budget / N = insufficient → some EP lines get graceful-skipped
```

This is architectural (Transformer attention), not a capability gap. It will not be "fixed" by better models as long as models use attention-based architectures. It CAN be mitigated by creating independent attention pools (sub-agents).

### 2. Knowledge and Control Are Inseparable

Knowledge (what to check) and control (when/how to check) cannot be separated into different layers. Evidence:

- Every EP improvement that added knowledge also improved control behavior
- You cannot orchestrate without knowing what to orchestrate
- You cannot apply knowledge without control flow to activate it at the right moment

**The compile-then-execute principle resolves this:**

> LLM's intelligence generates the control flow. Deterministic mechanism executes the control flow. Knowledge and control fuse during generation, separate during execution.

The LLM uses its knowledge to DESIGN the right control flow (what to check, in what order, with what criteria). Once designed, the control flow runs mechanically. Intelligence is in the design phase; discipline is in the execution phase.

### 3. Minimum-Cost Effective Feedback

The cheapest feedback that catches attention failures:

```
Agent returns findings → check which validation-table rows are covered
→ missing rows = attention failure → retry ONLY the missing rows
→ retry prompt is tiny (one specific check) → attention budget sufficient
```

**Why this works:** The retry is scoped to a single missing check. A single check is small enough that the model cannot fail to attend to it. The cost is one extra focused call per gap, not a full re-validation.

**Feedback levels (from cheapest to most expensive):**

| Level | When | What | Cost |
|-------|------|------|------|
| Per-item coverage check | After each agent returns | Count covered validation rows | Lowest — arithmetic |
| Missing-row retry | When coverage < expected | Re-validate specific missing checks | Low — focused prompt |
| Cross-item pattern check | After all items validated | Aggregate, find collection-wide gaps | Medium — one pass |
| Full adversarial review | When stakes are highest | Independent evaluator agent | High — separate session |

For most workflows, Levels 1-3 are sufficient. Level 4 (independent evaluator) is needed only when self-review with checklist is insufficient — typically when the evaluation criteria themselves are subjective.

### 4. Sub-Agents as Attention Pools

Each Agent() call creates a **new context window** with a fresh attention budget. This is not just an orchestration mechanism — it is an attention allocation strategy.

```
Parent with 17 items: attention / 17 = thin
17 sub-agents with 1 item each: full attention × 17 = deep
```

The parent's job is not to analyze — it's to allocate attention by spawning focused sub-agents. The parent's own attention budget goes toward orchestration (launching agents, checking coverage, aggregating results), not analysis.

### 5. The Pattern Is Reusable

This pattern applies to any EP step that processes multiple independent items:

- Skill validation (check N skills against M criteria)
- Code review (check N files against M standards)
- Deployment verification (check N services against M health criteria)
- Documentation audit (check N docs against M quality rules)

The invariant: items × checks > attention budget → spawn sub-agents + feedback loop.

## When NOT to Apply

- Single-item tasks (N=1): feedback loop is overhead with no benefit
- Simple checks (M < 5): unlikely to have coverage gaps
- Time-critical tasks: retry adds latency
- Tasks where partial coverage is acceptable

## Origin

Discovered through 8 iterative test rounds of skill-forge reviewing a 17-skill collection (featbit-skills, 2026-03-26/27). Each round revealed a different failure mode of EP execution at scale, leading to the principles above.
