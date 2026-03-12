<div align="center">

  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="assets/logo-light.svg">
    <img alt="Skill Forge" src="assets/logo-light.svg" width="480">
  </picture>

  <p>From idea to published, installable AI skill — in one pipeline.</p>
</div>

[Agent Skills](https://agentskills.io) compatible — works with Claude Code, Codex, Cursor, Windsurf, GitHub Copilot, and other adopters.

<div align="center">

[![License: MIT][license-shield]][license-url]
[![Version][version-shield]][version-url]
[![Agent Skills][skills-shield]][skills-url]

</div>

<div align="center">
  <a href="#quick-start">Quick Start</a> &middot;
  <a href="#usage">Usage</a> &middot;
  <a href="#install">Install</a> &middot;
  <a href="https://agentskills.io">Agent Skills</a>
</div>

---

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

0. **Config** — Set up `~/skills/` root, detect your GitHub org and preferences
1. **Gather** — Auto-detect existing skill content from project and conversation
2. **Create** — Write SKILL.md following the [Agent Skills](https://agentskills.io) standard
3. **Validate** — Structure, frontmatter, content quality, optional community readiness checks
4. **Publish** — Push to GitHub and optionally connect to tools already active on your machine

The result: a standalone repo that anyone can install with one command.

## Quick Start

```bash
npx skills add motiful/skill-forge
```

Then tell your AI coding assistant:

```
"Publish this skill to GitHub"
```

You get a standalone repo with SKILL.md, README, and LICENSE — pushed to GitHub and installable via `npx skills add <org>/<name>`.

## Usage

Say any of:
- "Create a skill for X and publish it"
- "Publish this skill to GitHub"
- "Forge a skill from my notes"
- "Turn this project-local skill into a repo"

<details>
<summary>Example: Publishing self-review</summary>

This is a sample flow, not a transcript from one specific machine.

```
$ "Publish self-review to GitHub"

Step 0: Config
  ✓ ~/.config/skill-forge/config.md found
  ✓ skill_root: ~/skills/, github_org: motiful

Step 1: Gather
  ✓ Existing skill detected at ~/skills/self-review/SKILL.md
  ✓ Capabilities: none needed (pure methodology, no state or onboarding)
  ✓ Recommended skills: none

Step 2: Create
  ✓ SKILL.md already exists — using as-is

Step 3: Validate
  ✓ name: self-review (kebab-case, 11 chars)
  ✓ description: single-line, 133 chars
  ✓ body: 226 lines (< 500)
  ✓ references/dimensions.md exists and is linked
  ✓ no junk files in skill content

Step 4: Publish
  ✓ showed what would be created, where it would be published, and which active tools would be connected
  ✓ user confirmed
  ✓ git init + initial commit
  ✓ detected the active tool locations on this machine
  ✓ connected self-review to the approved tools
  ✓ gh repo create motiful/self-review --public --source=. --push
  ✓ Published — install with: npx skills add motiful/self-review
```

</details>

## Install

```bash
npx skills add motiful/skill-forge
```

Works with Claude Code, Codex, Cursor, Windsurf, GitHub Copilot, and other [Agent Skills](https://agentskills.io) adopters.

<details>
<summary>Manual registration (clone + symlink)</summary>

```bash
git clone https://github.com/motiful/skill-forge ~/skills/skill-forge

# Register only in roots you actually use.

# Claude Code
ln -sfn ~/skills/skill-forge ~/.claude/skills/skill-forge

# Codex
ln -sfn ~/skills/skill-forge ~/.agents/skills/skill-forge

# VS Code / GitHub Copilot
ln -sfn ~/skills/skill-forge ~/.copilot/skills/skill-forge

# Cursor
ln -sfn ~/skills/skill-forge ~/.cursor/skills/skill-forge

# Windsurf
ln -sfn ~/skills/skill-forge ~/.codeium/windsurf/skills/skill-forge
```

</details>

<details>
<summary>Prerequisites</summary>

- **Git** (required)
- **Node.js** (required for `npx skills add`)
- **[GitHub CLI](https://cli.github.com/)** (`gh`) — recommended for one-command publishing. Without it, you set up the remote manually

</details>

<details>
<summary>Works Better With</summary>

- [`motiful/rules-as-skills`](https://github.com/motiful/rules-as-skills) — helps when the skill you're forging needs portable MUST/NEVER constraints. Install: `npx skills add motiful/rules-as-skills`
- [`motiful/readme-craft`](https://github.com/motiful/readme-craft) — strengthens README writing and review during publish. Install: `npx skills add motiful/readme-craft`

Skill Forge still works fully on its own.

</details>

<details>
<summary>Positioning</summary>

Skill Forge optimizes for **public artifact quality**, not domain-level outcome certification.

It helps you create skills that are installable, publishable, maintainable, composable, independently iterable, and honestly described.

It does **not** claim to prove that a generated skill's domain outputs are objectively excellent, production-safe, or aesthetically strong. Those judgments still depend on the author, the domain, and real usage.

**Skill Composition:** Most users can ignore this. The default model is simple — publish one thing as a single skill. If another skill genuinely strengthens one step, mention it in that step and mirror it in a short "Works Better With" section. Only move to `Kit` when several skills need to be delivered as one workflow.

</details>

<details>
<summary>What's Inside</summary>

```
SKILL.md              — Full creation + publishing pipeline
references/
├── skill-format.md          — How to write a valid SKILL.md
├── publishing-strategy.md   — Skill, Kit, or Collection decisions
├── skill-composition.md     — Lightweight composition rules
├── platform-registry.md     — Where each platform looks for skills
├── readme-quality.md        — README writing and claim discipline
├── onboarding-pattern.md    — Adding first-use setup to a skill
├── state-management.md      — Persistent config and state across sessions
├── rule-skill-pattern.md    — Separating enforceable rules into a paired rule-skill
└── templates.md             — README, LICENSE, .gitignore skeletons
```

</details>

## Contributing

Bug reports, validation rule ideas, and reference doc improvements are welcome. Open an issue or pull request on [GitHub](https://github.com/motiful/skill-forge).

## License

[MIT](LICENSE)

---

Forged with [Skill Forge](https://github.com/motiful/skill-forge) · Crafted with [Readme Craft](https://github.com/motiful/readme-craft)

<!-- Badge reference-style links -->
[license-shield]: https://img.shields.io/github/license/motiful/skill-forge.svg
[license-url]: https://github.com/motiful/skill-forge/blob/main/LICENSE
[version-shield]: https://img.shields.io/badge/version-2.0-blue.svg
[version-url]: SKILL.md
[skills-shield]: https://img.shields.io/badge/Agent%20Skills-compatible-DA7857?logo=anthropic
[skills-url]: https://agentskills.io
