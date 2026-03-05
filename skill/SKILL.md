---
name: skill-forge
description: Create, validate, and publish skills to GitHub as independent repos. Use when the user says "publish this skill", "create a skill", "forge a skill", "skill to GitHub", or wants to turn a project-local skill into a shareable GitHub repository. Handles the full pipeline from content creation to git init, GitHub repo creation, and symlink registration.
---

# Skill Forge

Full pipeline for creating and publishing skills as independent GitHub repositories.

## When to Use

- User has a skill idea and wants it as a GitHub repo
- User has an existing project-local skill (`.claude/skills/foo/`) and wants to publish it
- User says "publish", "forge", "create a skill", "put this skill on GitHub"

## Pipeline

```
1. Gather  → understand what the skill does (examples, triggers, scope)
2. Create  → write SKILL.md + references/ + scripts/ following CC conventions
3. Validate → check frontmatter, structure, content quality
4. Publish → git init, GitHub repo, push, symlink
```

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
~/motifpool/<skill-name>/          # repo root
├── skill/                         # skill content (CC reads this)
│   ├── SKILL.md
│   ├── references/                # if needed
│   └── scripts/                   # if needed
├── README.md                      # GitHub-facing description
├── LICENSE                        # MIT by default
└── .gitignore
```

### 4b. Generate README.md

```markdown
# <Skill Name>

> <one-line description from SKILL.md frontmatter>

## What This Is

A [Claude Code](https://claude.com/claude-code) skill that <description>.

## Install

```bash
git clone https://github.com/<org>/<skill-name> ~/motifpool/<skill-name>
ln -s ~/motifpool/<skill-name>/skill ~/.claude/skills/<skill-name>
```

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

### 4d. Git init + GitHub create + push

```bash
cd ~/motifpool/<skill-name>
git init
git add -A
git commit -m "init: <skill-name> skill"
gh repo create <org>/<skill-name> --public --source=. --push
```

The `<org>` defaults to the user's GitHub username. Ask if they want a different org.

### 4e. Register symlink

```bash
ln -sfn ~/motifpool/<skill-name>/skill ~/.claude/skills/<skill-name>
```

### 4f. Update motifpool .gitignore

Add `<skill-name>/` to `~/motifpool/.gitignore` if not already present.

### 4g. Update skill-publishing convention

If the user has `~/.claude/rules/skill-publishing.md`, add the new skill to the "已迁移的 Skills" table.

## Migration: Project-Local to Published

When publishing an existing project-local skill:

```
Source: ~/projects/foo/.claude/skills/bar/
Target: ~/motifpool/bar/skill/
```

1. Copy content: `cp -r <source>/* ~/motifpool/<name>/skill/`
2. Review and clean up (remove project-specific references)
3. Follow Steps 3-4 above
4. Original stays in the project (independent evolution)

## References

- `references/templates.md` — README and LICENSE templates
