<div align="center">

  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/logo-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset=".github/logo-light.svg">
    <img alt="Skill Forge" src=".github/logo-light.svg" width="480">
  </picture>

  <p>From local experiment to installable, trustworthy skill — in one command.</p>
</div>

> **Skills are code. Engineer them like it.**

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

The Agent Skills ecosystem has grown to 88K+ published skills ([SkillsMP](https://skillsmp.com), [skills.sh](https://skills.sh)). Community audits estimate ~26% have security vulnerabilities. Most have descriptions that don't cover their actual trigger scenarios. There is no standard for what a "well-engineered skill" looks like.

**If you haven't published yet** — your skill is trapped in one project, can't be shared, and doesn't meet any platform's install standard. No README, no LICENSE, no proper structure, no discoverability.

**If you already published** — your repo might have issues you haven't noticed: leaked API keys in config files, missing .gitignore entries, structure that doesn't match the [Agent Skills](https://agentskills.io) standard, or claims in the README that don't match what the skill actually does.

The gap is not in authoring — AI agents can already help write skill content. The gap is in engineering: validating structure, scanning for security issues, checking description coverage, catching README claims that don't match actual capabilities, and publishing correctly.

## What Skill Forge Does

- **Audits entire projects** — point forge at any directory and it finds every skill, rule, and agent instruction, then fixes them one by one — turning loose tools into standalone, publishable repos
- **Detects registration conflicts** — catches symlinks that shadow each other across platforms, broken links, and copies that should be symlinks — before they cause silent failures
- **Publishes to five platforms at once** — pushes to GitHub, then detects Claude Code, Codex, Cursor, Windsurf, and GitHub Copilot skill directories and symlinks to one source of truth
- **Scans for security issues** — finds leaked API keys, private keys, credential files, and missing .gitignore entries before they reach GitHub. Critical issues block push
- **Makes workflow skills actually get followed** — detects multi-step skills that agents tend to skim, and adds step-by-step structure so agents execute your procedure instead of absorbing it as background knowledge
- **Validates structure and discoverability** — checks that your skill's description, trigger phrases, and metadata are complete enough for agents to find and correctly activate it
- **Keeps your README honest** — flags claims that exceed what your skill actually does, catches hardcoded paths, and verifies install commands
- **Converts rules into publishable skills** — finds team rules buried in config files and packages them as portable, installable skills
- **Guides first-use setup** — when a skill needs user decisions before it can operate (org name, default license), runs an interactive onboarding flow instead of silently using defaults

**Token cost**: Review ~10-25K | Create ~15-30K | Push ~1-2K. Excludes dependent skill invocations (readme-craft, self-review). No Python, no surprise costs.

## Quick Start

```bash
npx skills add motiful/skill-forge -g
```

Then tell your AI coding assistant:

```text
"Review this skill"          — validate, scan, fix → local ready
"Create a skill for X"       — build from scratch → local ready
"Audit this project"         — discover all skills + rules in a directory, classify, fix each
"Publish this skill"         — any of the above + push to GitHub
```

## Usage

Say any of:
- "Review this skill repo" — discover, validate, fix → local ready
- "Audit my skill" — same as review
- "Create a skill for X" — build from scratch → local ready
- "Forge a skill from my notes" — same as create
- "Publish this skill" — forge + publish to GitHub
- "Push this skill to GitHub" — same as publish

## When to Load

| You're doing... | Need skill-forge? |
|-----------------|-------------------|
| Writing a skill's content | No — focus on the domain, not formatting |
| Ready to validate or publish | **Yes** — "publish this skill" or "forge a skill" |
| Reviewing an existing repo | **Yes** — "review this skill repo" |
| Cleaning up a project with mixed skills, rules, and agent instructions | **Yes** — "audit this project" or point forge at the directory |

skill-forge is a post-authoring tool. Load it when you're done writing, not while writing.

**Example: Forge + Publish self-review**

This is a sample flow, not a transcript from one specific machine.

```text
$ "Publish self-review to GitHub"

Step 0: Config
  ✓ ~/.config/skill-forge/config.md found
  ✓ skill_workspace: ~/skills/, github_org: motiful

Step 3: Validate (review path — skill already exists)
  ✓ name: self-review (kebab-case, 11 chars)
  ✓ description: single-line, 133 chars
  ✓ body: 226 lines (< 500)
  ✓ references/dimensions.md exists and is linked
  ✓ README audited by readme-craft — passed
  ✓ no junk files, no leaked secrets

Fix → Local Ready
  ✓ git init + initial commit
  ✓ linked ~/.claude/skills/self-review → ~/skills/self-review/
  ✓ all local ready criteria met

Push
  ✓ confirmed: motiful/self-review, public
  ✓ gh repo create motiful/self-review --public --source=. --push
  ✓ Published — install with: npx skills add motiful/self-review
```

## Install

```bash
npx skills add motiful/skill-forge -g
```

Works with Claude Code, Codex, Cursor, Windsurf, GitHub Copilot, and other [Agent Skills](https://agentskills.io) adopters.

**Manual registration** (clone + symlink):

```bash
git clone https://github.com/motiful/skill-forge ~/skills/skill-forge

# Register only in roots you actually use.
ln -sfn ~/skills/skill-forge ~/.claude/skills/skill-forge      # Claude Code
ln -sfn ~/skills/skill-forge ~/.agents/skills/skill-forge      # Codex
ln -sfn ~/skills/skill-forge ~/.copilot/skills/skill-forge     # VS Code / GitHub Copilot
ln -sfn ~/skills/skill-forge ~/.cursor/skills/skill-forge      # Cursor
ln -sfn ~/skills/skill-forge ~/.codeium/windsurf/skills/skill-forge  # Windsurf
```

### Prerequisites

- **Git** (required)
- **Node.js** (required for `npx skills add`)
- **[GitHub CLI](https://cli.github.com/)** (`gh`) — required for publishing. Forge works without it for local validation

### Dependencies

Installed automatically by `scripts/setup.sh` on first run:

| Dependency | Purpose |
|------------|---------|
| [`motiful/readme-craft`](https://github.com/motiful/readme-craft) | 3-tier layout, badge selection, dark/light logo for README generation |
| [`motiful/rules-as-skills`](https://github.com/motiful/rules-as-skills) | Rule-skill methodology: three-layer model, format, in-repo patterns |
| [`motiful/self-review`](https://github.com/motiful/self-review) | 4-pillar, 6-dimension alignment audit for skill quality validation |

Skill Forge validates and publishes — it does not write skill content or test domain effectiveness. Those judgments depend on the author, the domain, and real usage.

## Skill Philosophy

Skills are the next unit of reusable intelligence — loadable capability extensions that give AI agents structured expertise a base model doesn't have. skill-forge defines six quality dimensions (discoverable, reliable, efficient, trustworthy, bounded, valuable) and validates against them using prompts instead of scripts — keeping skills platform-agnostic and installable without runtimes.

→ [Vision, quality dimensions, and technical route](docs/skill-philosophy.md)

## Contributing

Bug reports, validation rule ideas, and reference doc improvements are welcome. Open an issue or pull request on [GitHub](https://github.com/motiful/skill-forge).

## License

[MIT](LICENSE)

---

Forged with [Skill Forge](https://github.com/motiful/skill-forge) · Crafted with [Readme Craft](https://github.com/motiful/readme-craft)

<!-- Badge reference-style links -->
[license-shield]: https://img.shields.io/github/license/motiful/skill-forge.svg
[license-url]: https://github.com/motiful/skill-forge/blob/main/LICENSE
[version-shield]: https://img.shields.io/badge/version-9.0-blue.svg
[version-url]: SKILL.md
[skills-shield]: https://img.shields.io/badge/Agent%20Skills-compatible-DA7857?logo=anthropic
[skills-url]: https://agentskills.io
