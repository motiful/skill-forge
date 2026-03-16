---
name: skill-forge
description: Create, validate, publish, and review skills as GitHub repos. Use when the user says "publish this skill", "create a skill", "forge a skill", "review this skill repo", "audit this skill", "check my skill", or wants to triage a project's skills or graduate a project-local skill to standalone. Handles five engagement scenarios: quick review, full pipeline, multi-skill triage, full create, and graduation.
license: MIT
metadata:
  author: motiful
  version: "3.1"
---

# Skill Forge

Skill engineering methodology and publishing pipeline. Defines what "well-engineered skill" means, validates skills against that standard, and publishes them as installable GitHub repos.

## Engagement Principles

These rules govern all scenarios. Read them before acting.

1. **Assess before acting** — first step is always understanding the situation (scan, inventory, read)
2. **Report before modifying** — show findings, get user approval, then act
3. **Security > Structure > Quality > Polish** — when multiple issues exist, fix in this priority
4. **Scope is user-defined** — "check" means only check. "publish" means full pipeline. Don't upsell
5. **One skill at a time for changes** — diagnose in batch, but modify one by one with user confirmation
6. **Progressive commitment** — user can stop at any stage. Review-only is a complete interaction
7. **Understand context** — a skill may belong to a tool, or relate to other skills. Don't treat each in isolation

## Scenarios

Identify the current scenario first, then compose the right Operation Modules.

### 1. Quick Review

**Signal**: "check my skill", "review this skill", "audit my skill repo"

User has an existing skill and wants a quality check. Not creating, not publishing.

**Flow**: Locate the skill → Step 3 (all checks) → structured report with severity levels

