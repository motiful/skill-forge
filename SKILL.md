---
name: skill-forge
description: 'Create, validate, scan for security issues, and review skills as publishable GitHub repos. Use when the user says "create a skill", "forge a skill", "review this skill repo", "audit this skill", "audit all my skills", "audit this project", "clean up my skills", "check my skill", "publish this skill", "push this to GitHub", or points to a project directory with mixed skills and rules. Two modes: Review (existing skill or project → discover → classify → validate → fix → local ready) and Create (new skill → build → validate → local ready). Push to GitHub is a single action after local ready.'
license: MIT
metadata:
  author: motiful
  version: "6.2"
---

# Skill Forge

Skill engineering methodology and publishing pipeline. Defines what "well-engineered skill" means, validates skills against that standard, and produces publishable GitHub repos.

## Engagement Principles

These rules govern all modes. Read them before acting.

1. **Assess before acting** — first step is always understanding the situation (scan, inventory, read)
2. **Report before modifying** — show findings, get user approval, then act
3. **Security > Structure > Quality > Polish** — when multiple issues exist, fix in this priority
4. **Default to local-ready** — both modes run through validation and fixes until the skill is local-ready. User can stop at any point
5. **One skill at a time for changes** — diagnose in batch, but modify one by one with user confirmation
6. **Push is a single action, not a pipeline** — local-ready means everything is done; push only sends to remote
7. **Understand context** — a skill may belong to a tool, or relate to other skills. Don't treat each in isolation

## Modes

Two modes. Push is a single action after either mode reaches local ready.

### Review (skill already exists)

**Signal**: "review", "check", "audit", "check my skill", "audit this skill", "audit all my skills"

**Flow**: Step 0 → Discovery → Classification → Plan File → [per item: Step 3 → Fix → Local Ready] → Close Plan

Every Review run starts with Discovery — even for a single skill. The target can be a single skill (local path or GitHub URL), a project directory, or a full monorepo. Discovery determines what the plan contains. See `references/project-audit.md` for Discovery, Classification, Plan File format, Rules Conversion, and Execution Order.

**Plan file**: always created at `/tmp/skill-forge-<name>.md`. If a plan file already exists at that path, resume from the first incomplete step — do not restart Discovery.

**Graduation**: Classification proactively identifies personal tool skills (useful beyond this project). Forge executes graduation without waiting for the user to ask: copy to `<skill_workspace>/<name>/`, run full Review, register globally. Original stays in the project.

**Severity**: Critical = must fix. Warning = recommend fix (user confirms). Info = report only.

### Create (skill does not exist)

**Signal**: "create a skill", "build a skill for X", "forge a skill"

**Flow**: Step 0 → Step 1 → Step 2 → Step 3 (Validate) → Fix → Local Ready

**Plan file**: created at start (`/tmp/skill-forge-<name>.md`), tracks progress through creation steps. Deleted on completion. See `references/project-audit.md` — Plan File section for format.

**Checkpoints**: confirm skill scope, confirm content

### Local Ready Definition

A skill is "local ready" when ALL of the following are true:

```
<skill-name>/
├── SKILL.md                           # validated (Step 3 passed)
├── references/                        # if needed, all links resolve
├── scripts/                           # if needed, setup.sh works
├── README.md                          # audited by readme-craft
├── LICENSE                            # exists
└── .gitignore                         # matches template
```

- `git init` done, initial commit made
- Local registration (symlinks) done for all detected platform roots
- All Critical and Warning issues from Step 3 resolved
- README audited by readme-craft (not just manually checked)

**Local ready = push-ready.** The only remaining action is a network operation.

### Push (single action after local ready)

**Signal**: "push", "publish this skill", "publish to GitHub", "put this on GitHub"

Push is NOT a mode — it is a single action the user triggers after a skill reaches local ready.

**Pre-check**: If the skill has not reached local ready (no prior Review or Create in this session), run Review first. Push only executes after local ready is confirmed.

**Flow**: Confirm remote target → `gh repo create` + `git push`

