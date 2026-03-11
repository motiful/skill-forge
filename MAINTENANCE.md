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

## Changelog (max 5 entries)

- 2026-03-11: Eliminated "companion" terminology — unified under "Recommend". Renamed `constraint-companion.md` → `rule-skill-pattern.md`. "Companion Recommendations" capability → "Recommend". "Constraint Companion" capability → "Rule-Skill Split". 35 occurrences across 9 files.
- 2026-03-11: Promoted Recommend to a first-class optional output, aligned Recommend vs Kit guidance, and locked the default authoring language to English unless the skill is language-specific or culture-specific.
- 2026-03-11: Tightened registration evidence to actual skill roots only, separated direct installability from downstream discoverability, and aligned README/registry guidance with that policy.
- 2026-03-11: Added a single preflight confirmation for side effects, taught Step 1 to scan the configured `skill_root`, clarified native vs shared vs configurable paths, and fixed the Codex skills docs link.
- 2026-03-11: Repositioned `skills-ref` as an optional pre-publish sanity check for users who already have it installed; manual validation remains the core path.
