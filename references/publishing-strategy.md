---
name: publishing-strategy
description: Three publishing models (Skill, Collection, In-Repo) with decision framework and directory standards. Covers single-skill repo structure, collection multi-skill structure, in-repo skill placement, graduation path, and npx skills add discovery priority.
---

# Publishing Strategy

## Execution Procedure

```
decide(skills_to_publish) → publishing_model

# Dimension C (Publishing) only. Does NOT assess entry (A) or dependency (B).
# Upstream decisions (which skills to create, how they depend) must be settled
# before calling this function.

if only for this repo's maintainers → in-repo (.claude/skills/)
if len(skills) == 1 → skill repo (default)
if len(skills) >= 2:
    if skills must ship together (any graft / fork must get all) → collection repo
    if skills can ship independently → separate skill repos + declared dependencies
```

## TOC

- [Terminology](#terminology)
- [Skill (Single Repo)](#skill-single-repo)
- [Collection (Multi-Skill Repo)](#collection-multi-skill-repo)
- [Protocol Skill — Orthogonal Dimension](#protocol-skill--orthogonal-dimension-installation-side-effects)
- [In-Repo (Not Independently Published)](#in-repo-not-independently-published)
- [Decision Framework](#decision-framework)
- [Directory Standards](#directory-standards)

## Terminology

| Term | Definition | Repo naming |
|------|-----------|------------|
| **Skill** | One capability, one repo. The atomic unit. | `<org>/<skill-name>` |
| **Collection** | Multiple skills in one repo. Simpler but skills are locked together. | `<org>/<domain>-skills` |
| **Protocol Skill** | A skill whose real value is delivered by a setup script that modifies the host environment. Publishing-model orthogonal (can be Single or Collection). | same as underlying publishing model |

Use these terms in conversation with the user. Avoid jargon like "monorepo" or "hybrid."

## Skill (Single Repo)

One skill, one GitHub repo. This is Skill-Forge's default output.

**Structure:**
```
<org>/<skill-name>/
├── SKILL.md              # skill content (at root)
├── references/            # if needed
├── scripts/               # if needed
├── README.md
├── LICENSE
└── .gitignore
```

**Install:** `npx skills add <org>/<skill-name>`

**Best for:**
- Independent, self-contained skills
- Social media promotion (one link = one skill)
- Community discovery (own GitHub stars, own SEO)
- Low install friction (user evaluates one thing)

### Dependencies

If a skill has dependencies (other skills, CLI tools, npm packages), declare them properly:

- **In SKILL.md Step 0**: declare dependencies, run `scripts/setup.sh`
- **In README**: add a "Dependencies" section listing what gets installed
- **In `scripts/setup.sh`**: check and install each dependency

See `references/installation.md` for the full setup.sh standard.

## Collection (Multi-Skill Repo)

Multiple skills in one GitHub repo. Used when skills are always consumed together.

Collections come in two flavors:

### Augmented Skill (主 + 加强器)

One **primary capability** skill plus N **augmenting** skills (typically rule-skills, sometimes micro-capabilities). The outward identity is the primary capability — users say "I'm using design-playbook", not "I'm using the design-playbook collection". The augmenters enhance the primary without being independently useful.

**Characteristics**:
- One primary skill, N ≥ 1 augmenters
- Augmenters have **maintenance dependency** on the primary (they exist to constrain or assist the primary's iteration)
- Outward branding = primary skill name
- Directory: `<primary-name>-skills/` or similar (GitHub repo); installation UX shows primary in README

**When to use**:
- Primary capability ships with paired rule-skill(s) enforcing maintenance constraints
- Primary has companion micro-capabilities that have no use outside it
- You want a single install command to pull primary + all enhancements

**Example**: a database migration capability skill + a paired rule-skill enforcing "NEVER write destructive migrations without backup verification". The rule-skill has no meaning outside that capability — publishing separately would force users to install both while giving them no way to understand the coupling, and forking the capability without the rule-skill would silently lose the enforcement.

**Description design for augmenters** — a pattern to improve auto-invocation reliability:

- **Primary skill description**: writes on **intent triggers** — "Use when user asks to build X", "Use when starting a Y workflow". Intent phrases match user's verbal task framing.
- **Augmenter (rule-skill) description**: writes on **environment triggers** — "MUST read SKILL.md BEFORE editing any `*.sql` migration file", "Activate when touching `schema/` directory". Environment phrases match the model's task context, not the user's phrasing.

Why split: if both use identical trigger patterns, they compete for the same matches and one drowns out the other. If they target different trigger dimensions (intent vs environment), the primary loads when the user states intent and the augmenter loads when the model is about to touch the constrained artifact — double coverage with no contention.

**Upper bound on N**: experience shows `N ≤ 3-5` augmenters. Beyond that, descriptions start competing for attention even with intent/environment split, and users lose the mental model of "one primary skill with a few guardrails". If you find yourself at N ≥ 6, reconsider whether the augmenters actually belong together or whether the primary itself should be split.

**When NOT to use this pattern**: 2026-04 dogfooding on `design-playbook` surfaced a counter-lesson. Most of that rule-skill's constraints (file size limits, reference index sync) were **general skill-engineering rules already enforced by skill-forge audits**, not design-playbook-specific. Only one constraint (EP field resolvability) was genuinely capability-specific — and that rule fit better as a 5-line comment block at the top of the reference file it constrained. Augmented Skill packaging is justified only when (a) the rule-skill has substantive content that would clutter the primary capability's SKILL.md, AND (b) the constraints are unique to the primary capability and cannot be handled by generic audits. If either fails, prefer a single skill with inline documentation over collection packaging.

See also: `rules-as-skills/references/decision-tree.md` Step 0 — if a candidate augmenter is universal engineering hygiene or single-file scope, it should not be a rule-skill at all.

### Peer Collection (平级多 skill)

N independent skills that happen to share a common domain or team, bundled for convenience. No primary — all peers.

**Characteristics**:
- N peer skills, no primary
- Each skill could theoretically be independently useful
- Bundled because same team / same release cycle / user wants one install

**When to use**:
- Single team publishes a family of related but independent capabilities
- Users commonly want all of them (WordPress dev workflow, Vercel + React stack)
- Release cycle is synchronized

**Example**: `WordPress/agent-skills` with 13 peer skills for WordPress development. No primary — each skill stands alone.

**Structure:**
```
<org>/<domain>-skills/
├── skills/
│   ├── <skill-a>/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── <skill-b>/
│   │   └── SKILL.md
│   └── <skill-c>/
│       └── SKILL.md
├── README.md              # lists all skills
├── LICENSE
└── .gitignore
```

**Install:**
```bash
npx skills add <org>/<collection> --skill <name>   # one skill
npx skills add <org>/<collection> --all             # all skills
npx skills add <org>/<collection>                   # interactive picker
```

**Best for:**
- Skills that are ALWAYS consumed together, never individually
- Single team, single release cycle
- One-command install is the top priority

**Real-world examples:**
- `WordPress/agent-skills` — 13 skills for WordPress development
- `vercel-labs/agent-skills` — 5 skills for Vercel + React
- `anthropics/skills` — 17 skills for Claude API

### Augmented vs Peer — Choosing Between the Two

```
Are the skills independently useful?
  YES (each skill stands alone, unrelated to the others)         → Peer Collection
  NO  (one skill is the reason for the bundle, others support it) → continue

Is there a clear "main thing" users identify with?
  YES (users say "I use X" where X is one specific skill)         → Augmented Skill
  NO  (users say "I use the X collection")                        → Peer Collection

Would forking the primary without the augmenters silently break behavior?
  YES (augmenters enforce invariants the primary relies on)       → Augmented Skill
  NO  (augmenters are nice-to-have)                               → Peer Collection or separate repos
```

Augmented Skill reads like "one product with bundled guardrails". Peer Collection reads like "a suite, each piece usable alone".

## Protocol Skill — Orthogonal Dimension: Installation Side Effects

Beyond Single / Collection / In-Repo (publishing models), a skill can also be classified by **what its installation does**:

| Skill behavior type | Value delivery | Install effect |
|---------------------|----------------|----------------|
| **Capability** | skill body (workflows, commands, code) | Install places files; value realized on load |
| **Rule-skill (constraint)** | description MUST/NEVER + body details | Install places files; value realized when description matches context |
| **Protocol Skill** | **setup script side effects** (modifies host environment) | Install places files **and** requires running setup to activate the protocol |

A Protocol Skill is any skill whose **real value is delivered by a setup script**, not by the skill files themselves. The files document the protocol; the setup activates it.

**Canonical example**: [rules-as-skills](https://github.com/motiful/rules-as-skills). Installing the repo alone gives you methodology docs. Running `scripts/install-meta-rule.sh` injects a meta-rule into each agent's global rule file — that meta-rule is the actual enforcement mechanism, and it applies to every `*-rules` skill on the machine (current and future). Without the setup step, the skill is a PDF; with it, it's a protocol.

**When a skill should be Protocol-type**:
- The skill's central claim is about **how other skills or tools should be treated** (meta-level methodology)
- Without an environment change, the methodology can be read but not enforced
- The change is **global** (affects the whole agent environment), not per-skill

**Interaction with publishing models**:
- Most Protocol Skills are **Single** (the protocol itself is one coherent thing)
- Some could be **Augmented** if they ship with helper rule-skills (but the meta-rule already covers all rule-skills by design, so augmenters are often redundant)
- Rarely **Peer** — Peer Collection has no primary, but a Protocol Skill needs a primary to anchor the setup script ownership

**Setup script expectations** (from `references/installation.md`):
- Idempotent (re-running has no adverse effect)
- Reversible (supports an `uninstall` subcommand)
- Uses distinctive markers in injected content so the uninstaller can target its changes precisely
- Non-destructive (never overwrites unrelated content in the host file)

## In-Repo (Not Independently Published)

Skills that ship with a project repo. Distributed via clone/fork, not `npx skills add`.

**Structure:**
```
project-repo/
├── SKILL.md                              ← main skill (published)
├── .claude/skills/<name>/
│   └── SKILL.md                          ← in-repo skill (source of truth)
├── .agents/skills/<name>                  → relative symlink
└── .gitignore                            ← .claude/* + !.claude/skills/
```

**Best for:**
- Maintenance constraints for the repo itself
- Project-specific coding standards or security rules
- Constraints that don't generalize to other projects
- Agent project internal skills that are crucial to project function

**Important**: `.claude/skills/` as source of truth. `.agents/skills/` as relative symlink for Codex/Windsurf coverage.

**Graduation**: In-repo skill that proves generally useful can be extracted to a standalone repo.

## Decision Framework

This framework is also used by the Classification step in `references/project-audit.md`. When classifying skills found during a project audit, apply this decision tree to determine whether each skill should stay in-repo, be extracted as a standalone repo, or grouped into a collection.

```
Dimension C decision (after A and B are settled):

Step 1 — How many skills to publish?
   0 (in-repo only) → In-repo (.claude/skills/)
   1 → Skill (one repo, default)
   ≥2 → continue to Step 2

Step 2 — Must they ship together?
   YES, forking one without others breaks maintenance/function → Collection
       → continue to Step 3
   NO, they can ship independently → Separate Skill repos
       → declare inter-skill dependencies in each skill's setup.sh

Step 3 — Collection subtype?
   One primary + N augmenters (rule-skills, micro-capabilities) → Augmented Skill
   N peers, no primary → Peer Collection

Step 4 — Orthogonal: is this also a Protocol Skill?
   Does activation require a setup script that modifies the host environment?
   YES → See §Protocol Skill for setup.sh requirements (idempotent, reversible,
         marker-based injection). Publishing model unchanged; add a setup step
         to README.
   NO  → Standard publishing; no additional requirements.
```

## Directory Standards

`npx skills add` discovers skills in this priority order:

1. **Root SKILL.md** → single Skill repo (returns immediately)
2. **`skills/*/SKILL.md`** → Collection (lists all for selection)
3. **Agent directories** (`.claude/skills/`, `.agents/skills/`, etc.) → 20+ paths checked
4. **Recursive search** (depth 5) → fallback

**Important:** `skill/` (singular) is NOT in the standard scan path. For `npx skills add` compatibility:
- Skill repos: put `SKILL.md` at repo root
- Collections: put skills in `skills/<name>/SKILL.md`
