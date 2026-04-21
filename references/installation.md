---
name: installation
description: Standard mechanism for declaring and installing skill dependencies via scripts/setup.sh. Covers the two-outcome principle (installed or blocked), dependency types (CLI tools, skills, npm packages), the shared install-skill-lib.sh helper, mechanical cascade semantics that mirror npm's postinstall behavior, protocol activation hints, install scope (global vs project), two-tier declaration model, and setup.sh authoring guidelines (idempotent, fast, non-interactive).
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
        after install → cascade: run its setup.sh (pulls deeper deps)
    if cannot install → error with resolution, exit non-zero
all present → exit 0
```

## TOC

- [Core Principle](#core-principle)
- [scripts/setup.sh](#scriptssetupsh)
- [Dependency Types](#dependency-types)
- [Shared Library: install-skill-lib.sh](#shared-library-install-skill-libsh)
- [Cascade Behavior](#cascade-behavior)
- [Protocol Activation Hints](#protocol-activation-hints)
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
  1. Check all declared CLI tools
  2. Source install-skill-lib.sh (see next section)
  3. For each skill dependency: call install_skill "name" "repo"
  4. (Optional) Print activation hint if this skill itself is a Protocol skill
  5. Can't install any dep → print error with resolution, exit non-zero
  6. All present → exit 0
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
| **Skills** | `skill_installed` helper (from lib) | `install_skill "name" "repo"` (from lib) |
| **npm packages** | `node_modules/` or `npm ls` | `npm install` |

## Shared Library: install-skill-lib.sh

Skill installation logic is **centralized in a shared bash library** — each skill ships its own copy of `scripts/install-skill-lib.sh` and sources it from `scripts/setup.sh`. This keeps setup.sh lean (20-30 lines) and avoids every skill re-defining the installer from scratch.

**Canonical source**: `/Users/yuhaolu/motifpool/skill-forge/references/install-skill-lib.sh` — maintained as the single source of truth.

**Distribution**: each skill copies the lib into its own `scripts/` directory. The lib travels with the skill (self-contained distribution; no chicken-and-egg with skill-forge).

```bash
# From your scripts/setup.sh:
source "$(dirname "$0")/install-skill-lib.sh"
```

The lib exposes three functions:

| Function | Purpose |
|----------|---------|
| `skill_installed "<name>" [scope]` | Returns 0 if skill exists in the requested scope |
| `skill_install_path "<name>" [scope]` | Prints the installed skill's directory path (or returns 1) |
| `install_skill "<name>" "<org/repo>" [scope-flag] [alt-name...]` | Installs via `npx skills add` **and** cascades into its setup.sh |

**Scope flag** (third parameter of `install_skill`, optional):

| Value | Meaning | Location | Matches |
|-------|---------|----------|---------|
| `<omitted>` (default) | project-level | `$PWD/.claude/skills/` + `$PWD/.agents/skills/` | `npx skills add` native default |
| `-g` or `--global` | user-level | `~/.claude/skills/` + `~/.agents/skills/` | `npx skills add -g` |
| anything else | **ERROR — unsupported** | — | custom absolute paths planned for v0.2 |

Default is **project** (matches `npx skills add` native behavior) — safer, doesn't pollute the user's global namespace. Tooling-type skills that belong globally (e.g. skill-forge's own deps) must pass `-g` explicitly.

**Alt names** (fourth parameter onward of `install_skill`, optional):

Additional names under which the skill may be found installed. Used when the repository name differs from the installed directory name — typically collection repos, or when the caller prefers a short alias over the real SKILL.md `name` field.

**Examples**:

```bash
# Default project-level; matches `npx skills add`
install_skill "project-helper" "org/skill"

# Global scope; matches `npx skills add -g`
install_skill "readme-craft" "motiful/readme-craft" "-g"
install_skill "readme-craft" "motiful/readme-craft" "--global"

# Alt names for mismatched naming
install_skill "feel-better" "jakubkrehel/make-interfaces-feel-better" "" "make-interfaces-feel-better"
#              ^primary     ^repo                                    ^scope-flag ^alt-name (4th arg)

# Alt names with explicit global scope
install_skill "taste" "Leonxlnx/taste-skill" "-g" "taste-skill" "stitch-design-taste"
```

`skill_installed` and `skill_install_path` take scope as their 2nd arg with values `"any"` (default — checks both project and global), `"global"`, or `"project"`. Internal helpers; most callers invoke `install_skill` and don't call these directly.

Do not redefine these in your setup.sh — source the lib. When skill-forge releases a new lib version, update each skill's copy (skill-forge validate will detect drift via content hash in the future).

## Cascade Behavior

`install_skill` goes beyond `npx skills add`. After a successful install, it **automatically runs the newly installed skill's own `scripts/setup.sh`** — this mirrors npm's `postinstall` semantics, which `npx skills add` itself does not provide.

**Why this matters**: without cascade, installing skill A does not pull A's own dependencies. Depth-2 dependencies silently break unless the AI happens to read A's SKILL.md and manually triggers its Step 0. The cascade makes the dependency chain mechanical, not reliant on agent behavior.

```
A.setup.sh → install_skill "B" → npx skills add → runs B.setup.sh
                                                        → install_skill "C" → npx skills add → runs C.setup.sh
                                                                                                     → ...
