# Precondition Checks

Optional workflow pattern: checking for external tools before the skill's main workflow runs.

## When to Use

Include a precondition check step when the skill depends on external tools that may not be present:

- CLI tools (`gh`, `node`, `npx`, `docker`)
- npm packages (check `node_modules/` or run `npm install`)
- APIs or services that need authentication
- Companion skills that enhance specific steps

## When NOT to Use

- Skill auto-discovers everything from project files (no external deps)
- Skill is pure methodology with no runtime dependencies
- Information is available from the runtime environment (agent platform, OS, working directory)

## Pattern

Add a Step 0 that runs **every invocation** (not just first use):

```
Step 0: Precondition Check
  1. Check for required tools (e.g., node --version, gh --version)
  2. Missing? → install or inform user
  3. All present? → proceed to Step 1
```

**Key principle:** Run every time, not gated behind a config marker. If `node_modules/` gets deleted, the next run should detect and fix it — not silently fail because a config file says "setup complete."

## Examples

**readme-craft** checks for Node.js and npm packages every run:
```
1. node --version → Node 18+?
2. node_modules/ exists?
3. Not found → npm install
```

**skill-forge** checks for `gh` CLI and forge config:
```
1. gh --version → GitHub CLI available?
2. ~/.config/skill-forge/config.md exists?
3. Not found → detect defaults, create config (see skill-configuration.md)
```

## Fallback Patterns

When a required tool is absent, choose the appropriate strategy:

| Strategy | When to use | Example |
|----------|-------------|---------|
| **Auto-install** | Project-level dependency, safe to install | `npm install` for missing `node_modules/` |
| **Graceful skip** | Feature is enhanced by the tool but not blocked without it | Companion skill absent → use built-in fallback, mention what's missing |
| **Block with instruction** | Core dependency, skill cannot function without it | `gh` CLI missing → tell user: "Install with `brew install gh`, then re-run" |

Choose the least disruptive strategy. Auto-install when safe, skip when possible, block only when the tool is truly essential.

### Graceful Skip Example

```
Step 0:
  1. Check for readme-craft skill
  2. Found → use 3-tier layout engine in Step 4
  3. Not found → use built-in README template from references/templates.md
     Tell user: "readme-craft not found — using built-in template.
     For richer README layout: npx skills add motiful/readme-craft"
```

## First-Run Initialization

Step 0 can handle two concerns simultaneously:

1. **Precondition checks** — are required tools present? (runs every time)
2. **Config initialization** — does the skill's config file exist? (creates only on first run)

Both run every invocation, but config creation only triggers when the file is missing. The check itself always runs — this ensures a deleted config file gets recreated rather than silently breaking the skill.

See `skill-configuration.md` for the full configuration pattern (location, format, litmus test).

## Guidelines

- Keep precondition checks fast — existence checks, not full test suites
- Handle absence gracefully: install if possible, skip with explanation if not
- Don't interrogate the user — detect what you can, confirm once
- If a companion skill would improve a step but is absent, describe the fallback and move on
- Always run checks — don't gate behind a "setup complete" marker
