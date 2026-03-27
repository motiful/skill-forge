# Attention, Control, and Feedback: Lessons from 8 Rounds of Skill Validation at Scale

What happens when you ask an AI agent to validate 17 skills instead of 1? It skips things. Not because it can't — because it won't. This article explains why, and what to do about it.

## The Experiment

We used skill-forge to review [featbit-skills](https://github.com/featbit/featbit-skills), a collection of 17 agent skills for the FeatBit feature flags platform. Over 8 iterative test rounds (2026-03-26/27), we discovered a series of failure modes and designed fixes for each. The final version produced 4 Critical + 20 Warning findings with per-skill granularity and cross-item pattern detection.

Each round revealed something the previous round didn't. The findings are not specific to skill-forge — they apply to any AI agent executing structured procedures on multiple items.

## Finding 1: EP = Attention Budget Allocation

An Execution Procedure (EP) is not a control flow diagram. It is an **attention budget allocation scheme**.

Every line of pseudocode tells the LLM: "right now, focus your attention HERE." The model already has the capability to plan, evaluate, and iterate. What it lacks is the discipline to allocate finite attention correctly when context grows.

**Why EP works for 1 item but degrades for N items:**

```
Attention budget ≈ constant (Transformer architecture)

1 item:  budget / 1 = sufficient → every EP line gets executed
N items: budget / N = insufficient → some EP lines get graceful-skipped
```

This is not a capability gap. Claude Code natively supports plan-and-execute, self-evaluation, sub-agents, and iterative workflows. The model can do all of these things. The question is: **will it do all of them when attention is spread across 17 items?**

The answer, consistently across 8 rounds: no. The model prioritizes completing the task over completing every step of the task. This is a training artifact — models are rewarded for producing comprehensive responses in a single turn, not for methodically following checklists.

## Finding 2: Knowledge and Control Are Inseparable

Early in the experiment, we tried to separate "knowledge" (what to check) from "control" (how to orchestrate the checking). Put standards in the skill, put orchestration in scripts.

This doesn't work. Here's why:

- You can't orchestrate without knowing what to orchestrate. A bash `for` loop doesn't know which skills have references that need separate validation.
- You can't apply knowledge without control flow to activate it at the right moment. Validation tables are useless if no control flow triggers reading them.
- Every EP improvement that added better knowledge also improved control behavior. They're the same thing.

**The resolution — compile-then-execute:**

> LLM's intelligence generates the control flow. Deterministic mechanism executes the control flow. Knowledge and control fuse during generation, separate during execution.

The LLM uses its domain knowledge to DESIGN the right control flow — what to check, in what order, with what criteria. Once designed, the control flow runs mechanically. Intelligence is in the design phase; discipline is in the execution phase.

This is how surgery works. A surgeon plans the approach (intelligence), then follows the protocol (discipline), making judgment calls only at predefined decision points.

## Finding 3: Sub-Agents Are Attention Pools

Each `Agent()` call creates a new context window with a fresh attention budget. This is not just an orchestration mechanism — it is an **attention allocation strategy**.

```
Parent with 17 items: attention / 17 = thin
17 sub-agents with 1 item each: full attention × 17 = deep
```

The parent's job is not to analyze — it's to **allocate attention** by spawning focused sub-agents. Evidence from our tests:

| Agent setup | Tool uses per skill | Quality |
|-------------|-------------------|---------|
| 0 agents (parent does everything) | ~2 | Shallow, batch findings only |
| 3 agents (6+6+5 skills each) | ~5 | Moderate, some per-skill findings |
| 14 agents (12×1 + 1×5) | ~15 for 1:1 agents | Deep, found checklist/body alignment issues |

The agent with 23 tool uses (dotnet, 1:1) found structural issues that required line-by-line comparison of checklist entries against body headings. The agent with 1.4 tool uses (5-skill batch) only found surface-level issues like description formatting.

## Finding 4: The Three Problems Are One Problem

Skill-forge is solving:

- **Attention management**: EP directs the model's finite attention to the right checks
- **Knowledge encoding**: Validation tables define what "good" means
- **Feedback design**: Detecting when attention failed and correcting it

These are not three separate concerns. They are one problem at three scales:

```
Knowledge defines WHAT to check →
  EP allocates attention to check it →
    Feedback detects when attention failed →
      Retry focuses attention on the gap →
        (Knowledge defines what the gap check should look for)
```

Every feedback loop requires knowledge (to know what's missing) and attention management (to focus the retry). Every knowledge item requires attention management (to ensure it's actually read) and feedback (to verify it was applied).

## Finding 5: Minimum-Cost Effective Feedback

Full adversarial review (independent evaluator agent) costs 20x per Anthropic's harness experiments. We found a cheaper alternative:

```
Agent returns findings →
  Check which validation-table rows are covered →
  Missing rows = attention failure →
  Retry ONLY the missing rows (tiny, focused prompt)
```

The retry prompt is small enough that the model cannot fail to attend to it. Cost: one extra focused call per gap, not a full re-validation.

This works because the "checker" doesn't need intelligence — it needs arithmetic. Count covered rows, subtract from expected rows, report the diff. The intelligence is in the original validation and in the focused retry.

## Finding 6: Graceful Skip Is Not a Bug

When the model skips EP lines under attention pressure, it's not malfunctioning. It's making a rational (if incorrect) tradeoff: "finishing the task" vs "finishing every step of the task." The training signal rewards the former.

This means:
- Adding more EP lines can actually REDUCE quality (more lines = more to skip)
- Making EP lines shorter and higher-priority is better than making them comprehensive
- The most important checks should be EP lines; less important ones should be in tables (read on demand)

The practical implication: **EP is a budget, not a wishlist.** Every line competes for attention. Add lines that matter; remove lines that don't pull their weight.

## The 8 Rounds

| Round | Fix Applied | Result | Key Learning |
|-------|-----------|--------|-------------|
| T1 | Baseline (batch everything) | 2W, no per-skill findings | LLM collapses multi-item into batch |
| T2 | Discovery boundary (frontmatter only) | Temporal order fixed, 4 grouped agents | Boundary works — head -10 for frontmatter |
| T3 | (No new fix, git history present) | Complete regression, 0 agents | Git diff created shortcut bypass |
| T4 | Ban git-diff shortcuts | 7W, quality returned | Without shortcuts, LLM does real work |
| T5 | "Read validation tables" instruction | 1C+21W, 10x findings increase | Telling agents WHAT to check is critical |
| T6 | 3a/3b/3c split (observe-then-act) | EP assessment appeared, 3 cross-item patterns | Separating validate from fix enables pattern detection |
| T7 | Plan count gate, per-item plan entries | 17 per-item entries, plan updated with results | Plan structure improved but agents still grouped |
| T8 | Explicit Agent() in pseudocode | 14 agents (70% 1:1), deepest per-skill findings | Making Agent calls structural prevents batching |

## What Persists, What Fades

**Persists (as long as Transformers have finite attention):**
- EP as attention management
- Sub-agents as attention pools
- Coverage feedback loops
- Domain knowledge in skills (what to check, what's important)

**Fades (as platforms and models improve):**
- Specific EP constraint workarounds (boundary comments, count gates)
- Manual "don't skip" instructions
- 1:1 agent enforcement (models will self-decompose better)

**The lasting investment:** Knowledge (validation standards) and architectural patterns (observe-then-act, compile-then-execute, coverage feedback). Not EP line-level tweaks.

## Implications Beyond Skill-Forge

This applies to any AI agent doing structured work on multiple items:
- Code review across many files
- Deployment verification across many services
- Documentation audits across many pages
- Test coverage analysis across many modules

The pattern: when items × checks > attention budget → allocate independent attention pools + coverage feedback + focused retry.

---

*Discovered through iterative testing of [skill-forge](https://github.com/motiful/skill-forge) on [featbit-skills](https://github.com/featbit/featbit-skills), March 2026.*
