---
name: skill-forge
description: Create, validate, and publish skills to GitHub as independent repos. Use when the user says "publish this skill", "create a skill", "forge a skill", "skill to GitHub", or wants to turn a project-local skill into a shareable GitHub repository. Handles the full pipeline from content creation to git init, GitHub repo creation, and local platform registration.
license: MIT
metadata:
  author: motiful
  version: "2.0"
---

# Skill Forge

Full pipeline for creating and publishing skills as independent GitHub repositories.

## Respecting User Conventions

Before creating or publishing a skill, check for the user's existing conventions. Scan in priority order:

1. **Forge config** — `~/.config/skill-forge/config.md` (platform-agnostic, created by Step 0)
2. **Project instructions** — `CLAUDE.md`, `AGENTS.md`, or equivalent for the current platform
3. **Platform rules directory** — if it exists (CC: `~/.claude/rules/`, Cursor: `~/.cursor/rules/`, etc.)

If the user has established conventions (naming, structure, org, licensing), **follow them**. Skill-forge provides defaults for users who don't have conventions yet, not overrides for users who do.

## When to Use

- User has a skill idea and wants it as a GitHub repo
- User has an existing project-local skill (`.claude/skills/foo/`) and wants to publish it
- User says "publish", "forge", "create a skill", "put this skill on GitHub"

## Pipeline

```
0. Config  → set up ~/skills/ root, detect preferences (auto-defaults)
1. Gather  → auto-detect existing content, then ask if needed
2. Create  → write SKILL.md + references/ + scripts/ following Agent Skills standard
3. Validate → check frontmatter, structure, content quality
4. Publish → shape the public artifact → publish remotely → optionally register locally
```

## Step 0: Ensure Configuration

### Positioning

SkillForge creates **independent, publishable skill repositories**. If the user just wants a quick project-internal skill (not shared), guide them to the platform's built-in skill creator instead.

SkillForge optimizes for **public artifact quality**:

- installability
- maintainability
- composition quality
- README clarity
- honest claims about what the skill does

It does **not** certify domain excellence or real-world effectiveness. Do not claim that a forged skill is objectively high quality in its output domain unless the user separately provides that evidence.

### Config check

Read `~/.config/skill-forge/config.md`.

**Found** → read user's preferences and proceed.

**Not found** → detect sensible defaults first, then ask for explicit confirmation before writing the file:

```markdown
# Skill Forge Config

## Defaults

- skill_root: ~/skills/
- github_org: <auto-detect via `gh api user -q .login`, ask if `gh` unavailable>
- license: MIT
```

**`skill_root`** defaults to `~/skills/`. Tell the user: *"Your skills will live in `~/skills/` — each skill gets its own folder and git repo there. You can change this anytime in `~/.config/skill-forge/config.md`."*

Detect what you can (`github_org` via `gh`, platform from the current agent). Show the exact config path and values you plan to write, then ask once before writing. Don't interrogate — detect, summarize, confirm.

`~/.config/skill-forge/config.md` is for stable forge preferences such as `skill_root`, `github_org`, and `license`. Forge-managed registries and history belong in `~/.config/skill-forge/state.md`.

## Step 1: Gather

### Context Detection (automatic)

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

### Capability Detection

Every skill potentially needs three independent capabilities. Detect which ones apply:

| Capability | Detection Question | If Yes |
|------------|-------------------|--------|
| **Onboarding** | Does this skill need first-use setup? (dependency checks, user preferences, guided introduction) | See `references/onboarding-pattern.md` |
| **State Management** | Does this skill need to remember things across sessions? (preferences, history, registries) | See `references/state-management.md` |
| **Rule-Skill Split** | Does this skill have user-customizable constraints? (MUST/NEVER rules, domain boundaries) | See `references/rule-skill-pattern.md` |

A skill may need any combination (all three, one, or none). Each is independent — detect and apply separately.

If `rules-as-skills` is installed, it can strengthen the Rule-Skill Split pattern by turning hard constraints into portable, dynamically loaded skills. Install: `npx skills add motiful/rules-as-skills`. Without it, forge uses the built-in `references/rule-skill-pattern.md` pattern.

## Step 2: Create

Write SKILL.md following the Agent Skills open standard. See `references/skill-format.md` for the complete format specification (frontmatter, CC extensions, body conventions, file structure, content guidelines).

Key principle: write for another AI agent, not a human. Keep body under 500 lines — use `references/` files for detailed content.

