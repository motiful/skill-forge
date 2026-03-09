# Skill Forge

> From idea to published, installable AI skill — in one pipeline.

Say "publish this skill" and Skill Forge handles the rest — from writing SKILL.md to pushing a ready-to-install repo to GitHub.

[Agent Skills](https://agentskills.io) compatible — works with Claude Code, Cursor, Codex, Windsurf, Gemini CLI, GitHub Copilot, and more.

## The Problem

You wrote a great skill. It works locally. But:

- It's trapped in one project's skills directory — not a proper, installable package
- You can't share it across machines, let alone with other people
- It doesn't meet any platform's install standard — no README, no LICENSE, no proper structure
- There's no versioning, no discoverability, no community presence
- Publishing means figuring out GitHub repo setup, README conventions, symlink registration, and community platform requirements — all manually

Your skill is trapped. It can't be maintained globally, iterated on independently, or shared with the community.

## What Skill Forge Does

Takes a skill idea (or an existing project-local skill) and runs the full pipeline:

```
Config → Gather → Create → Validate → Publish
```

0. **Config** — Set up `~/skills/` root, detect your GitHub org and preferences (auto-defaults, minimal questions)
1. **Gather** — Auto-detect existing skill content from project and conversation. Detect capabilities needed (onboarding, state management, constraint companion)
2. **Create** — Write SKILL.md following the [Agent Skills](https://agentskills.io) standard, bake detected capabilities in
3. **Validate** — Structure, frontmatter, `skills-ref validate` compatibility, content quality, optional community readiness checks
4. **Publish** — `git init`, register symlinks, push to GitHub. Pushing to GitHub auto-indexes on skills.sh, SkillsMP, and other community platforms

The result: a standalone repo that anyone can install with one command.

### Built-in Capabilities

Every skill Skill Forge creates is evaluated for three independent capabilities:

- **Onboarding** — First-use setup (preferences, dependency checks, guided introduction)
- **State Management** — Persistent data across sessions (config, history, registries)
- **Constraint Companion** — MUST/NEVER rules separated into a companion rule-skill for visibility

## Usage

Say any of:
- "Create a skill for X and publish it"
- "Publish this skill to GitHub"
- "Forge a skill from my notes"
- "Turn this project-local skill into a repo"

### Example: Publishing self-review (Real Output)

```
$ "Publish self-review to GitHub"

Step 0: Config
  ✓ ~/.config/skill-forge/config.md found
  ✓ skill_root: ~/motifpool/, github_org: motiful

Step 1: Gather
  ✓ Existing skill detected at ~/motifpool/self-review/skill/SKILL.md
  ✓ Capabilities: none needed (pure methodology, no state or onboarding)

Step 2: Create
  ✓ SKILL.md already exists — using as-is

Step 3: Validate
  ✓ name: self-review (kebab-case, 11 chars)
  ✓ description: single-line, 133 chars
  ✓ body: 226 lines (< 500)
  ✓ references/dimensions.md exists and is linked
  ✓ no junk files in skill/

Step 4: Publish
  ✓ git init + initial commit
  ✓ ~/.claude/skills/self-review → ~/motifpool/self-review/skill/
  ✓ ~/.agents/skills/self-review → ~/motifpool/self-review/skill/
  ✓ gh repo create motiful/self-review --public --source=. --push
  ✓ Published — install with: npx skills add motiful/self-review
```

## Install

```bash
npx skills add motiful/skill-forge
```

Or manually:

```bash
git clone https://github.com/motiful/skill-forge

# Claude Code
ln -sfn ~/skill-forge/skill ~/.claude/skills/skill-forge

# Other platforms (Cursor, Codex, Windsurf, Gemini CLI, Copilot)
ln -sfn ~/skill-forge/skill ~/.agents/skills/skill-forge
```

## What's Inside

```
skill/
├── SKILL.md              — Full creation + publishing pipeline
└── references/
    ├── skill-format.md          — SKILL.md format specification
    ├── platform-registry.md     — Platform paths, detection logic, community tools
    ├── onboarding-pattern.md    — First-use onboarding pattern
    ├── state-management.md      — Persistent state conventions
    ├── constraint-companion.md  — Constraint separation into rule-skills
    └── templates.md             — README, LICENSE, .gitignore templates
```

## License

MIT