**Checkpoints**: which issues to fix (critical = must, warning = user's choice)

**Exit**: after report. Do not push toward publishing or creation.

The skill can be local (path) or remote (GitHub URL — clone to temp directory). Quick Review does not require Step 0, Step 1, or Step 2.

### 2. Full Pipeline

**Signal**: "publish this skill", "put this on GitHub", "forge this skill"

User has a skill ready to share.

**Flow**: Step 0 → Step 1 → Step 3 → Step 4

**Checkpoints**: confirm publish target, confirm preflight

**Exit**: after successful publish (or at any Publishing Level the user chooses)

### 3. Multi-Skill Triage

**Signal**: "this project's skills are a mess", "audit all my skills", "review everything"

Project has multiple scattered skills with inconsistent quality.

**Flow**:
1. **Inventory** — scan all SKILL.md files in project and skill roots
2. **Triage** — prioritize by severity: security > structure > quality
3. **Plan** — propose fix order, present to user
4. **Execute** — each skill gets Step 3, one at a time

**Checkpoints**: approve the plan, approve scope, confirm each skill's changes

**Exit**: after all prioritized skills are reviewed. Don't force-publish.

### 4. Full Create

**Signal**: "create a new skill", "I want to build a skill for X"

User has an idea but no SKILL.md yet.

**Flow**: Step 0 → Step 1 → Step 2 → Step 3 → Step 4

**Checkpoints**: confirm skill scope, confirm content, confirm publish target

**Exit**: after publish (or earlier if user says stop)

### 5. Graduation

**Signal**: "graduate this project skill", "turn this local skill into a standalone repo"

Project-local skill is good enough to publish independently.

**Flow**:
1. **Step 0** — ensure forge config exists (`skill_root`, `github_org`)
2. **Step 1** — locate the project-local skill
3. **Graduation assessment** — check for project-specific references, hardcoded paths, project-internal dependencies
4. **Cleanup** — generalize: remove project-specific refs, ensure standalone usability
5. **Step 3** — validate the cleaned version
6. **Step 4** — publish

```
Source: <project>/.claude/skills/bar/    (or platform equivalent)
Target: <skill_root>/bar/
```

Copy content (`cp -r <source>/* <skill_root>/<name>/`), clean up, validate, publish. Original stays in the project — independent evolution.

**Checkpoints**: confirm what to clean, confirm publish target

**Exit**: after publish

## Operation Modules

Steps 0–4 are reusable building blocks. Scenarios define which steps run and in what order.

### Step 0: Configuration

#### User Conventions

Before creating or publishing, check for the user's existing conventions. Scan in priority order:

1. **Forge config** — `~/.config/skill-forge/config.md` (platform-agnostic, created below)
2. **Project instructions** — `CLAUDE.md`, `AGENTS.md`, or equivalent for the current platform
3. **Platform rules directory** — if it exists (CC: `~/.claude/rules/`, Cursor: `~/.cursor/rules/`, etc.)

If the user has established conventions (naming, structure, org, licensing), **follow them**. Skill-forge provides defaults for users who don't have conventions yet, not overrides for users who do.

#### Positioning

Skill Forge creates **independent, publishable skill repositories**. If the user just wants a quick project-internal skill (not shared), guide them to the platform's built-in skill creator instead.

Skill Forge optimizes for **public artifact quality**: installability, maintainability, composition quality, README clarity, honest claims. It does **not** certify domain excellence or real-world effectiveness.

#### Config Check

Read `~/.config/skill-forge/config.md`.

**Found** → read user's preferences and proceed.

**Not found** → detect sensible defaults first, then ask for explicit confirmation before writing:

```markdown
# Skill Forge Config

## Defaults

- skill_root: ~/skills/
- github_org: <auto-detect via `gh api user -q .login`, ask if `gh` unavailable>
- license: MIT
```

**`skill_root`** defaults to `~/skills/`. Tell the user: *"Your skills will live in `~/skills/` — each skill gets its own folder and git repo there. You can change this anytime in `~/.config/skill-forge/config.md`."*

Detect what you can (`github_org` via `gh`, platform from the current agent). Show the exact config path and values you plan to write, then ask once before writing. Don't interrogate — detect, summarize, confirm.

`~/.config/skill-forge/config.md` is for stable forge preferences. Forge-managed registries and history belong in `~/.config/skill-forge/state.md`.

#### Works Better With

Forge works fully on its own. These companion tools strengthen specific steps when available:

- **`motiful/rules-as-skills`** — strengthens Rule-Skill Split in Step 1 with portable constraint skills. Without it, forge uses built-in `references/rule-skill-pattern.md`
- **`motiful/readme-craft`** — 3-tier layout, badge selection, dark/light logo for README in Step 4. Without it, forge uses built-in templates from `references/templates.md`

### Step 1: Gather

#### Context Detection (automatic)

Before asking anything, detect what's already available:

1. **Current project scan** — Look for existing skill content:
   - `.claude/skills/*/SKILL.md` (or platform equivalent)
   - `skill/SKILL.md` in the working directory
   - If Step 0 found forge config: `<skill_root>/*/SKILL.md` (one level deep only; prefer exact name matches or user-referenced paths)
   - Any `SKILL.md` file the user might be working on

2. **Conversation context** — Has the user been discussing a skill idea? Are there notes, specs, or requirements already in the conversation?

3. **Explicit references** — Did the user point to specific files or directories?

**If one clear match is found** → proceed with it automatically and include the chosen source path in the Step 4 confirmation summary.

If multiple likely matches are found, summarize the candidate paths and ask which one to use.

**If nothing found** → then ask:
- What does this skill do? (1-2 sentences)
- When should it trigger? (specific phrases, file types, scenarios)

#### Structural Patterns

Check if the skill needs any of these optional patterns:

- **Precondition checks** — Does the skill need external tools (CLI, npm packages, APIs)? If yes, add a Step 0 that checks for them every run and handles absence. See `references/precondition-checks.md`
- **Rule-Skill Split** — Does the skill have hard MUST/NEVER constraints that users might want to customize? If yes, consider separating constraints into a paired `<name>-rules` skill. See `references/rule-skill-pattern.md`

Most skills need neither. Don't force-fit patterns where simple workflow steps suffice.

### Step 2: Create

Write SKILL.md following the Agent Skills open standard. See `references/skill-format.md` for the complete format specification (frontmatter, CC extensions, body conventions, file structure, content guidelines).

Key principle: write for another AI agent, not a human. Keep body under 500 lines — use `references/` files for detailed content.

#### Baking In Structural Patterns

For patterns detected in Step 1, bake the corresponding structure into the generated SKILL.md:

- **Precondition checks** → Add a Step 0 that checks for required external tools every run and handles absence (install prompt or graceful skip). See `references/precondition-checks.md`
- **Rule-Skill Split** → Create a separate `<name>-rules` skill alongside the main skill, but keep the main skill usable on its own. If `<name>-rules` is absent, the generated skill must fall back to its built-in/default behavior and say that explicitly

These patterns are **transparent to the end user** — they work without the end user having skill-forge installed. Forge bakes them in at creation time; the generated skill is self-contained.

#### Companion Tools in Generated Skills

If the skill being created works better with companion tools (other skills, CLI tools), mention them inline at the relevant workflow step with fallback behavior. Mirror them in README's "Works Better With" section.

Keep it simple:
- Mention what the companion does and how to get it
- Describe the complete fallback if it's absent
- The skill must fully complete its job without any companion installed

### Step 3: Validate

#### Core Validation

| Check | Criteria |
|-------|----------|
| Frontmatter fields | Only standard top-level fields: `name`, `description`, `license`, `metadata`, `compatibility`, `allowed-tools`. Put CC-specific or custom fields inside `metadata` |
| `name` | kebab-case, max 64 chars, lowercase alphanumeric + hyphens |
| `description` | Present, < 1024 chars, **single-line** (no YAML multi-line `>-` or `|` — causes skills to silently disappear in CC) |
| Description coverage | Does the description mention the key trigger scenarios from the SKILL.md body? For each major capability or workflow in the body, check if the description includes a corresponding trigger phrase. Report gaps as warnings with suggested additions. Report description claims absent from body as over-promises |
| Body | Under 500 lines, has meaningful content (not just TODOs) |
| References | All files referenced in SKILL.md actually exist |
| No junk files | For multi-skill repos: no README.md, CHANGELOG.md, or docs inside `skills/<name>/`. For single-skill repos: SKILL.md, references/, assets/, scripts/ at root alongside README.md and LICENSE is the expected structure |
| Companion tools | If the skill mentions companion tools, verify each has a complete fallback described. No companion should hide a real dependency |
| Terminology consistency | Extract core terms defined in SKILL.md. Check for: terms that conflict with the skill's own name, terms used with different meanings in different sections, terms that conflict with platform concepts. Report conflicts — don't auto-fix |
| Directory names | The Agent Skills standard names three skill directories: `references/`, `assets/`, `scripts/`. Flag non-standard directory names used for skill content. Directories serving only GitHub/repo presentation do not need renaming — just confirm they are not referenced by SKILL.md as skill content |
| Script quality | If `scripts/` exists: no single file >500 lines without justification; CLI parsing separated from business logic. See `references/script-quality.md` |

#### Repo Hygiene

These checks apply to the entire repository, not just skill content. They run automatically before publish and in review mode.

| Check | Criteria |
|-------|----------|
| Leaked secrets | Scan all tracked files for common secret patterns: API keys (`sk-`, `ghp_`, `AKIA`, `xox[bpas]-`), tokens, passwords in config files, private keys (`-----BEGIN.*PRIVATE KEY-----`), hardcoded credentials. **Block publish** until resolved |
| .gitignore coverage | Verify common entries: `.env*`, `node_modules/`, `.DS_Store`, IDE configs, OS files. Flag tracked files that match these patterns |
| Credential files | Warn if `.env`, `credentials.json`, `*.pem`, `*.key`, or secret-bearing config files are tracked by git |
| Unnecessary files | Flag files that add noise: lock files without a `scripts/` runtime, large media (> 1 MB), build artifacts, IDE workspace files |

**Severity levels:**
- **Critical** (leaked secrets, credential files) — block publish, require immediate action
- **Warning** (missing .gitignore entries, unnecessary files) — report and recommend, do not block

In review mode (Scenario 1), present all findings with severity. In publish mode, block on critical issues only.

#### Community Readiness (optional)

If the user wants maximum discoverability:

| Check | Criteria |
|-------|----------|
| README quality | Value-first structure, claim discipline, example clarity. See `references/readme-quality.md` and `references/templates.md` |
| Install command | Primary: `npx skills add <org>/<repo>`. Manual clone as fallback only |
| Companion tools | If SKILL.md mentions companion tools, mirror them in a concise README section and state the skill works on its own |
| Discoverability claims | Do not imply GitHub publication guarantees immediate listing or search placement |
| No hardcoded paths | No personal paths (~/ expanded, /Users/specific/) in published files |
| LICENSE exists | Required for community platforms |
| Description clarity | Description alone should tell a stranger what this skill does and when to use it |
| Security | If skill contains scripts, document what they do and what permissions they need |

### Step 4: Publish

#### Publishing Levels

User can stop at any level. Each level is a valid resting point.

| Level | What it means | skill-forge support |
|-------|--------------|---------------------|
| 0 — Local only | Skill lives in project, no git | Default state — no forge action needed |
| 1 — Version control | `git init`, local repo | Direct (natural checkpoint) |
| 2 — GitHub published | Public repo, `npx skills add` installable | Direct (full pipeline) |
| 3 — Directory listed | Community directories index it | Downstream (not our control) |

Do not promise Level 3 as an outcome of running skill-forge. Do not push users past the level they requested.

#### Strategy

Before creating the repo, determine the publishing strategy. See `references/publishing-strategy.md` for detailed guidance.

**Quick decision:** One skill → Skill repo (SKILL.md at root). Multiple tightly-coupled skills → see `references/publishing-strategy.md` for Skill vs Collection. For composition philosophy, see `references/skill-composition.md`.

Think about publishing in three layers, in this order:

1. **Public Artifact** — what gets published and how strangers evaluate/install it
2. **Remote Publish** — git + remote hosting
3. **Local Registration** — optional convenience on the current machine

Do not let local registration convenience redefine the public artifact.

#### 4a. Public Artifact

##### Repo structure

```
<skill_root>/<skill-name>/
├── SKILL.md                       # at root for npx skills add discovery
├── references/                    # if needed
├── scripts/                       # if needed
├── README.md
├── LICENSE
└── .gitignore
```

##### README.md

Use readme-craft if available (3-tier layout, badge selection, dark/light logo). Without it, use built-in templates.

See `references/templates.md` for skeletons and `references/readme-quality.md` for rules. Key requirements:
- **Value-first**: Problem → What It Does → Usage → Install → What's Inside
- Must mention [Agent Skills](https://agentskills.io) compatibility
- Primary install: `npx skills add <org>/<skill-name>`. Manual clone as fallback
- If companion tools exist, add a "Works Better With" section
- Include a "What's Inside" section showing skill files
- Include a "Forged with Skill Forge" footer

##### .gitignore

Use the template from `references/templates.md`.

#### 4b. Preflight Confirmation

Before any side effect outside the current repo artifact, summarize the exact actions and get explicit confirmation once:

- Config/state files to create or update
- Local repo actions (`git init`, initial commit, target repo path)
- Remote target (`<org>/<skill-name>`, visibility)
- Detected registration roots that will be linked
- Any new platform roots to be created (only for explicitly named platforms)

After confirmation, execute without further mode-selection questions unless new ambiguity appears.

Use task language: "Before I publish, here's what I'll do" instead of "preflight". Avoid surfacing internal concepts (mode, collection) unless the user's request requires them.

#### 4c. Remote Publish

```bash
# Git init
cd <skill_root>/<skill-name>
git init && git add -A && git commit -m "init: <skill-name> skill"

# Update skill_root .gitignore (if skill_root is a git repo)
# Add <skill-name>/ if not already present

# Push to GitHub (default)
gh repo create <org>/<skill-name> --public --source=. --push

# Non-GitHub: ask for remote URL
git remote add origin <url> && git push -u origin main
```

Update forge state: add the skill to `~/.config/skill-forge/state.md` under "Published Skills".

After push, tell the user: *"Your skill is on GitHub. Install with `npx skills add <org>/<skill-name>`. Community directories may surface it later based on their own indexing."*

See `references/platform-registry.md` for community directories and tools.

#### 4d. Local Registration (Optional)

Source of truth is `<skill_root>/<skill-name>/`. Registration is a convenience layer, not part of the public artifact.

**Do not ask the user to choose a registration mode.** Detect roots automatically, include in preflight, act after confirmation.

See `references/platform-registry.md` for the platform matrix and policy.

##### Decision Logic

```
1. Scan for existing skill roots (strong signals only)
   Strong: ~/.claude/skills/, ~/.agents/skills/, ~/.copilot/skills/,
           ~/.cursor/skills/, ~/.codeium/windsurf/skills/
   Strong: <project>/.claude/skills/, <project>/.agents/skills/,
           <project>/.github/skills/, <project>/.cursor/skills/,
           <project>/.windsurf/skills/
   Weak (ignore): installed CLI without skill root, generic config dirs,
                  bare parent dirs like <project>/.github/

2. Roots found → link all detected roots after confirmation
   No roots  → skip, tell user the repo is ready

3. User explicitly names undetected platform → create root + link after confirmation
```

Never link one vendor root to another. Every consumer root points to `<skill_root>/<skill-name>/`.

```bash
# Link into existing root
ln -sfn <skill_root>/<skill-name> ~/.claude/skills/<skill-name>

# User-requested new platform
mkdir -p ~/.agents/skills
ln -sfn <skill_root>/<skill-name> ~/.agents/skills/<skill-name>
```

##### Output

```text
Linked:
✓ ~/.claude/skills/<name> → <skill_root>/<name>/

No new platform directories created.
```

## References

- `references/quality-principles.md` — What is a good skill, 6 quality dimensions, skill-forge's identity, decision test for features
- `references/skill-format.md` — SKILL.md format specification (frontmatter, structure, guidelines)
- `references/skill-composition.md` — Composition philosophy: context budget, "works better with" pattern
- `references/publishing-strategy.md` — Skill vs Collection publishing models
- `references/platform-registry.md` — Platform skill paths, detection logic, community directories
- `references/skill-configuration.md` — Optional pattern: user preferences that persist across sessions
- `references/precondition-checks.md` — Optional pattern: runtime tool checking
- `references/rule-skill-pattern.md` — Optional pattern: MUST/NEVER constraints as paired skill
- `references/state-management.md` — State vs config distinction, forge's own state files
- `references/templates.md` — README, LICENSE, and .gitignore skeletons
- `references/readme-quality.md` — README writing, claim discipline, example rules
- `references/script-quality.md` — Script size limits, module split triggers, dependency policy
