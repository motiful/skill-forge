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
| T12 | **Compile-then-execute manifest** | **44 findings, 100% 1:1, EP+graceful skip found** | **Manifest as assertable intermediate artifact** |
| T13 | Simplified (removed guards) | Crashed — read all bodies, ran git log | **Each phase needs its own guard** |
| T14 | Compressed guards (-18 lines) | 40 findings, 29% 1:1 | Guards work compressed but less effectively |

## Finding 8: Compile-Then-Execute (Round 12)

The breakthrough. Instead of telling agents "validate this skill" (which they interpret freely), we added an intermediate step: **compile a validation manifest first, then execute it.**

```
STEP 3a: Compile manifest — for each item, list its path + ALL validation table rows
         assert len(manifest) >= len(items)
         assert all checks are ALL_ROWS (no filtering)

STEP 3b: Execute manifest — one Agent per manifest entry, prompt includes EXACT check list

Coverage: compare findings against manifest → retry missing rows
```

The manifest is a **visible, assertable artifact** between the "intelligence" phase (deciding what to check) and the "discipline" phase (executing the checks). T12 achieved 100% 1:1 agents and found EP assessment + graceful skip detection for the first time — because each agent's prompt listed the EXACT checks to run.

## Finding 9: Guards Are Per-Phase, Not Global (Round 13-14)

T13 removed guards from STEP 1 and STEP 2, reasoning that the manifest in STEP 3 would compensate. It crashed — the AI read all SKILL.md bodies in STEP 1 and ran git log before the manifest even existed.

T14 compressed guards (same constraints, fewer words). Quality dropped from 100% to 29% 1:1.

**Each phase of an EP needs its own attention guard.** A guard in STEP 3 cannot protect STEP 1, because STEP 1 executes before STEP 3 exists. Guards are temporal — they protect the moment they appear in, not the moments after.

This also means: **you cannot simplify an EP by merging guards.** Each guard is bound to a specific moment in the execution timeline. Removing it opens a gap at that moment, regardless of what comes later.

## Three Principles (What to推广)

The 14 rounds produced many EP-specific fixes, but only three principles have lasting, generalizable value:

### Principle 1: Granularity — One Agent, One Item

When a task has N items to process, each item must get its own attention pool (sub-agent). Batching N items into one agent divides attention by N, causing graceful skip of lower-priority checks.

**The trigger:** items × checks > single-agent attention budget.
**The fix:** spawn N agents, each processing exactly one item.

### Principle 2: Compile-Then-Execute — Manifest as Contract

Before executing, generate a concrete, inspectable intermediate artifact (manifest/checklist) that lists exactly what each agent must do. Then execute the manifest mechanically.

**Why it works:**
- The manifest is assertable (count items, verify check completeness)
- The agent prompt includes EXACT checks (no interpretation needed)
- Coverage feedback compares findings against the manifest (not against vague expectations)

> LLM's intelligence generates the control flow. Deterministic mechanism executes the control flow. Knowledge and control fuse during generation, separate during execution.

### Principle 3: Phase Guards — Each Step Protects Itself

Every phase of an EP needs its own boundary constraint. A guard in a later phase cannot protect an earlier phase, because execution is sequential. Guards are temporally bound.

**Common phase guards:**
- Discovery: "read paths and frontmatter ONLY, no content, no git history"
- Plan: "per-item structure, assert count"
- Execution: manifest assert, agent-per-item, coverage feedback

**You cannot simplify by merging guards across phases.** T13 and T14 proved this.

## What Persists, What Fades

**Principles (permanent — as long as attention is finite):**
- Granularity: one agent, one item
- Compile-then-execute: manifest as contract
- Phase guards: each step protects itself
- Coverage feedback: detect and retry attention failures

**Implementation (temporary — will evolve with models and platforms):**
- Specific BOUNDARY comment wording
- Plan template format
- Manifest JSON structure
- Assert placement

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