### Baking In Detected Capabilities

For each capability detected in Step 1, bake the corresponding pattern into the generated SKILL.md:

- **Onboarding** → Add a Step 0 section with the initialization check and onboarding flow
- **State Management** → Add config/state read-write instructions for persistent state, keeping stable preferences separate from evolving registries or history
- **Rule-Skill Split** → Create a separate `<name>-rules` skill alongside the main skill, but keep the main skill usable on its own. If `<name>-rules` is absent, the generated skill must fall back to its built-in/default behavior and say that explicitly

These capabilities are **transparent to the end user** — they work without the end user having skill-forge or any methodology skills installed. Forge bakes them in at creation time; the generated skill is self-contained.

If another independently installable skill would strengthen a specific step, describe it in plain prose at that step, include the install command, and state the full fallback behavior without it. Do not turn this into a separate capability or repo type.

### Recommended Skills Inside a Single Skill

If the skill being created would benefit from recommended skills, keep them inside the single-skill flow. See `references/publishing-strategy.md` for the pattern, the README mirror rules, and when to move from a single skill to a Kit.

Use recommended skills only when they are genuinely optional. A recommendation must never hide a real dependency; the skill must still complete the job without it installed.
For all other optional behavior, prefer a concrete workflow rule:

- If the step only uses repo-local scripts or already-available tools, keep it in the main flow and run it when helpful.
- If the step needs repo-local dependencies and the change is a reversible two-way door, default to doing it rather than surfacing it as a skill recommendation.
- Only escalate to user confirmation when the action would introduce a new long-lived context dependency, change system-level state, or cross a trust boundary the user may reasonably care about.

## Step 3: Validate

Before publishing, check:

| Check | Criteria |
|-------|----------|
| Frontmatter fields | Only standard top-level fields: `name`, `description`, `license`, `metadata`, `compatibility`, `allowed-tools`. Put CC-specific or custom fields inside `metadata` |
| `name` | kebab-case, max 64 chars, lowercase alphanumeric + hyphens |
| `description` | Present, < 1024 chars, **single-line** (no YAML multi-line `>-` or `|` — causes skills to silently disappear in CC) |
| Body | Under 500 lines, has meaningful content (not just TODOs) |
| References | All files referenced in SKILL.md actually exist |
| No junk files | For multi-skill repos: no README.md, CHANGELOG.md, or docs inside `skills/<name>/`. For single-skill repos: SKILL.md, references/, assets/, scripts/ at root alongside README.md and LICENSE is the expected structure |
| Triggers | Description covers all intended trigger scenarios |
| Recommended skills | If present: max 2; each recommendation sits at the step it enhances, includes the install command, and states a real fallback. Reject any "recommend" that is actually a required dependency |
| Terminology consistency | Extract core terms defined in SKILL.md. Check for: terms that conflict with the skill's own name (e.g., a skill called "self-review" that also uses "review" as a domain concept with different meaning), terms used with different meanings in different sections, terms that conflict with platform concepts (e.g., using "tool" in a way that conflicts with the agent platform's "tool" concept). Report conflicts — don't auto-fix, as naming is a design decision |
| Directory names | The Agent Skills standard names three skill directories: `references/`, `assets/`, `scripts/`. Flag non-standard directory names used for skill content (e.g., `templates/` → suggest `assets/`, `docs/` used for skill references → suggest `references/`). Directories serving only GitHub/repo presentation (like `docs/` for a logo gallery or `examples/` for demo files) are repo infrastructure and do not need renaming — just confirm they are not referenced by SKILL.md as skill content. Auto-fix when the mapping is unambiguous and the user confirms |
| Script quality | If `scripts/` exists: no single file >500 lines without justification; CLI parsing separated from business logic. See `references/script-quality.md` |

The manual checks above are the core validation path. If the user already has `skills-ref` installed, run `skills-ref validate <path>` as a final pre-publish sanity check. If not installed, skip it without adding setup work. Treat it as optional reassurance, not a dependency.
Treat recommended-skills checks as a manual review item even if `skills-ref` passes; community validators may not encode this pattern yet.

### Community Readiness (optional)

If the user wants maximum discoverability (good structure, disciplined claims, and clean install paths make downstream distribution easier):

