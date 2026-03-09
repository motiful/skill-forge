# Platform Registry

Last verified: 2026-03-09

This file is read by Step 4e at publish time. It tells the agent where to create symlinks.

## Registration Paths

All symlinks point to the same source of truth: `<skill_root>/<skill-name>/skill/`.

### Claude Code

Claude Code does NOT read `.agents/skills/`. It has its own path.

| Scope | Path |
|-------|------|
| Global | `~/.claude/skills/<name>/` |
| Project | `<project>/.claude/skills/<name>/` |

Always register here — forge runs in CC.

### .agents/skills/ (Cross-Platform Standard)

Adopted by Codex CLI, Cursor, Windsurf, Gemini CLI, GitHub Copilot. One symlink covers all of them.

| Scope | Path |
|-------|------|
| Global | `~/.agents/skills/<name>/` |
| Project | `<project>/.agents/skills/<name>/` |

Always registered alongside Claude Code for cross-platform availability.

## Detection

```
Global:
  ~/.claude/skills/          → always symlink
  ~/.agents/skills/          → always symlink (create dir if absent)

Project:
  <project>/.claude/ exists  → symlink into .claude/skills/
  <project>/.agents/ exists  → symlink into .agents/skills/
  Neither exists             → ask user which to create
```

## Per-Platform Reference

The agent does not create per-platform symlinks — the two paths above are sufficient. This table exists so the agent can answer user questions like "will Cursor pick this up?".

| Platform | Native path (global) | Reads `.agents/skills/`? | Docs |
|----------|---------------------|--------------------------|------|
| Claude Code | `~/.claude/skills/<name>/` | No | [docs](https://code.claude.com/docs/en/skills) |
| Codex CLI | `~/.agents/skills/<name>/` (native) | Yes | [docs](https://developers.openai.com/codex/skills/) |
| Cursor | `~/.cursor/skills/<name>/` | Yes | [docs](https://cursor.com/docs/context/skills) |
| Windsurf | `~/.codeium/windsurf/skills/<name>/` | Yes | [docs](https://docs.windsurf.com/windsurf/cascade/skills) |
| Gemini CLI | `~/.gemini/skills/<name>/` | Yes | [docs](https://geminicli.com/docs/cli/skills/) |
| GitHub Copilot | `.github/skills/` (project only) | Yes | [docs](https://code.visualstudio.com/docs/copilot/customization/agent-skills) |

## Community Tools

| Tool | Command | Purpose |
|------|---------|---------|
| Vercel Skills CLI | `npx skills add <org>/<repo>` | Auto-detect platforms, install to correct path |
| skills-ref | `skills-ref validate <path>` | Validate SKILL.md against Agent Skills spec |

## Community Directories

| Platform | URL | Notes |
|----------|-----|-------|
| skills.sh | [skills.sh](https://skills.sh) | Auto-indexes GitHub repos |
| SkillsMP | [skillsmp.com](https://skillsmp.com) | 66k+ skills |
| LobeHub | [lobehub.com/skills](https://lobehub.com/skills) | Marketplace |
