# skill-forge

> Create, validate, and publish skills to GitHub as independent repos.

## What This Is

A [Claude Code](https://claude.com/claude-code) skill that handles the full pipeline from skill creation to GitHub publication. When you have a skill idea or an existing project-local skill, skill-forge automates: content creation following CC conventions, validation, git init, GitHub repo creation, push, and symlink registration.

## Install

### Claude Code

```bash
# Clone the repo
git clone https://github.com/motiful/skill-forge ~/motifpool/skill-forge

# Register as a global skill
ln -s ~/motifpool/skill-forge/skill ~/.claude/skills/skill-forge
```

### Other AI Tools

The skill's knowledge is in `skill/SKILL.md` and `skill/references/`. You can adapt these files for your tool's format (e.g., append to AGENTS.md, include in system prompt).

## What's Inside

```
skill/
├── SKILL.md              — Main skill instructions (creation + publishing pipeline)
└── references/
    └── templates.md      — README, LICENSE, .gitignore templates
```

## Usage

In Claude Code, say any of:
- "Create a skill for X and publish it to GitHub"
- "Publish this skill to GitHub"
- "Forge a skill from my notes"
- "Turn this project-local skill into a GitHub repo"

## License

MIT