| Check | Criteria |
|-------|----------|
| README quality | Value-first structure, claim discipline, and example clarity. See `references/readme-quality.md` and `references/templates.md` |
| Install command | Primary: `npx skills add <org>/<repo>`. Manual clone as fallback only |
| Recommended skills | If SKILL.md recommends other skills, mirror them in a concise README section (for example, "Works Better With") and clearly state that the skill still works on its own |
| Discoverability claims | README may promise direct install by repo path; do not imply GitHub publication guarantees immediate listing, search placement, or leaderboard visibility unless the platform docs explicitly say so |
| No hardcoded paths | No personal paths (~/ expanded, /Users/specific/) in published files |
| LICENSE exists | Required for community platforms |
| Description clarity | Description alone should tell a stranger what this skill does and when to use it |
| Security | If skill contains scripts, document what they do and what permissions they need |

## Step 4: Publish

Before creating the repo, determine the publishing strategy. See `references/publishing-strategy.md` for detailed guidance.

**Quick decision:** Publishing one skill → Skill repo (SKILL.md at root). If another skill genuinely strengthens one step, mention it in that step and README. Publishing multiple skills → see `references/publishing-strategy.md` for the full decision framework (Skill vs Kit vs Collection). For the philosophy behind composition, see `references/skill-composition.md`.

Think about Step 4 in three layers, in this order:

1. **Public Artifact** — what gets published and how strangers will evaluate/install it
2. **Remote Publish** — git + remote hosting
3. **Local Registration** — optional convenience on the current machine

Do not let local registration convenience redefine the public artifact.

### 4a. Public Artifact

#### Repo structure

```
<skill_root>/<skill-name>/         # repo root (skill_root from Step 0 config)
├── SKILL.md                       # skill content (at root for npx skills add discovery)
├── references/                    # if needed
├── scripts/                       # if needed
├── README.md                      # GitHub-facing description
├── LICENSE                        # from config, default MIT
└── .gitignore
```

#### README.md

**Recommended:** Use readme-craft for README generation — it provides 3-tier layout strategy (above-fold / scan / reference), badge selection, dark/light logo patterns, GitHub-native formatting, and README improvement mode. Install: `npx skills add motiful/readme-craft`. Without it, forge uses its built-in templates below.

