# Skill Forge

> From idea to published, installable AI skill — in one pipeline.

Say "publish this skill" to your AI coding assistant and Skill Forge handles the rest — from writing SKILL.md to pushing a ready-to-install repo to GitHub.

[Agent Skills](https://agentskills.io) compatible — works with Claude Code, Codex, Cursor, Windsurf, GitHub Copilot, and other Agent Skills adopters.

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
1. **Gather** — Auto-detect existing skill content from project and conversation. Detect what the skill needs (first-use setup? persistent state? enforceable constraints?)
2. **Create** — Write SKILL.md following the [Agent Skills](https://agentskills.io) standard, bake detected capabilities in
3. **Validate** — Structure, frontmatter, content quality, optional community readiness checks
4. **Publish** — show one short confirmation of what will be created and connected, then push to GitHub and optionally connect it to the tools already active on this machine. The result is directly installable by repo path; broader directory visibility depends on downstream indexing or install telemetry

The result: a standalone repo that anyone can install with one command.

### Advanced: Publishing Multiple Skills

Most users can ignore this. If you later need to publish several related skills, Skill Forge also covers the packaging options. See the publishing strategy reference for details.

## Usage

Say any of:
- "Create a skill for X and publish it"
- "Publish this skill to GitHub"
- "Forge a skill from my notes"
- "Turn this project-local skill into a repo"

### Example: Publishing self-review

This is a sample flow, not a transcript from one specific machine. Exact registration depends on which skill roots already exist and which targets you explicitly choose.

```
$ "Publish self-review to GitHub"

Step 0: Config
  ✓ ~/.config/skill-forge/config.md found
  ✓ skill_root: ~/skills/, github_org: motiful

Step 1: Gather
  ✓ Existing skill detected at ~/skills/self-review/SKILL.md
  ✓ Capabilities: none needed (pure methodology, no state or onboarding)

Step 2: Create
  ✓ SKILL.md already exists — using as-is

Step 3: Validate
  ✓ name: self-review (kebab-case, 11 chars)
  ✓ description: single-line, 133 chars
  ✓ body: 226 lines (< 500)
  ✓ references/dimensions.md exists and is linked
  ✓ no junk files in skill content

Step 4: Review and confirm
  ✓ showed what would be created, where it would be published, and which active tools would be connected
  ✓ user confirmed the side effects

Step 5: Publish
  ✓ git init + initial commit
  ✓ detected the active tool locations on this machine
  ✓ connected self-review to the approved tools
  ✓ gh repo create motiful/self-review --public --source=. --push
  ✓ Published — install with: npx skills add motiful/self-review
```

## Prerequisites

- **Git** (required)
- **Node.js** (required for `npx skills add`)
- **[GitHub CLI](https://cli.github.com/)** (`gh`) — recommended for one-command publishing. Without it, you'll set up the remote manually

## Install

```bash
npx skills add motiful/skill-forge
```

Publishing note: pushing a skill repo to GitHub makes it directly installable by repo path. Directory listings and leaderboards are downstream and may lag or depend on install activity.

Common manual registration examples:

```bash
git clone https://github.com/motiful/skill-forge ~/skills/skill-forge

# Register only in roots you actually use.
# If a root does not exist yet, create it only intentionally.

# Claude Code
ln -sfn ~/skills/skill-forge ~/.claude/skills/skill-forge

# Codex
ln -sfn ~/skills/skill-forge ~/.agents/skills/skill-forge

# VS Code / GitHub Copilot
ln -sfn ~/skills/skill-forge ~/.copilot/skills/skill-forge

# Cursor (if your setup ignores the symlink, use a real copy in ~/.cursor/skills/skill-forge)
ln -sfn ~/skills/skill-forge ~/.cursor/skills/skill-forge

# Windsurf
ln -sfn ~/skills/skill-forge ~/.codeium/windsurf/skills/skill-forge
```

## What's Inside

```
SKILL.md              — Full creation + publishing pipeline
references/
├── skill-format.md          — How to write a valid SKILL.md
├── publishing-strategy.md   — One skill, multiple skills, or a themed Kit
├── skill-composition.md     — Why skills need composition (like npm needs dependencies)
├── platform-registry.md     — Where each platform looks for skills
├── readme-quality.md        — README writing, claims, and example rules
├── onboarding-pattern.md    — Adding first-use setup to a skill
├── state-management.md      — Persistent config and state across sessions
├── constraint-companion.md  — Separating enforceable rules into a companion skill
└── templates.md             — README, LICENSE, .gitignore skeletons
```

## License

[MIT](LICENSE)

---

Forged with [Skill Forge](https://github.com/motiful/skill-forge)
