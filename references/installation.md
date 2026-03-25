---
name: installation
description: Standard mechanism for declaring and installing skill dependencies via scripts/setup.sh. Covers the two-outcome principle (installed or blocked), dependency types (CLI tools, skills, npm packages), skill detection across platform directories, install scope (global vs project), two-tier declaration model, and setup.sh guidelines (idempotent, fast, non-interactive).
---

# Installation

Standard mechanism for declaring and installing skill dependencies.

## Execution Procedure

```
install(dependencies) → installed | blocked

run scripts/setup.sh
for each dependency:
    if present → skip
    if missing and installable → install
    if cannot install → error with resolution, exit non-zero
all present → exit 0
```

## TOC

- [Core Principle](#core-principle)
- [scripts/setup.sh](#scriptssetupsh)
- [Dependency Types](#dependency-types)
- [Skill Installation Detection](#skill-installation-detection)
- [Install Scope: Global vs Project](#install-scope-global-vs-project)
- [Declaration: Two Tiers](#declaration-two-tiers)
- [Example: skill-forge's own setup.sh](#example-skill-forges-own-setupsh)
- [Guidelines](#guidelines)

## Core Principle

**Dependencies must be installed. Not "works better with". Not graceful skip.**

Two outcomes only:

| Result | When |
|--------|------|
| **Installed** | Dependency is present (already existed or just installed) → continue |
| **Blocked** | Cannot install (network, permissions, platform) → specific error + resolution steps → stop |

No middle ground. No fallback behavior.

## scripts/setup.sh

Every skill with dependencies **must** include `scripts/setup.sh`. This is the standard entry point for dependency installation.

### Responsibilities

```
scripts/setup.sh
  1. Check all declared dependencies (tools, skills, npm packages)
  2. Missing → install
  3. Can't install → print error with resolution steps, exit non-zero
  4. All present → exit 0
```

### Relationship with SKILL.md Step 0

The prompt calls setup.sh. The prompt does NOT judge dependency state itself.

```
Step 0: Environment Setup
  1. Run scripts/setup.sh
  2. setup.sh exits 0 → proceed to Step 1
  3. setup.sh exits non-zero → report the error to user, stop
```

**AI is the executor. setup.sh is the detector.**

### Naming and Location

| Convention | Value |
|------------|-------|
| Path | `scripts/setup.sh` (relative to skill root) |
| Permissions | Must be executable (`chmod +x`) |
| Interpreter | `#!/usr/bin/env bash` |
| Exit code | 0 = all deps ready, non-zero = blocked |
| Output | Human-readable status for each dependency |

## Dependency Types

setup.sh handles three categories of dependencies:

| Type | Detection | Installation |
|------|-----------|-------------|
| **CLI tools** | `command -v <tool>` | `brew install`, `apt-get install`, or manual instructions |
| **Skills** | Check known skill directories (see below) | `npx skills add <org>/<name> -g -y` |
| **npm packages** | `node_modules/` or `npm ls` | `npm install` |

## Skill Installation Detection

Skills can exist in multiple directories depending on the installation method:

| Source | Location(s) |
|--------|------------|
| `npx skills add -g` | `~/.agents/skills/<name>/` + `~/.claude/skills/<name>/` (hardlinked) |
| Manual symlink | `~/.claude/skills/<name>/`, `~/.copilot/skills/<name>/`, `~/.cursor/skills/<name>/`, `~/.codeium/windsurf/skills/<name>/` |
| Project-level | `<project>/.claude/skills/<name>/`, `<project>/.agents/skills/<name>/`, etc. |

`npx skills add -g` automatically hardlinks to both `~/.agents/skills/` and `~/.claude/skills/`, so no manual symlink is needed. The detection function also checks Copilot, Cursor, and Windsurf native paths for manual installations.

Detection function:

```bash
skill_installed() {
  local name=$1
  [ -d "$HOME/.claude/skills/$name" ] && return 0
  [ -d "$HOME/.agents/skills/$name" ] && return 0
  [ -d "$HOME/.copilot/skills/$name" ] && return 0
  [ -d "$HOME/.cursor/skills/$name" ] && return 0
  [ -d "$HOME/.codeium/windsurf/skills/$name" ] && return 0
  return 1
}
```

## Install Scope: Global vs Project

| Skill type | Default scope | Rationale |
|------------|--------------|-----------|
| **Tooling skills** (skill-forge, readme-craft, self-review) | Global (`-g`) | Tools serve the user, not a project. Like installing an IDE globally |
| **Project skills** (deployment, linting rules for this repo) | Project | Part of the project's codebase, committed to git |

**If a tooling skill is installed project-level** (user explicitly chose this), it should be added to `.gitignore`:

```gitignore
# Tooling skills — installed via setup.sh, not project code
.claude/skills/skill-forge/
.claude/skills/readme-craft/
.claude/skills/self-review/
```

Same principle as `node_modules/`: declare dependencies (SKILL.md Step 0), install via setup.sh, don't commit the installation.

**setup.sh always installs with `-g`** — this is the default and correct behavior for dependency skills.

## Declaration: Two Tiers

| Tier | Declared in | Behavior |
|------|-------------|----------|
| **Dependencies** | SKILL.md Step 0 + scripts/setup.sh | Must install. Missing → install. Can't install → block |
| **Informational** | README.md only | Human reading. AI does not act on it |

"Works Better With" does not exist in SKILL.md runtime logic.

## Example: skill-forge's own setup.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "skill-forge: checking dependencies..."
echo ""

errors=0

# --- CLI tools ---
for tool in gh node npx; do
  if command -v "$tool" &>/dev/null; then
    echo "  $tool: $(command -v "$tool")"
  else
    echo "  ERROR: $tool not found"
    case "$tool" in
      gh)   echo "  Install: https://cli.github.com" ;;
      node) echo "  Install: https://nodejs.org" ;;
      npx)  echo "  Install: comes with Node.js — https://nodejs.org" ;;
    esac
    errors=$((errors + 1))
  fi
done

echo ""

# --- Skill dependencies ---
skill_installed() {
  local name=$1
  [ -d "$HOME/.claude/skills/$name" ] && return 0
  [ -d "$HOME/.agents/skills/$name" ] && return 0
  [ -d "$HOME/.copilot/skills/$name" ] && return 0
  [ -d "$HOME/.cursor/skills/$name" ] && return 0
  [ -d "$HOME/.codeium/windsurf/skills/$name" ] && return 0
  return 1
}

install_skill() {
  local name=$1 repo=$2

  if skill_installed "$name"; then
    echo "  $name: installed"
    return 0
  fi

  echo "  $name: installing..."
  if npx skills add "$repo" -g -y 2>/dev/null; then
    # npx skills add -g hardlinks to both ~/.agents/skills/ and ~/.claude/skills/
    echo "  $name: installed"
    return 0
  fi

  echo "  ERROR: failed to install $name"
  echo "  Manual fix: npx skills add $repo -g"
  return 1
}

install_skill "readme-craft" "motiful/readme-craft" || errors=$((errors + 1))
install_skill "rules-as-skills" "motiful/rules-as-skills" || errors=$((errors + 1))
install_skill "self-review" "motiful/self-review" || errors=$((errors + 1))

echo ""

# --- Result ---
if [ $errors -gt 0 ]; then
  echo "BLOCKED: $errors dependency issue(s). Fix above errors and re-run."
  exit 1
fi

echo "All dependencies ready."
exit 0
```

## Guidelines

- **Idempotent**: setup.sh runs every invocation, not just first use. Already-installed deps are detected and skipped instantly
- **Fast**: existence checks, not full test suites. A passing run should complete in under 2 seconds
- **Informative**: print status for each dependency so the user sees what's happening
- **Non-interactive**: no prompts. Use `-y` flags where available. setup.sh is automated, not an onboarding flow
- **Fail loud**: exit non-zero with specific error messages. Never silently continue with missing deps
