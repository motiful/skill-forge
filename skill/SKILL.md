---
name: skill-forge
description: Create, validate, and publish skills to GitHub as independent repos. Use when the user says "publish this skill", "create a skill", "forge a skill", "skill to GitHub", or wants to turn a project-local skill into a shareable GitHub repository. Handles the full pipeline from content creation to git init, GitHub repo creation, and symlink registration.
---

# Skill Forge

Full pipeline for creating and publishing skills as independent GitHub repositories.

## Relationship with Other Tools

**skill-creator** (CC built-in) handles skill *design methodology* — it guides users through what a skill should do, how to structure the content, and generates initial SKILL.md scaffolding. It's always available without installation.

**skill-forge** handles *format validation + publishing* — it takes a skill (whether created by skill-creator, hand-written, or migrated from a project) and turns it into a published GitHub repo with proper structure, symlinks, and registration.

They complement each other: skill-creator helps you *think through* the skill; skill-forge helps you *ship* it. You can use either independently.

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
0. Config  → ensure user's publishing preferences exist
1. Gather  → understand what the skill does (examples, triggers, scope)
2. Create  → write SKILL.md + references/ + scripts/ following Agent Skills standard
3. Validate → check frontmatter, structure, content quality
4. Publish → git init, remote push, symlink
```

## Step 0: Ensure Configuration

Before any publish operation, read `~/.config/skill-forge/config.md`.

**Found** → read user's preferences: `skill_root`, git remote defaults, default license, skill install paths.

**Not found** → ask user, then generate `~/.config/skill-forge/config.md`:

1. Where to store skill repos? (suggest `~/skills/` as default)
2. Git remote preference? (GitHub org via `gh api user -q .login`, or other)
3. Default license? (suggest MIT)
4. Which AI platform(s)? (CC, Cursor, OpenClaw, etc. — determines install paths)

Example generated config:

```markdown
# Skill Forge Config

## Defaults

- skill_root: ~/skills/
- git_remote: github
- github_org: motiful
- license: MIT

## Skill Install Paths

Where skills are registered on each platform the user uses:

- claude_code: ~/.claude/skills/
- cursor: ~/.cursor/skills/

## Directory Structure

\```
<skill_root>/<skill-name>/
├── skill/
│   ├── SKILL.md
│   ├── references/
│   └── scripts/
├── README.md
├── LICENSE
└── .gitignore
\```
```

All subsequent steps use values from this config. No hardcoded platform paths.

## Step 1: Gather

Ask the user:
- What does this skill do? (1-2 sentences)
- When should it trigger? (specific phrases, file types, scenarios)
- Any existing content to migrate? (project-local skill, notes, docs)

If migrating from a project-local skill, read the existing files first.

## Step 2: Create

### SKILL.md Format (Agent Skills Open Standard + CC Extensions)

Skills follow the **Agent Skills open standard** (agentskills.io), adopted by Claude Code, Microsoft Copilot, OpenAI ChatGPT, GitHub, Cursor, Atlassian, and Figma.

**Standard frontmatter** (works on all Agent Skills platforms):
```yaml
---
name: kebab-case-name       # required, max 64 chars, lowercase alphanumeric + hyphens
description: >-             # required, max 1024 chars, no angle brackets
  What it does + when to trigger.
  Include all trigger conditions here, NOT in the body.
  The description IS the trigger mechanism.
license: MIT                # optional
compatibility: node>=18     # optional, system requirements
metadata:                   # optional, custom key-value pairs
  author: name
  version: "1.0"
---
```

**CC-specific extensions** (only use if not targeting other platforms):
```yaml
disable-model-invocation: true   # only user can invoke via /skill-name
user-invocable: false            # only Claude auto-triggers, not in / menu
allowed-tools: Read, Grep, Bash  # restrict tool access when active
model: claude-opus-4-6           # override model for this skill
context: fork                    # run in isolated subagent
agent: Explore                   # subagent type (Explore, Plan, general-purpose)
argument-hint: "[file] [format]" # show expected args in autocomplete
```

