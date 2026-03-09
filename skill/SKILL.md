---
name: skill-forge
description: Create, validate, and publish skills to GitHub as independent repos. Use when the user says "publish this skill", "create a skill", "forge a skill", "skill to GitHub", or wants to turn a project-local skill into a shareable GitHub repository. Handles the full pipeline from content creation to git init, GitHub repo creation, and symlink registration.
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
4. Publish → git init (local) → symlink → push → optional community publishing
```

## Step 0: Ensure Configuration

### Positioning

SkillForge creates **independent, publishable skill repositories**. Each skill gets its own git repo, its own README, its own lifecycle. This is the right tool when the goal is to maintain, share, or publish a skill beyond a single project.

If the user just wants a quick project-internal skill (lives in `.claude/skills/` of one project, not shared), they don't need SkillForge — the platform's built-in skill creator is sufficient. Guide them there instead.

**Reassurance for first-time users**: SkillForge isn't "taking your skill away" from your project. It's giving your skill its own home so it can be installed anywhere, versioned independently, and shared with others. Your project can still use it via a symlink.

### Config check

Read `~/.config/skill-forge/config.md`.

**Found** → read user's preferences and proceed.

**Not found** → create config with sensible defaults, confirm with user:

```markdown
# Skill Forge Config

## Defaults

