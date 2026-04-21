#!/usr/bin/env bash
# skill-forge dependency checker.
# Verifies CLI tools (git, gh, node, npx) and installs skill dependencies
# (readme-craft, rules-as-skills, self-review) via the shared install-skill-lib.sh.
# Safe to re-run (idempotent). No sudo required.
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

install_skill "readme-craft"    "motiful/readme-craft"    || errors=$((errors + 1))
install_skill "rules-as-skills" "motiful/rules-as-skills" || errors=$((errors + 1))
install_skill "self-review"     "motiful/self-review"     || errors=$((errors + 1))

echo ""

# --- Result ---
if [ $errors -gt 0 ]; then
  echo "BLOCKED: $errors dependency issue(s). Fix above errors and re-run."
  exit 1
fi

echo "All dependencies ready."
exit 0
