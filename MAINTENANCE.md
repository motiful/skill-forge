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

- 2026-03-12: Collapsed the old Recommend tier back into the single-skill model. `skill-forge` now treats recommended skills as a lightweight writing pattern inside one skill plus `Works Better With` in README, not as a separate publishing type.
- 2026-03-11: Made Rule-Skill Split self-containment explicit. Generated capability skills must say `<name>-rules` is optional, keep a real standalone fallback, and avoid implying a hidden dependency.
- 2026-03-11: Renamed `constraint-companion.md` → `rule-skill-pattern.md`, clarified Rule-Skill Split naming, and temporarily consolidated companion-skill language under Recommend before the 2026-03-12 simplification.
- 2026-03-11: Aligned single-skill composition guidance, Kit guidance, and default English authoring rules; later simplified the composition taxonomy again on 2026-03-12.
- 2026-03-11: Tightened registration evidence to actual skill roots only, separated direct installability from downstream discoverability, and aligned README/registry guidance with that policy.
