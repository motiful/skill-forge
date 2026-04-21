#!/usr/bin/env bash
# install-skill-lib.sh — reusable skill dependency installer with scope control.
#
# Usage: source this file from your setup.sh, then call install_skill.
#
#   source "$(dirname "$0")/install-skill-lib.sh"
#
#   install_skill "readme-craft" "motiful/readme-craft"                        # project (default)
#   install_skill "readme-craft" "motiful/readme-craft" "-g"                   # global
#   install_skill "feel-better"  "jakubkrehel/make-interfaces-feel-better" "" "make-interfaces-feel-better"
#     └─ primary name + repo + empty scope flag + alt names (4th arg onward)
#
# Scope flag (third parameter, optional):
#   <none> (default)  — project-level: install under CWD (.claude/skills/ + .agents/skills/)
#                       mirrors `npx skills add` native default.
#   -g | --global     — user-level: install globally (~/.claude/skills/ + ~/.agents/skills/)
#                       mirrors `npx skills add -g`.
#
# Alt names (fourth parameter onward, optional):
#   Additional names under which the skill may be found installed. Used when the
#   repository name differs from the SKILL.md `name` field — e.g. repo
#   `jakubkrehel/make-interfaces-feel-better` installs as `make-interfaces-feel-better`,
#   but the caller may prefer the short alias `feel-better` as primary.
#   detect + resolve_path both try primary first, then each alt in order.
#
# Rationale for project default: matches npx skills add's native default, which reflects
# the safer behavior — don't pollute the user's global skill namespace unless explicitly
# asked. Tooling-style skills that should live globally (skill-forge, readme-craft, etc.)
# must pass "-g" explicitly.
#
# Custom absolute paths are NOT supported in v1 (npx skills add does not accept
# arbitrary paths). Planned for v0.2 via git clone fallback (see install-cascade-design.md §5.2).
#
# Requires: node + npx in PATH. Calls `npx skills add <repo> [-g] -y` under the hood.
#
# Cascade: after a successful install, runs the installed skill's own
# scripts/setup.sh to pull deeper dependencies. This mirrors npm's postinstall
# semantics that `npx skills add` itself does not provide. Recursion is capped
# by the SKILL_DEPS_DEPTH env var (max depth: 5).
#
# Activation hints: this lib does NOT detect or run any activate script. A skill
# that needs activation (e.g. Protocol skills modifying global rule files) must
# print its own hint from the tail of its scripts/setup.sh. The cascade will
# surface that hint naturally because we run the installed skill's setup.sh.

# --- skill_installed: check if a skill is already installed in the given scope ---
# Usage: skill_installed <name> [scope]
#   scope: "any" (default, checks both), "global", "project"
skill_installed() {
  local name=$1 scope=${2:-any}

  if [ "$scope" = "any" ] || [ "$scope" = "global" ]; then
    for root in \
      "$HOME/.claude/skills" \
      "$HOME/.agents/skills" \
      "$HOME/.copilot/skills" \
      "$HOME/.cursor/skills" \
      "$HOME/.codeium/windsurf/skills"; do
      [ -d "$root/$name" ] && return 0
    done
  fi

  if [ "$scope" = "any" ] || [ "$scope" = "project" ]; then
    [ -d "$PWD/.claude/skills/$name" ] && return 0
    [ -d "$PWD/.agents/skills/$name" ] && return 0
  fi

  return 1
}

# --- skill_install_path: resolve an installed skill's directory ---
# Usage: skill_install_path <name> [scope]
#   scope: "any" (default), "global", "project"
skill_install_path() {
  local name=$1 scope=${2:-any}

  if [ "$scope" = "any" ] || [ "$scope" = "global" ]; then
    for root in \
      "$HOME/.claude/skills" \
      "$HOME/.agents/skills" \
      "$HOME/.copilot/skills" \
      "$HOME/.cursor/skills" \
      "$HOME/.codeium/windsurf/skills"; do
      if [ -d "$root/$name" ]; then
        printf '%s\n' "$root/$name"
        return 0
      fi
    done
  fi

  if [ "$scope" = "any" ] || [ "$scope" = "project" ]; then
    if [ -d "$PWD/.claude/skills/$name" ]; then
      printf '%s\n' "$PWD/.claude/skills/$name"
      return 0
    fi
    if [ -d "$PWD/.agents/skills/$name" ]; then
      printf '%s\n' "$PWD/.agents/skills/$name"
      return 0
    fi
  fi

  return 1
}

# --- install_skill: install + cascade-run its setup.sh ---
# Usage: install_skill <name> <org/repo> [scope-flag] [alt-name...]
#   scope-flag (optional):
#     <none>            → project (default, matches `npx skills add`)
#     -g | --global     → global (matches `npx skills add -g`)
#   alt-name (optional, fourth arg onward):
#     additional names to probe when detecting / resolving path. See header comment.
install_skill() {
  local name=$1 repo=$2
  local scope="project"

  # Parse scope flag (third arg)
  case "${3:-}" in
    "")        scope="project" ;;
    -g|--global) scope="global" ;;
    *)
      echo "  ERROR: install_skill: unsupported scope flag '$3'"
      echo "  Accepted: <none> for project | -g | --global for global"
      echo "  Custom absolute paths planned for v0.2."
      return 1
      ;;
  esac

  # Collect alt names (args from 4th onward).
  local alt_names=()
  [ "$#" -ge 4 ] && alt_names=("${@:4}")

  # Detect: probe primary name, then each alt.
  if skill_installed "$name" "$scope"; then
    echo "  $name: installed ($scope)"
    return 0
  fi
  local alt
  for alt in ${alt_names[@]+"${alt_names[@]}"}; do
    if skill_installed "$alt" "$scope"; then
      echo "  $name: installed as $alt ($scope)"
      return 0
    fi
  done

  echo "  $name: installing ($scope)..."
  # Build npx flags: always -y; add -g only for global
  local npx_flags=("-y")
  [ "$scope" = "global" ] && npx_flags=("-g" "-y")

  if ! npx skills add "$repo" "${npx_flags[@]}" 2>/dev/null; then
    echo "  ERROR: failed to install $name ($scope)"
    echo "  Manual fix: npx skills add $repo ${npx_flags[*]}"
    return 1
  fi
  echo "  $name: installed"

  # Resolve path: try primary name, then each alt.
  local path=""
  path=$(skill_install_path "$name" "$scope") || path=""
  for alt in ${alt_names[@]+"${alt_names[@]}"}; do
    [ -n "$path" ] && break
    path=$(skill_install_path "$alt" "$scope") || path=""
  done
  if [ -z "$path" ]; then
    echo "  WARN: $name installed but install path not detectable (tried: $name ${alt_names[*]-}) — skipping cascade"
    return 0
  fi

  # Cascade: run the newly installed skill's setup.sh if present.
  # SKILL_DEPS_DEPTH caps recursion to prevent cycles.
  local depth=${SKILL_DEPS_DEPTH:-0}
  if [ "$depth" -ge 5 ]; then
    echo "  WARN: cascade depth $depth reached on $name — stopping recursion"
    return 0
  fi

  if [ -x "$path/scripts/setup.sh" ]; then
    echo "  $name: running its setup.sh..."
    if ! SKILL_DEPS_DEPTH=$((depth + 1)) bash "$path/scripts/setup.sh"; then
      echo "  ERROR: $name's setup.sh failed"
      return 1
    fi
  fi

  return 0
}
