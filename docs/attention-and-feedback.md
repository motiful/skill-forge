# Attention, Control, and Feedback: Lessons from 9 Rounds of Skill Validation at Scale

What happens when you ask an AI agent to validate 17 skills instead of 1? It skips things. Not because it can't — because it won't. This article explains why, and what to do about it.

## Why Attention Matters

"Attention budget" is not our invention. [Anthropic coined the term](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) in September 2025: *"LLMs have an 'attention budget' that they draw on when parsing large volumes of context."*

What we discovered is how this plays out in practice — when you give an AI agent a structured procedure (an Execution Procedure, or EP) and ask it to apply that procedure to many items at once.

The industry has evolved through Prompt Engineering (2022-24), Context Engineering (2025), and now [Harness Engineering](https://www.anthropic.com/engineering/harness-design-long-running-apps) (2026). Attention isn't a new category alongside these — it's the **underlying physics** that explains why each engineering discipline works or fails.

When a skill loads into an AI agent's context, it's doing one thing: **directing the model's attention to domain-relevant knowledge, away from everything else the model could think about.** EP pseudocode, validation tables, reference files — they all serve the same purpose: allocating the model's finite attention budget to the right places.

## The Experiment

We used [skill-forge](https://github.com/motiful/skill-forge) to review [featbit-skills](https://github.com/featbit/featbit-skills), a collection of 17 agent skills for the FeatBit feature flags platform. Over 9 iterative test rounds (2026-03-26/27), we discovered a series of failure modes and designed fixes for each.

Each round revealed something the previous round didn't. The findings are not specific to skill-forge — they apply to any AI agent executing structured procedures on multiple items.

## Finding 1: EP Lines Are Attention Instructions

An EP is not a control flow diagram. It is an **attention budget allocation scheme**.

Every line of pseudocode tells the LLM: "right now, focus your attention HERE." The model already has the capability to plan, evaluate, and iterate. What it lacks is the discipline to allocate finite attention correctly when context grows.

```
Attention budget ≈ constant (Transformer architecture)

1 item:  budget / 1 = sufficient → every EP line gets executed
N items: budget / N = insufficient → some EP lines get graceful-skipped
```

This is not a capability gap. Claude Code natively supports plan-and-execute, self-evaluation, sub-agents, and iterative workflows. The model can do all of these things. The question is: **will it do all of them when attention is spread across 17 items?**

Consistently across 9 rounds: no. The model prioritizes completing the task over completing every step of the task.

## Finding 2: Graceful Skip

When the model skips EP lines under attention pressure, it's not malfunctioning. It's making a rational (if incorrect) tradeoff: "finishing the task" vs "finishing every step of the task." We call this **graceful skip** — the model gracefully degrades by dropping what it judges as lower-priority steps.

Implications:
- Adding more EP lines can actually REDUCE quality (more lines = more to skip)
- **EP is a budget, not a wishlist.** Every line competes for attention
- The most important checks should be EP lines; less important ones should be in tables (read on demand)

This behavior has been studied under names like "context rot" ([Chroma Research, 2025](https://www.trychroma.com/research/context-rot)) and "context anxiety" ([Cognition AI/Anthropic, 2026](https://inkeep.com/blog/context-anxiety)), but we haven't seen "graceful skip" as a term for EP-level instruction dropping. The phenomenon is well-documented at the context level; our contribution is identifying it at the instruction level.

## Finding 3: Knowledge and Control Are Inseparable

Early in the experiment, we tried to separate "knowledge" (what to check) from "control" (how to orchestrate). Put standards in the skill, put orchestration in scripts. It didn't work:

- You can't orchestrate without knowing what to orchestrate
- You can't apply knowledge without control flow to activate it at the right moment
- Every EP improvement that added better knowledge also improved control behavior

Both serve the same purpose: directing attention. Knowledge says "this matters"; control says "attend to it now."

**The resolution — compile-then-execute:**

> LLM's intelligence generates the control flow. Deterministic mechanism executes the control flow. Knowledge and control fuse during generation, separate during execution.

The LLM uses domain knowledge to DESIGN the right control flow. Once designed, the control flow runs mechanically. Intelligence is in the design phase; discipline is in the execution phase. This is how surgery works — plan the approach (intelligence), follow the protocol (discipline).

## Finding 4: Sub-Agents Are Attention Pools

Each `Agent()` call creates a new context window with a fresh attention budget. This is an **attention allocation strategy**, not just an orchestration mechanism.

```
Parent with 17 items: attention / 17 = thin
17 sub-agents with 1 item each: full attention × 17 = deep
```

Evidence from our tests:

| Agent setup | Tool uses per skill | Quality |
|-------------|-------------------|---------|
| 0 agents (parent does everything) | ~2 | Shallow, batch findings only |
| 3-6 agents (grouped) | ~5 | Moderate, some per-skill findings |
| 14 agents (70% 1:1) | ~15 for 1:1 agents | Deep, found structural alignment issues |

The agent with 23 tool uses (1:1) found checklist/body heading mismatches requiring line-by-line comparison. The agent with 1.4 tool uses (5-skill batch) only found surface-level formatting issues.

## Finding 5: Assert as Attention Checkpoint

`assert` in an EP creates a moment where the agent must evaluate a condition before proceeding. It's an **attention checkpoint** — forcing a pause that allocates attention to verification.

Effectiveness depends on standard clarity:

| Type | Example | Skip risk |
|------|---------|-----------|
| No assert | (step just runs) | High — no checkpoint |
| Semantic assert | `assert plan.is_well_structured` | Medium — rationalizable |
| Arithmetic assert | `assert count >= 17` | Low — non-negotiable |

Place asserts at phase boundaries only. Too many asserts compete for the same attention budget they're trying to protect.

**M × N delegation:** Coarse asserts (M items exist) in the parent where attention is scarce. Fine asserts (N checks per item) in sub-agents where attention is fresh. Each assert level matches the attention budget of its execution context.

## Finding 6: Minimum-Cost Feedback

Full adversarial review (independent evaluator agent) costs 20x per [Anthropic's harness experiments](https://www.anthropic.com/engineering/harness-design-long-running-apps). We found a cheaper alternative:

```
Agent returns findings →
  Check which validation-table rows are covered →
  Missing rows = attention failure →
  Retry ONLY the missing rows (tiny, focused prompt)
```

The retry is small enough that the model cannot fail to attend to it. Cost: one extra focused call per gap, not a full re-validation.

This connects to the commercial reality of AI agents: **attention quality × token cost × user willingness to pay.** Better attention allocation means better quality per token spent. Coverage feedback optimizes this ratio — maximum quality recovery for minimum additional token spend.

## Finding 7: The Abstraction Trap (Round 9)

In Round 9, we compressed 15 lines of explicit EP instructions into a one-line function call referencing a module. The result: complete regression. The AI didn't read the module and fell back to default batch behavior.

**The abstraction that saved tokens destroyed the attention guidance those tokens provided.**

This reveals a paradox: fewer EP lines = more attention per line, but also less guidance per line. The optimal EP is not the shortest or the longest — it's the one that provides maximum guidance per attention unit spent.

Practical rule: **critical mechanisms must be visible at the call site, not hidden in references.** References are for detail; the call site must carry enough information for correct behavior even if the reference is not read.

## The 9 Rounds

| Round | Fix Applied | Result | Key Learning |
|-------|-----------|--------|-------------|
| T1 | Baseline | 2W, batch | LLM collapses multi-item into batch |
| T2 | Discovery boundary | Temporal order fixed | `head -10` for frontmatter works |
| T3 | (Git history present) | Complete regression | Git diff = shortcut bypass |
| T4 | Ban git-diff shortcuts | 7W, quality returned | Without shortcuts, LLM does real work |
| T5 | "Read validation tables" | 1C+21W, 10x increase | Telling agents WHAT to check is critical |
| T6 | 3a/3b/3c split | EP assessment + cross-item patterns | Observe-then-act enables pattern detection |
| T7 | Plan count gate | 17 per-item entries, plan updated | Plan structure ≠ execution structure |
| T8 | Explicit Agent() calls | 14 agents (70% 1:1), deepest findings | Making Agent calls structural prevents batching |
| T9 | Compressed to one-liner | Regression to 3W | Abstraction removed attention guidance |
| T10 | Upfront read() + one-liner | 13 findings, 5 grouped agents | read() helps but can't replace explicit code |
| T11 | Restored explicit Agent() | 27 findings, 5 agents, best grouped | Explicit code > abstract calls, even with read() |
| T12 | Compile-then-execute manifest | 44 findings, 100% 1:1 | Manifest as assertable artifact (but not reproducible — T15 failed) |
| T13 | Simplified (removed guards) | Crashed | Each phase needs its own guard |
| T14 | Compressed guards (-18 lines) | 40 findings, 29% 1:1 | Guards resist compression |
| T15 | Same EP as T12 | 30 findings, 0% 1:1 | EP execution is stochastic — same EP, different results |
| T16 | **Batch of 5 + row-count assert** | **36 findings, 100% 1:1** | **Work WITH LLM's natural batch size, not against it** |
| T17 | Same batch approach | **3 patterns (covering 46 skills) + 7 per-skill, 100% 1:1** | **EP assessment found ALL 17 skills with expert judgment** |

## Finding 8: Manifest Works But Isn't Reproducible (Round 12, 15)

T12 introduced a compile-then-execute manifest — a concrete artifact listing each item + ALL validation table rows, executed by 1:1 agents. Result: 100% 1:1, 44 findings, EP assessment found.

But T15 used the EXACT same EP and got 0% 1:1, 30 findings. **EP execution is stochastic.** The manifest was a good idea but its success depended on the LLM choosing to follow it — which it doesn't always do.

## Finding 9: Batch of 5 — Simple, Reliable, Reproducible (Round 16-17)

The final breakthrough. Instead of fighting the LLM's tendency to batch items into 3-5 agents, **work with it**: process items in batches of up to 5, each batch launches 1:1 agents, wait for completion before next batch.

```python
for batch in chunk(plan.items, 5):          # at most 5 per round
    agents = [Agent(f"Validate {item}...") for item in batch]
    run_parallel(agents)                     # 5 agents, naturally 1:1
    collect(agents)                          # wait before next batch
```

**Why it works:** LLMs are trained on patterns where 3-5 parallel agents are natural. Asking for 17 agents triggers compression. Asking for 5 is within the natural range — no compression needed.

**Verified over 2 consecutive runs (T16 + T17):** both achieved 100% 1:1 with 4 batches of 5+5+5+2. T17 additionally found EP assessment for all 17 skills with expert-level judgment.

**This is 13 lines of EP vs the manifest's 35 lines — simpler and more reliable.**

## Finding 10: Guards Are Per-Phase, Not Global (Round 13-14)

T13 removed guards from STEP 1 and STEP 2, reasoning that later mechanisms would compensate. It crashed. T14 compressed guards; quality dropped.

**Each phase of an EP needs its own attention guard.** A guard in STEP 3 cannot protect STEP 1, because STEP 1 executes first. Guards are temporal — they protect the moment they appear in.

**You cannot simplify by merging guards across phases.** Each guard is bound to a specific moment in the execution timeline.

## Three Principles

17 rounds produced many EP-specific fixes, but three principles have lasting, generalizable value:

### Principle 1: Batch to Match Natural Capacity

When N items > 5, process in batches of up to 5 with 1:1 agent-per-item within each batch. Wait for completion before the next batch. This works WITH the LLM's trained parallel capacity (~3-5 agents) instead of fighting it.

**Why not just "one agent per item"?** Because instructing the LLM to launch 17 agents is an instruction it can choose to ignore. Batching into groups of 5 makes 1:1 the natural behavior, not a forced constraint.

### Principle 2: Assert on Output Length, Not on Specific Items

Don't cherry-pick which checks to name in the agent prompt ("check EP and graceful skip"). Instead:
- Tell the agent: "check every row in the validation tables"
- Assert: `len(findings) >= len(validation_table_rows)`

The length comparison is universal. Cherry-picking implies unlisted checks are optional.

### Principle 3: Phase Guards — Each Step Protects Itself

Every phase of an EP needs its own boundary constraint. A guard in a later phase cannot protect an earlier phase, because execution is sequential. Guards are temporally bound.

**Common phase guards:**
- Discovery: "read paths and frontmatter ONLY, no content, no git history"
- Plan: "per-item structure"
- Execution: batch of 5, row-count assert

**You cannot simplify by merging guards across phases.** T13 and T14 proved this.

## What Persists, What Fades

**Principles (permanent — as long as attention is finite):**
- Batch to match natural capacity (5 items per round)
- Assert on output length, not specific items
- Phase guards: each step protects itself

**Implementation (temporary — will evolve with models and platforms):**
- Specific BOUNDARY comment wording
- Batch size (5 might change as models evolve)
- Assert threshold

**What the attention lens clarifies:**
- LLM autonomy vs external control = who allocates the attention budget
- Prompt vs Context vs Harness Engineering = managing attention at different scales
- Skill quality = how effectively the skill directs model attention to the right domain knowledge
- Commercial viability of AI agents = attention quality × token cost × user willingness to pay

---

## References

- [Anthropic: Effective Context Engineering for AI Agents (Sep 2025)](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — "attention budget" origin
- [Anthropic: Harness Design for Long-Running Apps (Mar 2026)](https://www.anthropic.com/engineering/harness-design-long-running-apps) — generator-evaluator, context anxiety
- [Chroma Research: Lost in the Middle (Jul 2025)](https://www.trychroma.com/research/context-rot) — U-shaped attention degradation
- [Cognition AI: Context Anxiety (2026)](https://inkeep.com/blog/context-anxiety) — model premature wrap-up
- [LIFBench: Instruction Following in Long Contexts (2024)](https://arxiv.org/abs/2411.07037) — quantified degradation
- [ICLR 2025: When Attention Sink Emerges](https://arxiv.org/abs/2410.10781) — positional attention bias

---

*Discovered through iterative testing of [skill-forge](https://github.com/motiful/skill-forge) on [featbit-skills](https://github.com/featbit/featbit-skills), March 2026.*
