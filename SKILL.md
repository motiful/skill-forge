---
name: skill-forge
description: Create, validate, publish, and review skills as GitHub repos. Use when the user says "publish this skill", "create a skill", "forge a skill", "review this skill repo", "audit this skill", "check my skill", or wants to triage a project's skills or graduate a project-local skill to standalone. Handles five engagement scenarios: quick review, full pipeline, multi-skill triage, full create, and graduation.
license: MIT
metadata:
  author: motiful
  version: "4.0"
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
1. **Step 0** — run setup.sh, ensure forge config exists (`skill_root`, `github_org`)
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

### Step 0: Environment Setup

#### 0a. Installation

Run `scripts/setup.sh` to check and install all dependencies.

```
1. Run scripts/setup.sh
2. Exit 0 → proceed
3. Exit non-zero → report error to user, stop
```

**Dependencies** (installed by setup.sh):
- **CLI tools**: `gh`, `node`, `npx`
- **Skills**: `motiful/readme-craft`, `motiful/rules-as-skills`, `motiful/self-review`

See `references/installation.md` for the setup.sh standard.

#### 0b. Onboarding (first use only)

If `~/.config/skill-forge/config.md` does not exist, run onboarding:

1. **Detect** — `github_org` via `gh api user -q .login`, platform from current agent
2. **Summarize** — show detected defaults:
   ```markdown
   # Skill Forge Config
   ## Defaults
   - skill_root: ~/skills/
   - github_org: <detected>
   - license: MIT
   ```
3. **Confirm once** — ask for approval
4. **Write** — create `~/.config/skill-forge/config.md`

**`skill_root`** defaults to `~/skills/`. Tell the user: *"Your skills will live in `~/skills/` — each skill gets its own folder and git repo there. You can change this anytime in `~/.config/skill-forge/config.md`."*

See `references/onboarding.md` for the onboarding pattern.

#### 0c. Config Check

Read `~/.config/skill-forge/config.md`.

**Found** → read user's preferences and proceed.

