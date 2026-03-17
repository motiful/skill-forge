# Skill Forge Maintenance

This file is for the agent maintaining skill-forge itself — not for users or the publishing agent.

Trigger: "update skill-forge", "refresh platform info", or during self-review of this project.

## Updating Platform Registry

1. Open `references/platform-registry.md`
2. For each platform in the Per-Platform Reference table, check its Docs link for user-level native paths, project-level native paths, any documented shared compatibility directories, and whether the link itself still resolves
3. Search: "agent skills directory [platform name] 2026" for any new platforms
4. Check separately: which `~` paths are vendor-native, which project paths are vendor-native, which shared directories (`.claude`, `.agents`, `.github`) are officially accepted by more than one tool, and which paths are only configurable custom locations
5. Only actual skill roots count as strong signals. Bare parent dirs such as `.github/`, `.claude/`, `.agents/`, `.cursor/`, or `.windsurf/` do not justify registration by themselves
6. Treat Gemini CLI as adjacent tooling unless its official docs add Agent Skills directory support; today it uses extensions / commands, not the same registry model
7. Update paths + "Last verified" date in platform-registry.md
8. Keep platform facts separate from forge behavior: registry facts may change without changing the default registration policy
9. If path changes affect the Detection logic, README install examples, or the Local Registration section in Step 4 of SKILL.md, update those too
10. If README writing guidance changes, update both `references/templates.md` and `references/readme-quality.md`
11. Add a changelog entry below (keep max 5 entries, trim oldest)

## Updating Community Tools

1. Check `npx skills add` — still maintained? New features?
2. Check `skills-ref validate` — any new validation rules? Keep it positioned as an optional pre-publish sanity check, not a required dependency
3. Check the current skills.sh FAQ before making visibility claims. Keep direct installability separate from directory or leaderboard visibility
4. Update the Community Tools table in platform-registry.md if needed

## Contribution Criteria

Use the **Decision Test** from `docs/quality-principles.md` to evaluate every proposed change (PR, issue, or self-initiated improvement):

1. Does it help users' skills score higher on the 6 quality dimensions?
2. Is it simple enough that an AI agent will reliably follow it?
3. Can it be expressed as prompts instead of scripts?
4. Does it impose an architectural opinion that most skills don't need?
5. Is it a platform or infrastructure concern, not a skill quality concern?
6. Does the ecosystem actually use this pattern?
7. Do we practice it ourselves?

**Accept** when answers are: yes, yes, yes, no, no, yes, yes. Any "wrong" answer requires justification or redesign.

Additional PR hygiene:
- Changes to SKILL.md must not push body over 500 lines
- New reference files need a corresponding entry in SKILL.md's References section
- Terminology changes must be consistent across SKILL.md, README.md, and all affected reference files

## Self-Governance

skill-forge validates other skills. It must also pass its own validation.

**Self-review protocol** (run periodically or after significant changes):
1. Run skill-forge Review on this repo
2. Every README claim must be backed by a SKILL.md capability
3. Every reference file listed in SKILL.md must exist and be current
4. Version in SKILL.md frontmatter, README badge, and changelog must agree

**Consistency checks**:
- SKILL.md description matches README's positioning
- "What's Inside" file tree in README matches actual `references/` directory
- No residual terminology from previous versions (check for: "five-layer", "Kit", "JIT", "Enhancement Report", "Quick Review", "Full Pipeline", "Multi-Skill Triage", "Scenario 1/2/3/4/5")

## Update Triggers

Beyond scheduled platform registry checks, these events should trigger a maintenance pass:

| Event | What to check |
|-------|--------------|
| Agent Skills standard changes | SKILL.md frontmatter fields, `references/skill-format.md` |
| New platform adopts Agent Skills | `references/platform-registry.md`, README install examples, SKILL.md Step 4 |
| `npx skills add` breaking change | README install commands, Quick Start |
| skill-forge's own SKILL.md changes | README alignment, "What's Inside" tree, version badge |
| New reference file added | SKILL.md References section, README "What's Inside" |
| Community feedback or bug report | Relevant validation checks in SKILL.md Step 3 |

## Changelog (max 5 entries)

- 2026-03-17: **v5.0 — Two modes, one action.** Replaced 5 engagement scenarios (Quick Review, Full Pipeline, Multi-Skill Triage, Full Create, Graduation) with 2 modes (Review, Create) and 1 independent action (Publish). Multi-skill triage and graduation folded into Review as sub-behaviors. Community Readiness checks merged into Core Validation (always run). Default behavior changed from "scope is user-defined" to "run to local-ready, user can stop". Publish is never auto-triggered.
- 2026-03-16: **v4.0 — Prescription-driven practice.** Fixed 6 internal contradictions in quality-principles.md. Dependencies must install (no graceful skip). setup.sh is the standard. Three-layer separation: Installation / Onboarding / Configuration. Replaced `precondition-checks.md` with `installation.md` + `onboarding.md`. Removed `state-management.md` (absorbed into skill-configuration.md). Added self-review as dependency.
- 2026-03-16: **v3.1 — Scenario-based engagement.** Restructured SKILL.md from linear pipeline to 5 engagement scenarios with 7 engagement principles.
- 2026-03-16: **v3.0 — Principle-driven simplification.** Added `references/quality-principles.md` as the decision compass. Removed Capability Detection table, JIT dependency pattern, Enhancement Report, and Kit publishing model.
- 2026-03-15: Added JIT dependency pattern (subsequently removed in v3.0).