**Body** supports string substitutions: `$ARGUMENTS`, `$0`, `$1`, `${CLAUDE_SKILL_DIR}`.

Body: instructions for the AI agent. Keep under 500 lines. Use progressive disclosure — put details in `references/` files, reference them from SKILL.md.

### File Structure

```
skill-name/
├── skill/
│   ├── SKILL.md              # required
│   ├── references/           # optional, loaded on demand
│   └── scripts/              # optional, executable utilities
├── README.md                 # required for GitHub
├── LICENSE                   # required for GitHub (default: MIT)
└── .gitignore
```

### Content Guidelines

- Write for another AI agent, not a human. Include non-obvious procedural knowledge.
- Only add what the AI doesn't already know. Don't explain basic concepts.
- Prefer concise examples over verbose explanations.
- References: one level deep from SKILL.md. Large files (>100 lines) get a TOC.
- Delete empty directories (don't create scripts/ or references/ if unused).

### Cross-Platform Compatibility

Skills follow the Agent Skills open standard. For maximum portability:
- Use only standard frontmatter fields (name, description, license, compatibility, metadata)
- Avoid CC-specific extensions unless the skill truly needs them
- README.md serves as the human-readable + other-AI-tool-readable entry point
- Skill's core knowledge in SKILL.md body is platform-agnostic markdown

## Step 3: Validate

Before publishing, check:

| Check | Criteria |
|-------|----------|
| Frontmatter | `name` and `description` present, name is kebab-case, description < 1024 chars |
| Body | Under 500 lines, has meaningful content (not just TODOs) |
| References | All files referenced in SKILL.md actually exist |
| No junk files | No README.md, CHANGELOG.md, or docs inside `skill/` (those go in repo root) |
| Triggers | Description covers all intended trigger scenarios |

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

```markdown
# <Skill Name>

> <one-line description from SKILL.md frontmatter>

## What This Is

An [Agent Skills](https://agentskills.io) compatible skill that <description>.

## Install

```bash
git clone https://github.com/<org>/<skill-name> ~/skills/<skill-name>
```

Then register on your platform:

| Platform | Command |
|----------|---------|
| Claude Code | `ln -s ~/skills/<skill-name>/skill ~/.claude/skills/<skill-name>` |
| Cursor | `ln -s ~/skills/<skill-name>/skill ~/.cursor/skills/<skill-name>` |

## Usage

<brief usage notes extracted from SKILL.md>

## License

MIT
```

### 4c. Generate .gitignore

```
.DS_Store
*.skill
```

### 4d. Git init + remote push

```bash
cd <skill_root>/<skill-name>
git init
git add -A
git commit -m "init: <skill-name> skill"
```

**GitHub (default):**
```bash
gh repo create <org>/<skill-name> --public --source=. --push
```

The `<org>` defaults to the user's GitHub username. Ask if they want a different org.

**Non-GitHub remotes:** If the user's project uses a non-GitHub git remote (GitLab, Bitbucket, self-hosted), follow their existing remote conventions. Ask for the remote URL, then `git remote add origin <url> && git push -u origin main`. The rest of the pipeline (symlink, .gitignore, etc.) works identically.

### 4e. Register skill on user's platforms

Read the `Skill Install Paths` from `~/.config/skill-forge/config.md`. Create symlinks for each platform the user has configured:

```bash
# Example: user has claude_code and cursor configured
ln -sfn <skill_root>/<skill-name>/skill ~/.claude/skills/<skill-name>
ln -sfn <skill_root>/<skill-name>/skill ~/.cursor/skills/<skill-name>
```

If config has no install paths yet, ask the user which platform(s) they use and update the config.

### 4f. Update skill_root .gitignore

If `<skill_root>` is a git repo (or has a `.gitignore`), add `<skill-name>/` if not already present.

### 4g. Update forge config

Add the new skill to `~/.config/skill-forge/config.md` under a "Published Skills" section (create if absent). This serves as a registry of all skills managed by forge.

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

- `references/templates.md` — README and LICENSE templates
