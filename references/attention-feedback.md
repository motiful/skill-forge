---
name: attention-feedback
description: Batch execution pattern for multi-item EP steps. Constrains batch size to match LLM's natural parallel agent capacity (~5), ensuring 1:1 agent-per-item across multiple rounds. Includes coverage floor assertion.
---

# Batch Execution Pattern

When an EP step processes N items and N > 5, execute in batches of up to 5. Each batch launches 1:1 agents in parallel, waits for completion, then starts the next batch. This works WITH the LLM's natural tendency to launch 3-5 parallel agents instead of fighting it.

## Execution Procedure

```
batch_validate(items, checks) → all_findings

for batch in chunk(items, 5):                    # at most 5 per round
    agents = [Agent(f"Check {item} against {checks}") for item in batch]
    run_parallel(agents)
    for item, agent in zip(batch, agents):
        assert agent.findings >= coverage_floor  # coverage check
        all_findings[item] = agent.findings

patterns = cross_item_analysis(all_findings)
return all_findings, patterns
```

## Why Batch Size 5

LLMs are trained on patterns where 3-5 parallel sub-agents are natural. When asked to launch 17 agents, they compress into 3-5 batches internally — losing the 1:1 guarantee. By constraining batch size to 5 and iterating, we get structural 1:1 within each batch.

## Coverage Floor

After each agent returns, assert that findings count meets a minimum (e.g., ≥ 50% of validation table rows). This catches agents that return shallow results without adding the complexity of row-by-row coverage tracking.

## When to Apply

- items > 5 and each item needs independent analysis
- Quality requires per-item attention isolation (sub-agents as attention pools)

## When NOT to Apply

- N ≤ 5: single batch, no iteration needed
- Items are trivially uniform (same check, same structure): batch processing is fine
- Time-critical tasks: sequential batching adds latency