See [Push to Remote](#push-to-remote) for the exact procedure.

## Operation Modules

Steps 0–3 are reusable building blocks. Modes define which steps run and in what order. Push is a standalone action after local ready.

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
2. **Ask workspace** — `skill_workspace` is the only value that differs per person. Output this question and stop — wait for the user's response before proceeding: *"Where should new skills live? [~/skills/]"* Let the user type a path or press Enter for the default. Do not bundle this into a generic confirm and do not assume the default.
3. **Summarize** — show the confirmed workspace plus detected defaults:
   ```markdown
   # Skill Forge Config
   ## Defaults
   - skill_workspace: <confirmed path>
   - github_org: <detected>
   - license: MIT
   ```
4. **Write** — create `~/.config/skill-forge/config.md`

**`skill_workspace`** is where new skill repos are created — each skill gets its own subfolder and git repo there. It is the only onboarding value that needs explicit user input; `github_org` and `license` have reliable defaults.

See `references/onboarding.md` for the onboarding pattern.

#### 0c. Config Check

Read `~/.config/skill-forge/config.md`.

**Found** → read user's preferences and proceed.

**Not found** (and onboarding didn't run) → create with detected defaults (see 0b).

#### User Conventions

Check for the user's existing conventions. Scan in priority order:

1. **Forge config** — `~/.config/skill-forge/config.md` (platform-agnostic, created above)
2. **Project instructions** — `CLAUDE.md`, `AGENTS.md`, or equivalent for the current platform
3. **Platform rules directory** — if it exists (CC: `~/.claude/rules/`, Cursor: `~/.cursor/rules/`, etc.)

If the user has established conventions (naming, structure, org, licensing), **follow them** in Create and **validate against them** in Review. Skill-forge provides defaults for users who don't have conventions yet, not overrides for users who do.

#### Positioning

Skill Forge creates **independent, publishable skill repositories**. If the user just wants a quick project-internal skill (not shared), guide them to the platform's built-in skill creator instead.

Skill Forge optimizes for **public artifact quality**: installability, maintainability, composition quality, README clarity, honest claims. It does **not** certify domain excellence or real-world effectiveness.

### Step 1: Gather

#### Context Detection (automatic)

Before asking anything, detect what's already available:

1. **Current project scan** — Look for existing skill content:
   - `.claude/skills/*/SKILL.md` (or platform equivalent)
   - `skill/SKILL.md` in the working directory
   - If Step 0 found forge config: `<skill_workspace>/*/SKILL.md` (one level deep only; prefer exact name matches or user-referenced paths)
   - Any `SKILL.md` file the user might be working on

2. **Conversation context** — Has the user been discussing a skill idea? Are there notes, specs, or requirements already in the conversation?

3. **Explicit references** — Did the user point to specific files or directories?

**If one clear match is found** → proceed with it automatically.

If multiple likely matches are found, summarize the candidate paths and ask which one to use.

**If nothing found** → then ask:
- What does this skill do? (1-2 sentences)
- When should it trigger? (specific phrases, file types, scenarios)

#### Location Rule

Where the skill lives depends on context:

| Situation | Where to work |
|-----------|---------------|
| Skill already has a location (with or without git) | **In-place** — work where it is |
| Create mode (no existing files) | **`<skill_workspace>/<skill-name>/`** — the default |
| Graduation (explicit move request) | **Copy to `<skill_workspace>/<skill-name>/`** — user asked for the move |

Forge does not force-move the author's files. `skill_workspace` is the default for new skills, not a mandatory destination.

#### Publishing Strategy

Before creating, determine the repo strategy. See `references/publishing-strategy.md` for detailed guidance.

**Quick decision:** One skill → Skill repo (SKILL.md at root). Multiple tightly-coupled skills → see `references/publishing-strategy.md` for Skill vs Collection. For composition philosophy, see `references/skill-composition.md`.

#### Ecosystem Check (Create mode only)

Before writing new content, check if similar skills already exist:

1. **Search** — `npx skills find <keyword>` or search skills.sh for the domain
2. **Found similar?** → present to user with options:

| Finding | Recommendation |
|---------|---------------|
| Good match exists as standalone repo | Depend on it (`scripts/setup.sh`), don't recreate |
| Partial match — needs significant customization | Fork and adapt, or create new with the existing as reference |
| Nothing similar | Create from scratch |

Skip this check in Review mode — it works with existing skills.

#### Capability Detection

Detect which capabilities the skill needs. This is not optional — detect and act.

| Capability | Detection question | Action | Reference |
|---|---|---|---|
| **Installation** | Does the skill have dependencies to install? (tools, skills, npm packages) | Add `scripts/setup.sh` + Step 0 that runs it | `references/installation.md` |
| **Skill Invocation** | Does the skill invoke other skills at runtime? | Use the invocation pattern (explicit `Skill(...)` + output gate) at every call site | `references/skill-invocation.md` |
| **Onboarding** | Does the skill need first-use user guidance? (profile setup, credentials, preferences) | Add onboarding flow in Step 0 | `references/onboarding.md` |
| **Rule-Skill Split** | Does the skill contain 3+ MUST/NEVER constraints that users may want to customize? | Auto-create paired `<name>-rules` skill | `references/rule-skill-pattern.md` |
| **Maintenance** | Does the skill have 3+ dependencies, platform-path references in content, scripts/, or >300 line body? | Generate in-repo `maintenance-rules` skill | `references/maintenance-guide.md` |

**Rule-Skill Split is detection-driven**: if constraints are detected, forge creates the paired skill automatically. If no constraints detected, nothing is created. The user is not asked whether to create it — forge decides based on content.

### Step 2: Create

Write SKILL.md following the Agent Skills open standard. See `references/skill-format.md` for the complete format specification (frontmatter, CC extensions, body conventions, file structure, content guidelines).

Key principle: write for another AI agent, not a human. Keep body under 500 lines — use `references/` files for detailed content.

#### Baking In Detected Capabilities

For capabilities detected in Step 1, bake the corresponding structure into the generated SKILL.md:

- **Installation** → Add `scripts/setup.sh` that checks and installs all declared dependencies. Add a Step 0 that runs setup.sh. See `references/installation.md`
- **Skill Invocation** → At every call site, use the invocation pattern: explicit `Skill(...)` + output gate. See `references/skill-invocation.md`
- **Onboarding** → Add first-use guidance in Step 0 (after setup.sh). See `references/onboarding.md`
- **Rule-Skill Split** → `Skill("rules-as-skills")` — owns rule-skill methodology. Then auto-create a separate `<name>-rules` skill. See `references/rule-skill-pattern.md` for forge-specific detection and packaging
- **Maintenance** → Generate in-repo `maintenance-rules` skill in `.claude/skills/` with MUST/NEVER constraints, update triggers, and changelog. Symlink from `.agents/skills/`. See `references/maintenance-guide.md`

These patterns are **transparent to the end user** — they work without the end user having skill-forge installed. Forge bakes them in at creation time; the generated skill is self-contained (independent from forge, not from its own dependencies).

#### Repo Artifacts

Step 2 creates ALL publishable files, not just SKILL.md:

| File | Source | Notes |
|------|--------|-------|
| `SKILL.md` | Written in this step | Core skill content |
| `README.md` | Generated by readme-craft | Value-first structure, see `references/readme-quality.md` and `references/templates.md` |
| `.claude/skills/maintenance-rules/` | Generated if detected | In-repo maintenance rule-skill, see `references/maintenance-guide.md` |
| `LICENSE` | From `references/templates.md` | Default MIT, or per forge config |
| `.gitignore` | From `references/templates.md` | Standard template |

README is generated by readme-craft. skill-forge validates skill-specific additions from `references/readme-quality.md`.

### Step 3: Validate

#### Project-Specific Standards

Before running checks, scan the target project for its own quality standards. These become additional validation criteria on top of Core Validation.

Scan in order:
1. **Project instructions** — `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, or platform equivalents
2. **Editor/linter configs** — `.editorconfig`, linter configs
3. **Rules directory** — `.claude/rules/*.md`, `.cursor/rules/*.mdc`, etc.

Extract actionable rules (e.g., "references >100 lines must have a TOC", "description must include a negative trigger") and check them alongside Core Validation. Report violations attributed to the project's own standard, not skill-forge's.

If the target project has no project-specific standards, proceed with Core Validation only.

#### Core Validation

| Check | Criteria |
|-------|----------|
| Frontmatter fields | Only standard top-level fields: `name`, `description`, `license`, `metadata`, `compatibility`, `allowed-tools`. Put CC-specific or custom fields inside `metadata` |
| `name` | kebab-case, max 64 chars, lowercase alphanumeric + hyphens. Must not start/end with hyphen, no consecutive hyphens (`--`), must match parent directory name |
| `description` | Present, < 1024 chars, **single-line** (no YAML multi-line `>-` or `|` — causes skills to silently disappear in CC). If value contains `: ` (colon-space), must be quoted — strict YAML parsers (e.g. Codex) will reject unquoted colons as mapping indicators |
| Description coverage | Does the description mention the key trigger scenarios from the SKILL.md body? For each major capability or workflow in the body, check if the description includes a corresponding trigger phrase. Report gaps as warnings with suggested additions. Report description claims absent from body as over-promises |
| Body | Under 500 lines, has meaningful content (not just TODOs) |
| References | All files referenced in SKILL.md actually exist |
| No junk files | For multi-skill repos: no README.md, CHANGELOG.md, or docs inside `skills/<name>/`. For single-skill repos: SKILL.md, references/, assets/, scripts/ at root alongside README.md and LICENSE is the expected structure |
| Dependencies | If the skill declares dependencies, verify `scripts/setup.sh` exists and handles each one. Dependencies must be installed, not optional |
| Invocation reliability | For each skill dependency: does every invocation point use explicit `Skill(...)` syntax + output gate? Natural-language invocations ("invoke X", "run X") are flagged. See `references/skill-invocation.md` | Warning |
| Runtime write to skill directory | Skill directory should have no runtime-written data files. Flag `.claude/skills/<name>/data/`, `.claude/skills/<name>/cache/`, or any non-published file | Warning |
| Assets misuse | `assets/` only holds AI-consumed source material. Logo, screenshots, and repo infrastructure belong in `.github/` or root level, not in `assets/` | Warning |
| Meta-skill contamination | Skill repo should not contain tooling skills (skill-forge, skill-creator) as subdirectories. Detect `skills/skill-forge/`, `.claude/skills/skill-forge/`, `.agents/skills/skill-forge/` or similar inside the repo. Remediation: `rm -rf <path>` then `npx skills add motiful/skill-forge -g` (tooling skills belong at global scope, not inside the skill being forged) | Warning |
| Collection context budget | For multi-skill repos: count total skills. 15+ skills → warn about context flooding (descriptions alone consume ~1.5K+ tokens). Recommend selective install (`--skill`) in README | Warning |
| Collection name collision | For multi-skill repos: flag generic skill names (`code-review`, `landing-page`) that are likely to collide with standalone skills the user may already have. Recommend namespacing (`<domain>-code-review`) | Warning |
| Terminology consistency | Extract core terms defined in SKILL.md. Check for: terms that conflict with the skill's own name, terms used with different meanings in different sections, terms that conflict with platform concepts. Report conflicts — don't auto-fix |
| Directory names | The Agent Skills standard names three skill directories: `references/`, `assets/`, `scripts/`. For non-standard directories: if SKILL.md references files inside them → Warning (content should likely be in `references/` or `assets/`). If SKILL.md does not reference them → not skill content, do not flag |
| Script quality | If `scripts/` exists: no single file >500 lines without justification; CLI parsing separated from business logic. See `references/script-quality.md` |
| README quality | Deferred to Fix Phase: readme-craft runs there (step 3). During Step 3 validation, flag README issues visible without readme-craft (missing file, obviously stale content). Full quality assessment is recorded after Fix Phase readme-craft run, combined with skill-specific checks from `references/readme-quality.md` |
| Install command | Primary: `npx skills add <org>/<repo>`. Manual clone as fallback only |
| Dependency mirroring | If SKILL.md declares dependencies, mirror them in a README "Dependencies" section |
| No hardcoded paths | No personal paths (~/ expanded, /Users/specific/) in published files |
| LICENSE exists | Required for community platforms |
| Description clarity | Description alone should tell a stranger what this skill does and when to use it |
| Script documentation | If skill contains scripts, document what they do and what permissions they need |
| Discoverability claims | Do not imply GitHub publication guarantees immediate listing or search placement |
| Graceful skip | Conditional branches must have actions on both sides — no implicit "do nothing" path. Flag "if applicable" / "optionally" / "if exists" that suppress capabilities. No-downside enhancements must default to execution. See `references/anti-graceful-skip.md` | Warning |
| Entry complexity | If skill has multiple modes or entry points: do modes produce different deliverables or follow different core workflows? Modes that differ only in information source (e.g., "has code" vs "no code") should merge into single-entry with state-driven steps. Flag capability gaps between modes (capability in Mode A but not Mode C) | Warning |

#### Repo Hygiene

These checks apply to the entire repository, not just skill content.

| Check | Criteria |
|-------|----------|
| Leaked secrets | Scan all tracked files for common secret patterns: API keys (`sk-`, `ghp_`, `AKIA`, `xox[bpas]-`), tokens, passwords in config files, private keys (`-----BEGIN.*PRIVATE KEY-----`), hardcoded credentials. **Block push** until resolved |
| .gitignore coverage | Verify common entries: `.env*`, `node_modules/`, `.DS_Store`, IDE configs, OS files. Flag tracked files that match these patterns |
| Credential files | Warn if `.env`, `credentials.json`, `*.pem`, `*.key`, or secret-bearing config files are tracked by git |
| Unnecessary files | Flag files that add noise: lock files without a `scripts/` runtime, large media (> 1 MB), build artifacts, IDE workspace files |

**Severity levels:**
- **Critical** (leaked secrets, credential files) — block push, require immediate action
- **Warning** (missing .gitignore entries, unnecessary files) — report and recommend, do not block

Present all findings with severity. Critical issues block push.

#### Fix Phase

After validation report is presented and user approves fixes:

1. Fix all Critical issues (mandatory)
2. Fix Warning issues (with user confirmation)
3. README:

   `Skill("readme-craft", "review <path>")` — owns universal README quality.
   skill-forge owns skill-specific README standards (`references/readme-quality.md`). Both apply, domain wins.
   Do not manually fix what readme-craft handles.

   If README does not exist, readme-craft will create it. After readme-craft completes,
   check skill-specific standards from `references/readme-quality.md` and fix any gaps.

4. Create missing repo artifacts (LICENSE, .gitignore) if they don't exist
5. Update remaining artifacts to pass validation
6. **Local registration** — detect platform roots, create symlinks:

   Detect platform registration paths (see `references/platform-registry.md` for the full path matrix and policy).
   Paths found → symlink all. No paths → skip. User names undetected platform → create + link.
   Never link one vendor path to another. Every consumer path points to the skill's source directory.
   **Exception — in-repo skills**: for skills committed to a repository (e.g., `.claude/skills/maintenance-rules/`), cross-vendor symlinks like `.agents/skills/X → ../../.claude/skills/X` are correct. These must be relative paths so they work for anyone who clones the repo. The `.claude/skills/` path IS the source directory in this context, not a vendor proxy.

7. **Git init** (if not already a git repo) + initial commit
8. Final quality review:

   `Skill("self-review", "<skill-path>")` — owns holistic quality judgment.
   Runs after skill-forge's structural validation. Catches what checklists miss.
   Do not declare local ready if self-review reports Broken dimensions.

9. Verify all Local Ready criteria are met

## Push to Remote

A single action, not a pipeline. Only available after local ready.

**Signal**: "push", "publish this skill", "publish to GitHub", "put this on GitHub"

**Procedure**:

1. **Confirm** — summarize what will happen:
   - Remote target (`<org>/<skill-name>`, visibility)
   - Current local ready status

2. **Execute**:

   ```bash
   # Push to GitHub (default)
   gh repo create <org>/<skill-name> --public --source=. --push

   # Non-GitHub: ask for remote URL
   git remote add origin <url> && git push -u origin main

   # Update skill_workspace .gitignore (if skill_workspace is a git repo)
   # Add <skill-name>/ if not already present
   ```

3. **Update config** — add the skill to `~/.config/skill-forge/config.md` under "Published Skills"

4. **Report**: *"Your skill is on GitHub. Install with `npx skills add <org>/<skill-name>`. Community directories may surface it later based on their own indexing."*

**CC Market**: check `cc_market` in forge config. If `true` → include CC Market submission. If `false` → skip. If **not set** → ask once with recommendation to skip (GitHub is already installable), save preference. See `references/platform-registry.md` for details.

## References

- `references/installation.md` — setup.sh standard: dependency detection, installation, two outcomes
- `references/skill-invocation.md` — Runtime invocation reliability: explicit `Skill(...)` call + output gate pattern
- `references/onboarding.md` — Interactive first-use guidance pattern
- `references/skill-configuration.md` — User preferences, config location, litmus test, stateless principle
- `references/skill-format.md` — SKILL.md format specification (frontmatter, structure, guidelines)
- `references/skill-composition.md` — Composition philosophy: context budget, dependency tiers
- `references/rule-skill-pattern.md` — Forge integration: detection, auto-creation, and packaging of rule-skills
- `references/publishing-strategy.md` — Skill vs Collection publishing models
- `references/platform-registry.md` — Platform skill paths, detection logic, community directories
- `references/templates.md` — README, LICENSE, and .gitignore skeletons
- `references/readme-quality.md` — README writing, claim discipline, example rules
- `references/script-quality.md` — Script size limits, module split triggers, dependency policy
- `references/maintenance-guide.md` — In-repo maintenance-rules skill: when to create, required content, template
- `references/anti-graceful-skip.md` — Default-execute principle, skip conditions, no-downside enhancements, Step 3 audit criteria
- `references/project-audit.md` — Discovery, Classification, Plan File, Rules Conversion, Execution Order for project-level Review
