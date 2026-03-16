# Templates

## TOC

- [README.md Template](#readmemd-template)
- [LICENSE Template (MIT)](#license-template-mit)
- [.gitignore Template](#gitignore-template)

## README.md Template

> This skeleton defines the **minimum content requirements** for a skill README. For full layout, 3-tier hierarchy, badge selection, dark/light logo, collapsible sections, and formatting decisions, use readme-craft (`npx skills add motiful/readme-craft`). Without readme-craft, use this skeleton as-is.

Use this file for the literal file skeletons. For writing rules and claim discipline, see `references/readme-quality.md`. For example provenance rules, tone/voice, and layout strategy, see readme-craft.

The README follows a **value-first** structure: tell the reader what problem you solve before telling them how to install.

If you mention directories, marketplaces, or leaderboards around the template, frame them as downstream discovery paths, not guaranteed immediate outcomes of publishing.
Default the template prose to English for reusable skills. Only localize when the skill itself is language-specific or culture-specific.
If the skill has dependencies (other skills, CLI tools), add a "Dependencies" section listing what gets installed by `scripts/setup.sh`. Informational recommendations (not required) go in README body text only, not in a dedicated section.

```markdown
# <skill-name>

> <one-line value proposition — what problem this solves, not what it is>

[Agent Skills](https://agentskills.io) compatible — works with Claude Code, Codex, Cursor, Windsurf, GitHub Copilot, and other Agent Skills adopters.

## The Problem

<2-4 sentences describing the pain point. Be specific — what goes wrong without this skill?>

## What <skill-name> Does

<How the skill solves the problem. Show the workflow or key capabilities. Use a code block, table, or bullet list — whichever communicates fastest.>

## Usage

<Trigger phrases, example invocations, what the user says to activate the skill. This section answers "how do I use it?" not "how do I install it?">

## Prerequisites

<Optional. Include only when the skill requires external tools or runtimes that aren't universally present. List each dependency with a brief note on why it's needed.>

## Install

```bash
npx skills add <org>/<skill-name> -g
```

Common manual registration examples:

```bash
git clone https://github.com/<org>/<skill-name> ~/skills/<skill-name>

# Pick only the roots you actually use.
# You do not need to register every platform.
# If a root does not exist yet, create it only intentionally.

# Claude Code
ln -sfn ~/skills/<skill-name> ~/.claude/skills/<skill-name>

# Codex
ln -sfn ~/skills/<skill-name> ~/.agents/skills/<skill-name>

# VS Code / GitHub Copilot
ln -sfn ~/skills/<skill-name> ~/.copilot/skills/<skill-name>

# Cursor (if your setup ignores the symlink, use a real copy in ~/.cursor/skills/<skill-name>)
ln -sfn ~/skills/<skill-name> ~/.cursor/skills/<skill-name>

# Windsurf
ln -sfn ~/skills/<skill-name> ~/.codeium/windsurf/skills/<skill-name>
```

## Dependencies

<Include when the skill has dependencies installed by scripts/setup.sh. Omit if the skill has no dependencies.>

| Dependency | Purpose | Installed by |
|------------|---------|-------------|
| `<tool-or-skill>` | <what it does for this skill> | `scripts/setup.sh` |

## What's Inside

```
SKILL.md              — <short description>
references/            — <if applicable>
└── ...
```

## License

<license>

---

Forged with [Skill Forge](https://github.com/<org>/skill-forge) · Crafted with [Readme Craft](https://github.com/<org>/readme-craft)
```

## Collection README.md Template

> For multi-skill repos (Collection publishing model). See `references/publishing-strategy.md`.

```markdown
# <collection-name>

> <one-line value proposition — what problem space this collection covers>

[Agent Skills](https://agentskills.io) compatible — works with Claude Code, Codex, Cursor, Windsurf, GitHub Copilot, and other Agent Skills adopters.

## The Problem

<2-4 sentences describing the pain point that spans multiple skills.>

## Skills

| Skill | Description |
|-------|-------------|
| [`<skill-a>`](skills/<skill-a>/SKILL.md) | <one-line description> |
| [`<skill-b>`](skills/<skill-b>/SKILL.md) | <one-line description> |
| [`<skill-c>`](skills/<skill-c>/SKILL.md) | <one-line description> |

<If 10+ skills, group by category:>

### <Category 1>

| Skill | Description |
|-------|-------------|
| [`<skill-a>`](skills/<skill-a>/SKILL.md) | <one-line description> |

### <Category 2>

| Skill | Description |
|-------|-------------|
| [`<skill-b>`](skills/<skill-b>/SKILL.md) | <one-line description> |

## Install

```bash
# All skills
npx skills add <org>/<collection>

# Specific skills
npx skills add <org>/<collection> --skill <skill-a> <skill-b>

# List available
npx skills add <org>/<collection> --list
```

## Dependencies

<Include when the collection has shared dependencies installed by scripts/setup.sh. Omit if none.>

| Dependency | Purpose | Installed by |
|------------|---------|-------------|
| `<tool-or-skill>` | <what it does> | `scripts/setup.sh` |

## License

<license>

---

Forged with [Skill Forge](https://github.com/<org>/skill-forge)
```

## LICENSE Template (MIT)

```
MIT License

Copyright (c) <year> <author>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## .gitignore Template

```
.DS_Store
Thumbs.db
*.skill
node_modules/
dist/
.env*
.idea/
.vscode/
```
