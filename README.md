# Skill Forge

> Create, validate, and publish skills as independent repos — for any AI agent platform.

## What This Is

An [Agent Skills](https://agentskills.io) compatible skill that handles the full pipeline from skill creation to publication. Follows the Agent Skills open standard adopted by Claude Code, Cursor, Microsoft Copilot, GitHub, and others.

Skill Forge takes a skill idea (or an existing project-local skill) and automates: content creation following the Agent Skills standard, validation, git init, remote push, and registration on your platform(s).

## Install

### Claude Code

```bash
# From marketplace (if published)
/skill install motiful/skill-forge

# Or manual
git clone https://github.com/motiful/skill-forge ~/skills/skill-forge
ln -s ~/skills/skill-forge/skill ~/.claude/skills/skill-forge
```

### Cursor

```bash
git clone https://github.com/motiful/skill-forge ~/skills/skill-forge
ln -s ~/skills/skill-forge/skill ~/.cursor/skills/skill-forge
```

### Other Platforms

Clone the repo and symlink/copy `skill/` to your agent's skills directory.

## What's Inside

```
skill/
├── SKILL.md              — Main skill instructions (creation + publishing pipeline)
└── references/
    └── templates.md      — README, LICENSE, .gitignore templates
```

## Usage

Say any of:
- "Create a skill for X and publish it"
- "Publish this skill to GitHub"
- "Forge a skill from my notes"
- "Turn this project-local skill into a repo"

## Cross-Platform

Skill Forge creates skills that work on any Agent Skills compatible platform. On first use, it asks which platform(s) you use and stores preferences in `~/.config/skill-forge/config.md`.

## License

MIT
