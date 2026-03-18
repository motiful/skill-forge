---
name: maintenance-rules
description: 'Maintenance rules for the skill-forge repo. MUST run Decision Test before accepting changes. MUST update platform-registry when platforms change. MUST keep SKILL.md under 500 lines. MUST verify cross-file consistency after changes. Triggers on "update skill-forge", "maintain skill-forge", "refresh platform registry".'
metadata:
  author: motiful
---

# skill-forge Maintenance Rules

Constraints and procedures for maintaining the skill-forge repository.

## Constraints

- MUST run Decision Test (7 criteria from `docs/quality-principles.md`) before accepting any change
- MUST NOT push SKILL.md body over 500 lines
- MUST keep SKILL.md ↔ README ↔ references terminology consistent
- MUST add References section entry when adding new reference files
- MUST update "What's Inside" tree in README when references/ changes
- MUST NOT include content that fails the Content Audience Check (see references/skill-format.md)

## Platform Registry Updates

1. Open `references/platform-registry.md`
2. For each platform, check Docs link for: user-level paths, project-level paths, shared compat directories, link validity
3. Search: "agent skills directory [platform name] 2026" for new platforms
4. Distinguish: vendor-native paths vs compat-scanned paths vs custom locations
5. Only actual skill roots count as strong signals (not bare parent dirs)
6. Treat Gemini CLI as adjacent tooling unless official docs add Agent Skills directory support
7. Update paths + "Last verified" date
8. Keep platform facts separate from forge behavior
9. If path changes affect SKILL.md Fix Phase, README install examples, or Detection logic, update those too
10. If README writing guidance changes, update both `references/templates.md` and `references/readme-quality.md`
11. Add changelog entry (keep max 5, trim oldest)

## Community Tools Updates

1. Check `npx skills add` — still maintained? New features?
2. Check `skills-ref validate` — new validation rules? Keep as optional, not required dependency
3. Check skills.sh FAQ before making visibility claims. Installability ≠ directory/leaderboard visibility
4. Update Community Tools table in `references/platform-registry.md` if needed

## Contribution Criteria

Use the **Decision Test** from `docs/quality-principles.md`:

1. Does it help users' skills score higher on the 6 quality dimensions?
2. Is it simple enough that an AI agent will reliably follow it?
3. Can it be expressed as prompts instead of scripts?
4. Does it impose an architectural opinion most skills don't need?
5. Is it a platform or infrastructure concern, not skill quality?
6. Does the ecosystem actually use this pattern?
7. Do we practice it ourselves?

**Accept** when: yes, yes, yes, no, no, yes, yes. Wrong answers need justification.

PR hygiene:
- Changes to SKILL.md must not push body over 500 lines
- New reference files need a SKILL.md References entry
- Terminology changes must be consistent across SKILL.md, README.md, and all affected references

## Self-Governance

skill-forge validates other skills. It must also pass its own validation.

Protocol (run after significant changes):
1. Run skill-forge Review on this repo
2. Every README claim must be backed by a SKILL.md capability
3. Every reference listed in SKILL.md must exist and be current
4. Version in frontmatter, README badge, and changelog must agree

## Consistency Checks

- SKILL.md description matches README positioning
- "What's Inside" tree matches actual references/ directory
- No residual terminology from previous versions: "five-layer", "Kit", "JIT", "Enhancement Report", "Quick Review", "Full Pipeline", "Multi-Skill Triage", "Scenario 1/2/3/4/5"

## Update Triggers

| Event | What to check |
|-------|--------------|
| Agent Skills standard changes | SKILL.md frontmatter, `references/skill-format.md` |
| New platform adopts Agent Skills | `references/platform-registry.md`, README install examples, SKILL.md Fix Phase |
| `npx skills add` breaking change | README install commands, Quick Start |
| skill-forge SKILL.md changes | README alignment, "What's Inside", version badge |
| New reference file added | SKILL.md References section, README "What's Inside" |
| Community feedback or bug report | Relevant validation checks in SKILL.md Step 3 |

## Changelog (max 5 entries)

- 2026-03-18: **v6.1 — Maintenance as in-repo rule-skill.** Converted MAINTENANCE.md to `.claude/skills/maintenance-rules/`. Added in-repo skills concept to publishing-strategy. Restored rules-as-skills as dependency. Slimmed rule-skill-pattern.md to forge-specific logic.
- 2026-03-17: **v6.0 — Kill Publish as standalone path.** Removed Publish mode. Step 3 invokes readme-craft. Push is single action after local ready.
- 2026-03-17: **v5.0 — Two modes, one action.** Review + Create + Push.
- 2026-03-16: **v4.0 — Prescription-driven practice.** Dependencies must install. setup.sh standard.
- 2026-03-16: **v3.1 — Scenario-based engagement.** 5 engagement scenarios.
