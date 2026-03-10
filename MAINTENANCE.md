# Skill Forge Maintenance

This file is for the agent maintaining skill-forge itself — not for users or the publishing agent.

Trigger: "update skill-forge", "refresh platform info", or during self-review of this project.

## Updating Platform Registry

1. Open `references/platform-registry.md`
2. For each platform in the Per-Platform Reference table, check its Docs link for path changes
3. Search: "agent skills directory [platform name] 2026" for any new platforms
4. Check: has any platform added or removed `.agents/skills/` support?
5. Update paths + "Last verified" date in platform-registry.md
6. If path changes affect the Detection logic or Step 4e in SKILL.md, update those too
7. Add a changelog entry below (keep max 5 entries, trim oldest)

## Updating Community Tools

1. Check `npx skills add` — still maintained? New features?
2. Check `skills-ref validate` — any new validation rules?
3. Update the Community Tools table in platform-registry.md if needed

## Changelog (max 5 entries)

- 2026-03-09: Initial registry. Two-track (`.claude/` + `.agents/`). Verified 6 platforms: CC, Codex, Cursor, Windsurf, Gemini CLI, Copilot.
