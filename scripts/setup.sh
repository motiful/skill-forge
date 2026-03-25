#!/usr/bin/env bash
# skill-forge dependency checker
# Verifies CLI tools (git, gh, node, npx) and installs skill dependencies
# (readme-craft, rules-as-skills, self-review) via npx skills add.
# No special permissions required. Safe to re-run (idempotent).
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
