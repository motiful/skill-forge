#!/usr/bin/env bash
# Extract actionable findings ([ ] rows) from individual finding files
# and APPEND them to the plan file.
# Usage: extract-actionable.sh <findings_dir> <plan_file>
#
# Input:  findings_dir/*.md (one per skill, with PASS and [ ] rows)
# Output: Appends ## Findings section to plan_file (only [ ] rows, grouped by skill)

set -euo pipefail

findings_dir="${1:?Usage: extract-actionable.sh <findings_dir> <plan_file>}"
plan_file="${2:?Usage: extract-actionable.sh <findings_dir> <plan_file>}"

echo "" >> "$plan_file"
echo "## Findings" >> "$plan_file"
echo "" >> "$plan_file"

for f in "${findings_dir}"/*.md; do
  skill=$(basename "$f" .md)
  [ "$skill" = "REPORT" ] && continue
  lines=$(grep '^- \[ \]' "$f" || true)
  if [ -n "$lines" ]; then
    echo "### $skill" >> "$plan_file"
    echo "$lines" >> "$plan_file"
    echo "" >> "$plan_file"
  fi
done

count=$(grep -c '^- \[ \]' "$plan_file" || echo 0)
echo "extract-actionable: ${count} actionable findings appended to ${plan_file}"