**Not found** (and onboarding didn't run) → create with detected defaults (see 0b).

#### User Conventions

Before creating or publishing, check for the user's existing conventions. Scan in priority order:

1. **Forge config** — `~/.config/skill-forge/config.md` (platform-agnostic, created above)
2. **Project instructions** — `CLAUDE.md`, `AGENTS.md`, or equivalent for the current platform
3. **Platform rules directory** — if it exists (CC: `~/.claude/rules/`, Cursor: `~/.cursor/rules/`, etc.)

If the user has established conventions (naming, structure, org, licensing), **follow them**. Skill-forge provides defaults for users who don't have conventions yet, not overrides for users who do.

#### Positioning

Skill Forge creates **independent, publishable skill repositories**. If the user just wants a quick project-internal skill (not shared), guide them to the platform's built-in skill creator instead.

Skill Forge optimizes for **public artifact quality**: installability, maintainability, composition quality, README clarity, honest claims. It does **not** certify domain excellence or real-world effectiveness.

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

#### Ecosystem Check (Full Create only)

For Scenario 4 (Full Create), before writing new content, check if similar skills already exist:

1. **Search** — `npx skills find <keyword>` or search skills.sh for the domain
2. **Found similar?** → present to user with options:

| Finding | Recommendation |
|---------|---------------|
| Good match exists as standalone repo | Depend on it (`scripts/setup.sh`), don't recreate |
| Partial match — needs significant customization | Fork and adapt, or create new with the existing as reference |
| Nothing similar | Create from scratch |

Skip this check for Scenarios 1, 2, 3, 5 — those work with existing skills.

#### Capability Detection

Detect which capabilities the skill needs. This is not optional — detect and act.

| Capability | Detection question | Action | Reference |
|---|---|---|---|
| **Installation** | Does the skill have dependencies to install? (tools, skills, npm packages) | Add `scripts/setup.sh` + Step 0 that runs it | `references/installation.md` |
| **Onboarding** | Does the skill need first-use user guidance? (profile setup, credentials, preferences) | Add onboarding flow in Step 0 | `references/onboarding.md` |
| **Rule-Skill Split** | Does the skill contain 3+ MUST/NEVER constraints that users may want to customize? | Auto-create paired `<name>-rules` skill | `references/rule-skill-pattern.md` |

**Rule-Skill Split is detection-driven**: if constraints are detected, forge creates the paired skill automatically. If no constraints detected, nothing is created. The user is not asked whether to create it — forge decides based on content.

### Step 2: Create

Write SKILL.md following the Agent Skills open standard. See `references/skill-format.md` for the complete format specification (frontmatter, CC extensions, body conventions, file structure, content guidelines).

Key principle: write for another AI agent, not a human. Keep body under 500 lines — use `references/` files for detailed content.

#### Baking In Detected Capabilities

For capabilities detected in Step 1, bake the corresponding structure into the generated SKILL.md:

- **Installation** → Add `scripts/setup.sh` that checks and installs all declared dependencies. Add a Step 0 that runs setup.sh. See `references/installation.md`
- **Onboarding** → Add first-use guidance in Step 0 (after setup.sh). See `references/onboarding.md`
- **Rule-Skill Split** → Auto-create a separate `<name>-rules` skill alongside the main skill. See `references/rule-skill-pattern.md`

These patterns are **transparent to the end user** — they work without the end user having skill-forge installed. Forge bakes them in at creation time; the generated skill is self-contained (independent from forge, not from its own dependencies).

#### Dependencies in Generated Skills

If the skill being created has dependencies (other skills, CLI tools, npm packages), they must be declared and installed:

- Declare in SKILL.md Step 0 and implement in `scripts/setup.sh`
- Mirror in README's "Dependencies" section
- No fallback behavior — dependencies are installed or the skill blocks with an error

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
| Dependencies | If the skill declares dependencies, verify `scripts/setup.sh` exists and handles each one. Dependencies must be installed, not optional |
| Runtime write to skill directory | Skill directory should have no runtime-written data files. Flag `.claude/skills/<name>/data/`, `.claude/skills/<name>/cache/`, or any non-published file | Warning |
| Assets misuse | `assets/` only holds AI-consumed source material. Logo, screenshots, and repo infrastructure belong in `.github/` or root level, not in `assets/` | Warning |
| Meta-skill contamination | Skill repo should not contain tooling skills (skill-forge, skill-creator) as subdirectories. Detect `skills/skill-forge/`, `.claude/skills/skill-forge/`, `.agents/skills/skill-forge/` or similar inside the repo. Remediation: `rm -rf <path>` then `npx skills add motiful/skill-forge -g` (tooling skills belong at global scope, not inside the skill being forged) | Warning |
| Collection context budget | For multi-skill repos: count total skills. 15+ skills → warn about context flooding (descriptions alone consume ~1.5K+ tokens). Recommend selective install (`--skill`) in README | Warning |
| Collection name collision | For multi-skill repos: flag generic skill names (`code-review`, `landing-page`) that are likely to collide with standalone skills the user may already have. Recommend namespacing (`<domain>-code-review`) | Warning |
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
| Dependencies | If SKILL.md declares dependencies, mirror them in a README "Dependencies" section |
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

#### Location Rule

Forge does not force-move the author's files. `skill_root` is the default for new skills, not a mandatory destination.

| Scenario | Where to publish |
|----------|-----------------|
| Skill already has a location (with or without git) | **Publish in-place** — `git init` where it is |
| Full Create (no existing files) | **Create in `<skill_root>/<skill-name>/`** — the default |
| Graduation (explicit move request) | **Copy to `<skill_root>/<skill-name>/`** — user asked for the move |

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
<skill-name>/                          # wherever the skill lives (see Location Rule)
├── SKILL.md                           # at root for npx skills add discovery
├── references/                        # if needed
├── scripts/                           # if needed
├── README.md
├── LICENSE
└── .gitignore
```

##### README.md

Use readme-craft (3-tier layout, badge selection, dark/light logo — installed by setup.sh).

See `references/templates.md` for skeletons and `references/readme-quality.md` for rules. Key requirements:
- **Value-first**: Problem → What It Does → Usage → Install → What's Inside
- Must mention [Agent Skills](https://agentskills.io) compatibility
- Primary install: `npx skills add <org>/<skill-name>`. Manual clone as fallback
- If dependencies exist, add a "Dependencies" section
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

**CC Market**: check `cc_market` in forge config. If `true` → include CC Market submission. If `false` → skip. If **not set** → ask once with recommendation to skip (GitHub is already installable), save preference. See `references/platform-registry.md` for details.

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

- `references/installation.md` — setup.sh standard: dependency detection, installation, two outcomes
- `references/onboarding.md` — Interactive first-use guidance pattern
- `references/skill-configuration.md` — User preferences, config location, litmus test, stateless principle
- `references/skill-format.md` — SKILL.md format specification (frontmatter, structure, guidelines)
- `references/skill-composition.md` — Composition philosophy: context budget, dependency tiers
- `references/rule-skill-pattern.md` — Detection-driven: MUST/NEVER constraints as paired skill
- `references/publishing-strategy.md` — Skill vs Collection publishing models
- `references/platform-registry.md` — Platform skill paths, detection logic, community directories
- `references/templates.md` — README, LICENSE, and .gitignore skeletons
- `references/readme-quality.md` — README writing, claim discipline, example rules
- `references/script-quality.md` — Script size limits, module split triggers, dependency policy