See `references/templates.md` for the file skeletons and `references/readme-quality.md` for writing/validation rules. Key requirements:
- **Value-first structure**: Problem → What It Does → Usage → Install → What's Inside
- Must mention [Agent Skills](https://agentskills.io) compatibility
- Primary install: `npx skills add <org>/<skill-name>`. Manual clone as fallback
- If recommended skills exist, summarize them in a concise README section and state that the skill still works on its own
- Manual fallback may show common agent examples, but do not imply every reader should register every platform
- Must include a "What's Inside" section showing the skill files (SKILL.md, references/, scripts/)
- Must include a "Forged with Skill Forge" footer with link to forge repo (signature, not dependency)

#### .gitignore

Use the template from `references/templates.md`.

### 4b. Preflight Confirmation

Before any side effect outside the current repo artifact, summarize the exact actions and get explicit confirmation once.

The preflight must include:
- config/state files to create or update (`~/.config/skill-forge/config.md`, `~/.config/skill-forge/state.md`, `<skill_root>/.gitignore`, repo-local `.gitignore` changes if any)
- local repo actions (`git init`, initial commit, target repo path)
- remote target (`<org>/<skill-name>`, visibility, hosting service)
- detected registration roots that will be linked
- any new platform roots that will be created because the user explicitly named that platform

After the user confirms, execute Remote Publish and Local Registration without further mode-selection questions unless new ambiguity appears.

For user-visible messages, use task language rather than internal workflow language:
- say "Before I publish this, here's what I'll create/update" instead of "preflight"
- say "connect it to the tools already active on this machine" instead of "link into detected registration roots"
- say "GitHub repo and visibility" instead of "remote target"
- avoid surfacing "mode", "recommended skills", "Kit", or "Collection" unless the user's request actually requires those concepts

### 4c. Remote Publish

#### Git init (local)

```bash
cd <skill_root>/<skill-name>
git init
git add -A
git commit -m "init: <skill-name> skill"
```

This prepares the publishable repo. It does not imply any local registration yet.

#### Update skill_root .gitignore

If `<skill_root>` is a git repo (or has a `.gitignore`), add `<skill-name>/` if not already present.

#### Update forge state

Add the new skill to `~/.config/skill-forge/state.md` under a "Published Skills" section (create if absent). This is forge-managed registry state, not a user preference.

#### Push to remote

All local setup is complete. Now push.

**GitHub (default):**
```bash
gh repo create <org>/<skill-name> --public --source=. --push
```

The `<org>` comes from the forge config. Include the exact org, repo name, and visibility in the Step 4 preflight. Do not run `gh repo create` until the user confirms.

**Non-GitHub remotes:** Follow the user's existing conventions. Ask for the remote URL:
```bash
git remote add origin <url> && git push -u origin main
```

#### Community distribution

**GitHub publication makes the repo directly installable.** Pushing a well-structured repo (valid SKILL.md + good README) is sufficient for direct installs such as `npx skills add <org>/<skill-name>`.

Community directory visibility is downstream behavior. Some directories or leaderboards surface skills only after their own indexing or install telemetry. Do not promise immediate listing just because the repo is public.

See `references/platform-registry.md` for the current list of community directories and tools.

Tell the user: *"Your skill is now on GitHub. Anyone who knows `<org>/<skill-name>` can install it with `npx skills add <org>/<skill-name>`. Community directories may surface it later based on their own indexing or install telemetry."*

### 4d. Local Registration (Optional Convenience)

Use `<skill_root>/<skill-name>/` as the source of truth. Local registration is a convenience layer for the current machine, not part of the public artifact contract.

**Do not ask the user to choose a registration mode.** Detect roots automatically, include the planned links in the Step 4 preflight, and act after explicit confirmation. Only ask when you genuinely cannot infer intent.

Treat only actual skill roots as strong signals. Parent directories such as `<project>/.github/`, `<project>/.claude/`, or `<project>/.agents/` are not registration evidence on their own.

See `references/platform-registry.md` for the platform matrix and policy details.

#### Decision Logic

```
1. Scan for existing skill roots (strong signals only)
   Strong: ~/.claude/skills/, ~/.agents/skills/, ~/.copilot/skills/,
           ~/.cursor/skills/, ~/.codeium/windsurf/skills/
   Strong: <project>/.claude/skills/, <project>/.agents/skills/,
           <project>/.github/skills/, <project>/.cursor/skills/,
           <project>/.windsurf/skills/
   Weak (ignore): installed CLI without skill root, generic config dirs,
                  bare parent dirs like <project>/.github/ or <project>/.claude/

2. Roots found?
   YES → add them to the preflight summary; after confirmation, link into all detected skill roots and report what you did
   NO  → skip registration, tell user the repo is ready

3. User explicitly names a platform not yet detected?
   → Add creation of that platform's root to the preflight; after confirmation, create and link. Only for explicitly named platforms.
```

Never link one vendor root to another vendor root. Every consumer root should point back to `<skill_root>/<skill-name>/`.

#### Link Examples

```bash
# Existing root — just link
ln -sfn <skill_root>/<skill-name> ~/.claude/skills/<skill-name>

# User explicitly requested a new platform
mkdir -p ~/.agents/skills
ln -sfn <skill_root>/<skill-name> ~/.agents/skills/<skill-name>
```

#### Output

```text
Linked:
✓ ~/.claude/skills/<name> → <skill_root>/<name>/

No new platform directories created.
```

## Migration: Project-Local to Published

When publishing an existing project-local skill:

```
Source: <project>/.claude/skills/bar/    (or platform equivalent)
Target: <skill_root>/bar/
```

1. Copy content: `cp -r <source>/* <skill_root>/<name>/`
2. Review and clean up (remove project-specific references)
3. Follow Steps 3-4 above
4. Original stays in the project (independent evolution)

## References

- `references/skill-format.md` — SKILL.md format specification (frontmatter, structure, guidelines)
- `references/platform-registry.md` — Platform skill paths, detection logic, community tools. Read by the Local Registration section at publish time
- `references/onboarding-pattern.md` — First-use onboarding: detection, flow design, config as marker
- `references/state-management.md` — Persistent state: `~/.config/` convention, project-specific state
- `references/rule-skill-pattern.md` — Rule-Skill user customization: detection, decision tree, packaging
- `references/publishing-strategy.md` — Skill/Kit/Collection publishing models, plus recommended-skills rules inside single skills
- `references/skill-composition.md` — Composition philosophy: context budget constraint, tooling landscape
- `references/templates.md` — README, LICENSE, and .gitignore skeletons
- `references/readme-quality.md` — README writing, claim discipline, and example rules
- `references/script-quality.md` — Script file size limits, module split triggers, complexity thresholds, dependency policy