- skill_root: ~/skills/
- github_org: <auto-detect via `gh api user -q .login`, ask if `gh` unavailable>
- license: MIT
```

**`skill_root`** defaults to `~/skills/`. Tell the user: *"Your skills will live in `~/skills/` — each skill gets its own folder and git repo there. You can change this anytime in `~/.config/skill-forge/config.md`."*

Detect what you can (`github_org` via `gh`, platform from the current agent). Only ask when auto-detection fails. Don't interrogate — detect, default, confirm.

## Step 1: Gather

### Context Detection (automatic)

Before asking anything, detect what's already available:

1. **Current project scan** — Look for existing skill content:
   - `.claude/skills/*/SKILL.md` (or platform equivalent)
   - `skill/SKILL.md` in the working directory
   - Any `SKILL.md` file the user might be working on

2. **Conversation context** — Has the user been discussing a skill idea? Are there notes, specs, or requirements already in the conversation?

3. **Explicit references** — Did the user point to specific files or directories?

**If content found** → summarize what was detected, confirm with the user: *"I found an existing skill at `<path>`. I'll use this as the basis — anything you want to change?"*

**If nothing found** → then ask:
- What does this skill do? (1-2 sentences)
- When should it trigger? (specific phrases, file types, scenarios)

### Capability Detection

Every skill potentially needs three independent capabilities. Detect which ones apply:

| Capability | Detection Question | If Yes |
|------------|-------------------|--------|
| **Onboarding** | Does this skill need first-use setup? (dependency checks, user preferences, guided introduction) | See `references/onboarding-pattern.md` |
| **State Management** | Does this skill need to remember things across sessions? (preferences, history, registries) | See `references/state-management.md` |
| **Constraint Companion** | Does this skill have user-customizable constraints? (MUST/NEVER rules, domain boundaries) | See `references/constraint-companion.md` |

A skill may need any combination (all three, one, or none). Each is independent — detect and apply separately.

## Step 2: Create

Write SKILL.md following the Agent Skills open standard. See `references/skill-format.md` for the complete format specification (frontmatter, CC extensions, body conventions, file structure, content guidelines).

Key principle: write for another AI agent, not a human. Keep body under 500 lines — use `references/` files for detailed content.

### Baking In Detected Capabilities

For each capability detected in Step 1, bake the corresponding pattern into the generated SKILL.md:

- **Onboarding** → Add a Step 0 section with the initialization check and onboarding flow
- **State Management** → Add config read/write instructions for persistent state
- **Constraint Companion** → Create a separate `<name>-rules` skill alongside the main skill

These capabilities are **transparent to the end user** — they work without the end user having skill-forge or any methodology skills installed. Forge bakes them in at creation time; the generated skill is self-contained.

## Step 3: Validate

Before publishing, check:

| Check | Criteria |
|-------|----------|
| Frontmatter fields | Only standard top-level fields: `name`, `description`, `license`, `metadata`, `compatibility`, `allowed-tools`. Put CC-specific or custom fields inside `metadata` |
| `name` | kebab-case, max 64 chars, lowercase alphanumeric + hyphens |
| `description` | Present, < 1024 chars, **single-line** (no YAML multi-line `>-` or `|` — causes skills to silently disappear in CC) |
| Body | Under 500 lines, has meaningful content (not just TODOs) |
| References | All files referenced in SKILL.md actually exist |
| No junk files | No README.md, CHANGELOG.md, or docs inside `skill/` (those go in repo root) |
| Triggers | Description covers all intended trigger scenarios |
| Terminology consistency | Extract core terms defined in SKILL.md. Check for: terms that conflict with the skill's own name (e.g., a skill called "self-review" that also uses "review" as a domain concept with different meaning), terms used with different meanings in different sections, terms that conflict with platform concepts (e.g., using "tool" in a way that conflicts with the agent platform's "tool" concept). Report conflicts — don't auto-fix, as naming is a design decision |

If `skills-ref` CLI is available, run `skills-ref validate` for automated checking. If not available, validate manually against the checks above.

### Community Readiness (optional)

If the user wants maximum discoverability (most platforms auto-index from GitHub, so good structure = good distribution):

| Check | Criteria |
|-------|----------|
| README quality | Value-first structure: problem/solution before install. See `references/templates.md` |
| Install command | Primary: `npx skills add <org>/<repo>`. Manual clone as fallback only |
| No hardcoded paths | No personal paths (~/ expanded, /Users/specific/) in published files |
| LICENSE exists | Required for community platforms |
| Description clarity | Description alone should tell a stranger what this skill does and when to use it |
| Security | If skill contains scripts, document what they do and what permissions they need |

## Step 4: Publish

Execute these steps in order:

### 4a. Create repo structure

```
<skill_root>/<skill-name>/         # repo root (skill_root from Step 0 config)
├── skill/                         # skill content (CC reads this)
│   ├── SKILL.md
│   ├── references/                # if needed
│   └── scripts/                   # if needed
├── README.md                      # GitHub-facing description
├── LICENSE                        # from config, default MIT
└── .gitignore
```

### 4b. Generate README.md

See `references/templates.md` for the full README template. Key requirements:
- **Value-first structure**: Problem → What It Does → Usage → Install → What's Inside
- Must mention [Agent Skills](https://agentskills.io) compatibility
- Primary install: `npx skills add <org>/<skill-name>`. Manual clone as fallback
- No per-platform install sections — `npx skills add` handles platform detection
- Must include a "What's Inside" section showing the `skill/` directory structure

### 4c. Generate .gitignore

```
.DS_Store
*.skill
```

### 4d. Git init (local)

```bash
cd <skill_root>/<skill-name>
git init
git add -A
git commit -m "init: <skill-name> skill"
```

Local repo only. Remote push happens in Step 4h after all local setup is complete.

### 4e. Register skill via symlink

Ask the user about registration scope:

**Global** (available across all projects):
```bash
ln -sfn <skill_root>/<skill-name>/skill ~/.claude/skills/<skill-name>
```
The skill appears in the agent's skill listing everywhere.

**Project-level** (current project only):
```bash
ln -sfn <skill_root>/<skill-name>/skill <project>/.claude/skills/<skill-name>
```
The skill only appears when working in this project.

Each user's preference per skill may differ — some skills are universal tools, others are project-specific. Don't assume; ask once per skill.

Currently optimized for Claude Code. For other platforms (Cursor, Codex, OpenClaw), the symlink pattern is the same but install paths may vary — use web research to check the platform's current conventions when needed.

### 4f. Update skill_root .gitignore

If `<skill_root>` is a git repo (or has a `.gitignore`), add `<skill-name>/` if not already present.

### 4g. Update forge config

Add the new skill to `~/.config/skill-forge/config.md` under a "Published Skills" section (create if absent). This serves as a registry of all skills managed by forge.

### 4h. Push to remote

All local setup is complete. Now push.

**GitHub (default):**
```bash
gh repo create <org>/<skill-name> --public --source=. --push
```

The `<org>` comes from the forge config. Ask if the user wants a different org or visibility (public/private).

**Non-GitHub remotes:** Follow the user's existing conventions. Ask for the remote URL:
```bash
git remote add origin <url> && git push -u origin main
```

### 4i. Community distribution

**Most community platforms auto-index from GitHub.** Pushing a well-structured repo (valid SKILL.md + good README) is sufficient for discoverability on skills.sh, SkillsMP, agentskills.in, LobeHub, and others. No active submission needed.

Tell the user: *"Your skill is now on GitHub. Community platforms like skills.sh auto-index public repos — anyone can install it with `npx skills add <org>/<skill-name>`. No extra submission needed."*

**Optional: ClawHub (OpenClaw registry)**

If the user wants to publish to ClawHub specifically:

1. Run the Community Readiness checks from Step 3
2. Two paths: `clawhub publish` CLI (requires `npm i -g openclaw-core clawhub`) or fork+PR on the `clawhub/registry` GitHub repo
3. GitHub account must be 1+ week old. Review is community-driven (2-5 days)
4. OpenClaw itself is NOT required to publish — just the CLI tools

This step is optional. GitHub push already provides broad distribution.

## Migration: Project-Local to Published

When publishing an existing project-local skill:

```
Source: <project>/.claude/skills/bar/    (or platform equivalent)
Target: <skill_root>/bar/skill/
```

1. Copy content: `cp -r <source>/* <skill_root>/<name>/skill/`
2. Review and clean up (remove project-specific references)
3. Follow Steps 3-4 above
4. Original stays in the project (independent evolution)

## References

- `references/skill-format.md` — SKILL.md format specification (frontmatter, structure, guidelines)
- `references/onboarding-pattern.md` — First-use onboarding: detection, flow design, config as marker
- `references/state-management.md` — Persistent state: `~/.config/` convention, project-specific state
- `references/constraint-companion.md` — Constraint separation: rule-skill creation, self-containment
- `references/templates.md` — README, LICENSE, and .gitignore templates
