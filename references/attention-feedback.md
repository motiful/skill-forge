---
name: attention-feedback
description: Validate-check-retry pattern for multi-item EP execution. Detects graceful skip via coverage checking, retries only missing validation rows. Applies when items × checks exceeds a single agent's attention budget.
---

# Attention Feedback Pattern

Feedback loop that detects and corrects attention failures in multi-item validation. Each item gets an independent attention pool (sub-agent); coverage is checked after each returns; gaps trigger focused retry.

## Execution Procedure

```
validate_with_feedback(items, checks) → all_findings, patterns

# Phase A: validate each item (parallel, independent attention pools)
for item in items:
    findings[item] = Agent(f"Validate {item} against {checks}")

    # Phase A+: coverage feedback (per-item, immediate)
    covered = extract_covered_checks(findings[item])
    missing = checks - covered
    if missing:
        extra = Agent(f"Check ONLY {missing} for {item}")
        findings[item].merge(extra)
    assert len(findings[item]) > 0

# Phase B: cross-item analysis (parent context, all findings visible)
patterns = cross_item_analysis(findings)

return findings, patterns
```

## Coverage Check

After each agent returns, count which validation table rows appear in the findings. A row is "covered" if the findings explicitly reference it — either as a PASS or as a finding with severity.

```
covered = {row for row in checks if any finding references row}
missing = checks - covered
```

If `missing` is non-empty, the agent skipped those checks (graceful skip due to attention scarcity). Retry with a focused prompt that names ONLY the missing rows.

## Why Focused Retry Works

The retry prompt is tiny — one or two specific checks. A single check is small enough that the agent cannot fail to attend to it. Cost is one extra focused call per gap, not a full re-validation.

## Feedback Levels

| Level | When | What | Cost |
|-------|------|------|------|
| Per-item coverage check | After each agent returns | Count covered rows | Lowest — arithmetic |
| Missing-row retry | When coverage < expected | Re-validate specific gaps | Low — focused prompt |
| Cross-item pattern check | After all items validated | Aggregate, find collection-wide gaps | Medium — one pass |
| Full adversarial review | When stakes are highest | Independent evaluator agent | High — separate session |

For most workflows, Levels 1-3 are sufficient.

## When NOT to Apply

- Single-item tasks (N=1): no attention scarcity
- Simple checks (M < 5): unlikely to have coverage gaps
- Time-critical tasks: retry adds latency
- Tasks where partial coverage is acceptable
