<div align="center">

  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/logo-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset=".github/logo-light.svg">
    <img alt="Skill Forge" src=".github/logo-light.svg" width="480">
  </picture>

  <p>From local experiment to installable, trustworthy skill — in one command.</p>
</div>

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

88K+ skills exist in the Agent Skills ecosystem. Research shows 26% have security vulnerabilities. Most have descriptions that don't cover their actual trigger scenarios. There is no standard for what a "well-engineered skill" looks like.

**If you haven't published yet** — your skill is trapped in one project, can't be shared, and doesn't meet any platform's install standard. No README, no LICENSE, no proper structure, no discoverability.

**If you already published** — your repo might have issues you haven't noticed: leaked API keys in config files, missing .gitignore entries, structure that doesn't match the [Agent Skills](https://agentskills.io) standard, or claims in the README that don't match what the skill actually does.

The gap is not in authoring — AI agents can already help write skill content. The gap is in engineering: validating structure, scanning for security issues, checking description coverage, enforcing claim discipline, and publishing correctly.

## What Skill Forge Does

Skill Forge is a **skill engineering methodology and publishing pipeline**. The methodology defines what "well-engineered skill" means. The pipeline automates validation and publishing. Both are valuable independently.

- **Validates structure and discoverability** — checks frontmatter, description coverage, body length, reference integrity, and terminology so agents can find and correctly trigger your skill
- **Scans for security issues** — detects leaked API keys (`sk-`, `ghp_`, `AKIA`), private keys, credential files, and missing .gitignore entries before they reach GitHub. Critical issues block push
- **Checks README claim discipline** — compares README claims against SKILL.md capabilities, flags hardcoded paths, verifies install commands and LICENSE
- **Two modes, one action** — Review (existing skill → validate → fix → local ready) or Create (new skill → build → validate → local ready). Push is a single action you trigger when ready
- **Pushes to GitHub with explicit confirmation** — confirm remote target, then `gh repo create` → push. Everything else is already done at local ready
- **Auto-registers across platforms** — detects Claude Code, Codex, Cursor, Windsurf, and GitHub Copilot skill roots and symlinks them to one source of truth
- **Generates community-ready artifacts** — README (with readme-craft integration), LICENSE, .gitignore following the Agent Skills standard
- **Respects your conventions** — scans forge config → project instructions → platform rules in priority order

<details>
<summary>Pipeline stages</summary>

0. **Config** — Set up `~/skills/` root, detect your GitHub org and preferences
1. **Gather** — Auto-detect existing skill content from project and conversation
2. **Create** — Write SKILL.md + README + LICENSE + .gitignore following the [Agent Skills](https://agentskills.io) standard
3. **Validate & Fix** — Structure, frontmatter, content quality, repo hygiene, readme-craft audit, local registration → local ready

Push to GitHub is a single action after local ready — confirm target, then `gh repo create` + push.

</details>

### What Users Get

| Capability | What it means for you | How forge delivers it |
|------------|----------------------|----------------------|
| **Security assurance** | Your skill won't leak API keys or credentials to GitHub | Repo hygiene scan: regex pattern matching for common secret formats |
| **Description quality** | Agents will actually find and trigger your skill | Coverage check: does the description mention key scenarios from the body? |
| **Cross-platform compatibility** | Works on Claude Code, Codex, Cursor, Windsurf, Copilot — not just one | Standard frontmatter validation + platform-agnostic structure |
| **Efficient context usage** | Your skill doesn't waste the agent's context window | Body under 500 lines, instruction density check, progressive disclosure via references/ |
| **Claim discipline** | README says what the skill actually does, no inflated promises | README ↔ SKILL.md consistency check |
| **Configuration pattern** | Your skill can have user preferences, done properly | Reference pattern for declaring and reading config |
| **Dependency installation** | Required tools and skills are installed automatically | `scripts/setup.sh` standard — install or block, no graceful skip |
| **One-command publishing** | Local files → installable GitHub repo | Push: `gh repo create` + push (everything else done at local ready) |
| **Ongoing maintenance** | Catch regressions when you update | Review mode: re-run validation on existing repos |

**Token cost**: Review ~5-15K | Create ~10-20K | Push ~1-2K. No subagents, no Python, no surprise costs.

## When to Load

| You're doing... | Need skill-forge? |
|-----------------|-------------------|
| Writing a skill's content | No — focus on the domain, not formatting |
| Ready to validate or publish | **Yes** — "publish this skill" or "forge a skill" |
| Reviewing an existing repo | **Yes** — "review this skill repo" |

skill-forge is a post-authoring tool. Load it when you're done writing, not while writing.

## Quick Start

```bash
npx skills add motiful/skill-forge -g
```

Then tell your AI coding assistant:

```
"Publish this skill to GitHub"
```

You get a standalone repo with SKILL.md, README, and LICENSE — pushed to GitHub and installable via `npx skills add <org>/<name>`.

## Usage

Say any of:
- "Review this skill repo" — Review mode
- "Audit my skill" — Review mode
- "Create a skill for X" — Create mode
- "Forge a skill from my notes" — Create mode
- "Push this skill to GitHub" — Push action (after local ready)
- "Publish this skill" — Review + Push

<details>
<summary>Example: Review + Push self-review</summary>

This is a sample flow, not a transcript from one specific machine.

```
$ "Publish self-review to GitHub"

Step 0: Config
  ✓ ~/.config/skill-forge/config.md found
  ✓ skill_root: ~/skills/, github_org: motiful

Step 3: Validate (Review mode — skill already exists)
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

</details>

## Install

```bash
npx skills add motiful/skill-forge -g
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

### Prerequisites

- **Git** (required)
- **Node.js** (required for `npx skills add`)
- **[GitHub CLI](https://cli.github.com/)** (`gh`) — required for publishing. Review mode works without it

### Dependencies

Installed automatically by `scripts/setup.sh` on first run:

| Dependency | Purpose |
|------------|---------|
| [`motiful/readme-craft`](https://github.com/motiful/readme-craft) | 3-tier layout, badge selection, dark/light logo for README generation |
| [`motiful/rules-as-skills`](https://github.com/motiful/rules-as-skills) | Portable MUST/NEVER constraint skills for Rule-Skill Split |
| [`motiful/self-review`](https://github.com/motiful/self-review) | 4-pillar, 6-dimension alignment audit for skill quality validation |

<details>
<summary>Positioning</summary>

Skill Forge is a **skill engineering methodology and publishing pipeline**. The methodology defines what "well-engineered skill" means — referenced while writing or improving skills. The pipeline automates validation and publishing — run when ready to share.

It helps you create skills that are installable, publishable, maintainable, and honestly described.

It does **not** claim to prove that a generated skill's domain outputs are objectively excellent, production-safe, or aesthetically strong. Those judgments still depend on the author, the domain, and real usage.

</details>

<details>
<summary>What's Inside</summary>

```
SKILL.md              — Full creation + publishing pipeline
scripts/
└── setup.sh                 — Dependency installation (readme-craft, rules-as-skills, self-review)
references/
├── installation.md          — setup.sh standard: dependency detection and installation
├── onboarding.md            — Interactive first-use guidance pattern
├── skill-configuration.md   — User preferences, config location, stateless principle
├── skill-format.md          — How to write a valid SKILL.md
├── skill-composition.md     — Composition philosophy and context budget
├── rule-skill-pattern.md    — Detection-driven: MUST/NEVER constraints as paired skill
├── publishing-strategy.md   — Skill or Collection decisions
├── platform-registry.md     — Where each platform looks for skills
├── readme-quality.md        — README writing and claim discipline
├── script-quality.md        — Script file structure guidelines
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
[version-shield]: https://img.shields.io/badge/version-6.0-blue.svg
[version-url]: SKILL.md
[skills-shield]: https://img.shields.io/badge/Agent%20Skills-compatible-DA7857?logo=anthropic
[skills-url]: https://agentskills.io