```

**Recursion guard**: the `SKILL_DEPS_DEPTH` env var caps the cascade at 5 levels. A cyclic dependency (A → B → A) hits the cap and stops with a warning instead of looping forever. In practice no real dependency tree needs more than 2-3 levels.

**Failure propagation**: if any level's setup.sh exits non-zero, the cascade propagates the failure up. The upstream install_skill returns non-zero, which in turn causes the upstream setup.sh to BLOCK.

## Protocol Activation Hints

Some skills (notably Protocol skills like `rules-as-skills`) require an additional **activation** step after installation — running a script that modifies global environment state (e.g., injecting a meta-rule into every agent's global rule file). **Activation has side effects and must not be automated** — the user must see the prompt and consent before execution.

**Convention**: the activation hint is printed at the **tail of the skill's own setup.sh**. The lib does NOT detect any special "activate.sh" file — no new naming convention is introduced. Because `install_skill` cascades by running the installed skill's setup.sh, the activation hint naturally surfaces in the parent's install output without any extra machinery.

**Template** (put at the end of a Protocol skill's setup.sh, after all dep declarations):

```bash
cat <<EOF

NOTE: <skill-name> is a Protocol Skill.
To activate, run:
  $(dirname "$0")/<activation-script>

This modifies <what it modifies>. Run with 'uninstall' to revert.
EOF
```

Example (from rules-as-skills):

```bash
cat <<EOF

NOTE: rules-as-skills is a Protocol Skill.
To activate the meta-rule protocol across agent platforms, run:
  $(dirname "$0")/install-meta-rule.sh install

This modifies global rule files (~/.claude/rules/, ~/.codex/rules/, etc.).
Run with 'uninstall' to revert.
EOF
```

Non-Protocol skills omit this section entirely.

## Skill Installation Detection

Skills can exist in multiple directories depending on the installation method:

| Source | Location(s) |
|--------|------------|
| `npx skills add -g` | `~/.agents/skills/<name>/` + `~/.claude/skills/<name>/` (hardlinked) |
| Manual symlink | `~/.claude/skills/<name>/`, `~/.copilot/skills/<name>/`, `~/.cursor/skills/<name>/`, `~/.codeium/windsurf/skills/<name>/` |
| Project-level | `<project>/.claude/skills/<name>/`, `<project>/.agents/skills/<name>/`, etc. |

`npx skills add -g` automatically hardlinks to both `~/.agents/skills/` and `~/.claude/skills/`, so no manual symlink is needed. The `skill_installed` helper in install-skill-lib.sh checks all five canonical roots: Claude Code, Agents, Copilot, Cursor, Windsurf.

The helper function is **provided by the lib** — do not redefine it in setup.sh.

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

**`install_skill` always installs with `-g`** — this is the default and correct behavior for dependency skills.

## Declaration: Two Tiers

| Tier | Declared in | Behavior |
|------|-------------|----------|
| **Dependencies** | SKILL.md Step 0 + scripts/setup.sh | Must install. Missing → install. Can't install → block |
| **Informational** | README.md only | Human reading. AI does not act on it |

"Works Better With" does not exist in SKILL.md runtime logic.

## Example: skill-forge's own setup.sh

Standard pattern: CLI checks → source lib → declare skill dependencies → optional activation hint → exit gate.

```bash
#!/usr/bin/env bash
# skill-forge dependency checker.
set -euo pipefail

echo "skill-forge: checking dependencies..."
echo ""

errors=0

# --- CLI tools ---
for tool in git gh node npx; do
  if command -v "$tool" &>/dev/null; then
    echo "  $tool: $(command -v "$tool")"
  else
    echo "  ERROR: $tool not found"
    case "$tool" in
      git)  echo "  Install: https://git-scm.com" ;;
      gh)   echo "  Install: https://cli.github.com" ;;
      node) echo "  Install: https://nodejs.org" ;;
      npx)  echo "  Install: comes with Node.js — https://nodejs.org" ;;
    esac
    errors=$((errors + 1))
  fi
done

echo ""

# --- Skill dependencies via shared lib ---
source "$(dirname "$0")/install-skill-lib.sh"

# skill-forge is a tooling skill — deps live globally so they work across all
# user projects, not just whichever one invoked setup.sh. Pass -g explicitly.
install_skill "readme-craft"    "motiful/readme-craft"    "-g" || errors=$((errors + 1))
install_skill "rules-as-skills" "motiful/rules-as-skills" "-g" || errors=$((errors + 1))
install_skill "self-review"     "motiful/self-review"     "-g" || errors=$((errors + 1))

echo ""

# --- Result ---
if [ $errors -gt 0 ]; then
  echo "BLOCKED: $errors dependency issue(s). Fix above errors and re-run."
  exit 1
fi

echo "All dependencies ready."
exit 0
```

**What is NOT in this setup.sh anymore**: `skill_installed` and `install_skill` function definitions. They live in `install-skill-lib.sh` — the skill's copy sits at `scripts/install-skill-lib.sh`, sourced on the line above.

## Guidelines

- **Idempotent**: setup.sh runs every invocation, not just first use. Already-installed deps are detected and skipped instantly
- **Fast**: existence checks, not full test suites. A passing run should complete in under 2 seconds (skipping only). Cascade installs take longer on first run — expected
- **Informative**: print status for each dependency so the user sees what's happening
- **Non-interactive**: no prompts. Use `-y` flags where available. setup.sh is automated, not an onboarding flow
- **Fail loud**: exit non-zero with specific error messages. Never silently continue with missing deps
- **Lean shell**: setup.sh body ≤ 40 lines. Heavy lifting lives in install-skill-lib.sh, not in the shell
- **Keep lib copies up to date**: when the canonical lib in skill-forge/references/ changes, update each skill's `scripts/install-skill-lib.sh` copy. Skill-forge validate will flag drift
