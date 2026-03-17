# Platform Registry

## TOC

- [Core Rule](#core-rule)
- [Skill Forge Registration Policy](#skill-forge-registration-policy)
- [Detection Signals](#detection-signals)
  - [Weak Signal Decision Tree](#weak-signal-decision-tree)
- [Documented Directories](#documented-directories)
- [Detection / Registration Strategy](#detection--registration-strategy)
- [Per-Platform Reference](#per-platform-reference)
- [Adjacent Tooling (Different Model)](#adjacent-tooling-different-model)
- [Community Tools](#community-tools)
- [Community Directories](#community-directories)

Last verified: 2026-03-17

This file is read by the Local Registration section at publish time. User-level skill directories are **not** standardized across agents. Do not describe `~/.agents/skills/` as a universal home-directory path, and do not treat platform directory management as Skill Forge's default responsibility.

## Core Rule

Distinguish between:

- **Native directories** — vendor-owned paths such as `~/.claude/skills/` or `~/.cursor/skills/`
- **Shared compatibility directories** — paths that more than one vendor officially reads, such as `.claude/skills/` or `.agents/skills/`
- **Configurable custom locations** — paths the user can point a tool at manually; these are not the same as built-in shared directories
- **Source of truth** — the actual repo at `<skill_root>/<skill-name>/`

There is no single `~` directory that officially covers Claude Code, Codex, Cursor, Windsurf, and GitHub Copilot together.

Every consumer root should link back to the source of truth. Do **not** link one vendor root to another vendor root.

Only actual skill roots count as registration evidence. Parent config directories alone are not enough.

## Skill Forge Registration Policy

**Do not ask the user to choose a mode.** Detect existing roots, include them in a preflight summary, then link into them after confirmation. The agent decides the implementation details; the user approves the side effects.

| Situation | Behavior |
|-----------|----------|
| Existing skill roots detected | Add all detected roots to the preflight, then link after confirmation |
| No roots detected | Skip registration — tell user the repo is ready |
| User explicitly names a platform | Add that platform root to the preflight if missing, then create and link after confirmation |

## Detection Signals

Treat these as **strong signals**:

- Existing global roots: `~/.claude/skills/`, `~/.agents/skills/`, `~/.copilot/skills/`, `~/.cursor/skills/`, `~/.codeium/windsurf/skills/`
- Existing project roots: `<project>/.claude/skills/`, `<project>/.agents/skills/`, `<project>/.github/skills/`, `<project>/.cursor/skills/`, `<project>/.windsurf/skills/`

Treat these as **weak signals**:

- Installed CLI or desktop app without a skill root
- Generic config directories without a skills directory
- Bare parent dirs such as `<project>/.github/`, `<project>/.claude/`, `<project>/.agents/`, `<project>/.cursor/`, `<project>/.windsurf/`
- Tooling docs or shell history that imply usage but do not show a current registration target

Do not create directories from weak signals alone.

### Weak Signal Decision Tree

When a weak signal is detected (e.g., `~/.agents/` exists but no `skills/` subdirectory):

1. **Record** — note the finding internally
2. **Include in preflight** — "Detected `~/.agents/` — want to register for Codex?"
3. **User says yes** → create the skill root directory + symlink
4. **User says no** → skip, do not ask again this session
5. **User doesn't mention** → do not ask, do not create

Never act on weak signals without explicit user confirmation. Never create directories from weak signals alone.

## Documented Directories

### User-Level (`~`) Directories

| Directory | Documented support |
|-----------|--------------------|
| `~/.claude/skills/<name>/` | Claude Code (native), VS Code / GitHub Copilot (compat), Windsurf (compat if Claude Code config reading is enabled) |
| `~/.agents/skills/<name>/` | Codex (native), Windsurf (compat) |
| `~/.copilot/skills/<name>/` | VS Code / GitHub Copilot (native) |
| `~/.cursor/skills/<name>/` | Cursor (native) |
| `~/.codeium/windsurf/skills/<name>/` | Windsurf (native) |

### Project-Level Directories

| Directory | Documented support |
|-----------|--------------------|
| `<project>/.claude/skills/<name>/` | Claude Code (native), VS Code / GitHub Copilot (compat), Windsurf (compat if Claude Code config reading is enabled) |
| `<project>/.agents/skills/<name>/` | Codex (native), Windsurf (compat) |
| `<project>/.github/skills/<name>/` | VS Code / GitHub Copilot (native) |
| `<project>/.cursor/skills/<name>/` | Cursor (native) |
| `<project>/.windsurf/skills/<name>/` | Windsurf (native) |

### Configurable But Not Built-In Shared

| Platform | Notes |
|----------|-------|
| VS Code / GitHub Copilot | Supports additional custom skill locations via settings. A user-configured path does not make that path a documented built-in shared directory. |

## Detection / Registration Strategy

```
1. Scan for existing global + project skill roots (strong signals only)
2. Roots found → add them to the preflight summary; after confirmation, link into all of them and report what was linked
3. Only bare parent config dirs found → ignore them; they do not justify registration
4. No roots found → skip, tell user repo is ready
5. User explicitly names a platform → add that root to the preflight; after confirmation, create it if missing, then link
```

## Per-Platform Reference

| Platform | Native user path | Native project path | Also accepts shared directories | Notes | Docs |
|----------|------------------|---------------------|---------------------------------|-------|------|
| Claude Code | `~/.claude/skills/<name>/` | `<project>/.claude/skills/<name>/` | No documented `.agents` support | Forge runs in Claude Code, so this path is always first-class | [docs](https://docs.anthropic.com/en/docs/claude-code/skills) |
| Codex CLI | `~/.agents/skills/<name>/` | `<project>/.agents/skills/<name>/` | N/A | Also scans `/etc/codex/skills/` for system-level installs | [docs](https://developers.openai.com/codex/skills) |
| Cursor | `~/.cursor/skills/<name>/` | `<project>/.cursor/skills/<name>/` | None documented | Use the native Cursor path. Do not promise `.agents` support unless Cursor documents it. If user-level symlinks are flaky in the target setup, prefer a real native mirror. | [docs](https://cursor.com/docs/context/skills) |
| Windsurf | `~/.codeium/windsurf/skills/<name>/` | `<project>/.windsurf/skills/<name>/` | Yes: `~/.agents/skills/`, `<project>/.agents/skills/`, and `.claude` variants when Claude Code config reading is enabled | Native path exists, but compatibility scanning often makes extra mirrors unnecessary | [docs](https://docs.windsurf.com/windsurf/cascade/skills) |
| VS Code / GitHub Copilot | `~/.copilot/skills/<name>/` | `<project>/.github/skills/<name>/` | Yes: `~/.claude/skills/`, `<project>/.claude/skills/` | VS Code also supports configured custom locations via settings | [docs](https://code.visualstudio.com/updates/v1_109#_project-and-user-agent-skills) |

## Adjacent Tooling (Different Model)

| Tool | Official model | Relevant paths | Notes | Docs |
|------|----------------|----------------|-------|------|
| Gemini CLI | Extensions + commands | `~/.gemini/extensions/`, `~/.gemini/commands/`, `<project>/.gemini/commands/` | Not an Agent Skills directory consumer. Do not register SKILL.md repos here as if they were standard skills. | [extensions](https://github.com/google-gemini/gemini-cli/blob/main/docs/extension.md) |

## Community Tools

| Tool | Command | Purpose |
|------|---------|---------|
| Vercel Skills CLI | `npx skills add <org>/<repo>` | Auto-detect platforms, install to correct path |
| skills-ref | `skills-ref validate <path>` | Optional pre-publish spec sanity check for users who already have it installed |

## Community Directories

| Platform | URL | Notes |
|----------|-----|-------|
| skills.sh | [skills.sh](https://skills.sh) | Leaderboard visibility follows `npx skills add` telemetry; do not promise immediate ranking from GitHub publication alone |
| SkillsMP | [skillsmp.com](https://skillsmp.com) | 66k+ skills |
| LobeHub | [lobehub.com/skills](https://lobehub.com/skills) | Marketplace |

## CC Market (Claude Code Marketplace)

Anthropic's official marketplace for Claude Code extensions. Requires review and approval.

### Assessment

| Factor | Evaluation |
|--------|-----------|
| **Review process** | Strict — manual review, may take days/weeks |
| **Incremental value** | Low — GitHub repos are already natively installable via `npx skills add` without any marketplace |
| **Maintenance burden** | Each update may require re-review |
| **Discoverability** | Marginal — most users discover skills via GitHub, skills.sh, or word of mouth |
| **Recommendation** | Skip by default. Only publish if user explicitly wants CC Market presence |

### Publishing Flow

**Push behavior:**

```
1. Config has cc_market setting?
   Yes, true  → include CC Market submission in publish flow
   Yes, false → skip CC Market silently
   No         → continue to step 2

2. First-time: ask once with recommendation
   "Your skill is on GitHub and already installable via npx skills add.
    CC Market adds an Anthropic-curated listing, but requires manual review
    on every update. Recommend: skip.
    Publish to CC Market? [y/N]"

   Save answer to ~/.config/skill-forge/config.md as cc_market: true/false
```

Config example:
```markdown
## Publishing
- cc_market: false    # asked 2026-03-17, user chose to skip
```

### Why Default Off

GitHub + `npx skills add` gives you:
- Instant installability (zero review)
- Cross-platform compatibility (all Agent Skills adopters)
- Version control, issues, PRs, community contributions
- Automatic indexing by skills.sh and other directories

CC Market adds:
- An Anthropic-branded listing (but only for Claude Code users)
- Review overhead on every update
- Platform lock-in (CC-only visibility)

For most skill authors, GitHub publication is sufficient. CC Market is for authors who specifically want Anthropic-curated visibility.
