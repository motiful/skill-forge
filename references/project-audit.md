# Project Audit

Discovery, Classification, and Plan File logic for Review mode.

Every Review run — single skill or full project — starts with Discovery. The plan file is always created. Discovery determines what the plan contains.

## TOC

- [Discovery](#discovery)
- [Classification](#classification)
- [Plan File](#plan-file)
- [Rules Quality](#rules-quality)
- [Rules Conversion](#rules-conversion)
- [Execution Order](#execution-order)

## Discovery

Traverse the **full project tree** from the target path. Do not limit to known directories — scan everything, then filter for agent-related content.

**What to look for (examples, not an exhaustive list):**

| Category | Examples |
|----------|---------|
| Skills | `SKILL.md` anywhere in the tree, `.claude/skills/*/SKILL.md`, `.agents/skills/*/SKILL.md`, `skills/*/SKILL.md`, `skill/SKILL.md` |
| Project instructions | `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md`, `AGENTS.override.md`, `.github/copilot-instructions.md` |
| Rules | `.claude/rules/*.md`, `.cursor/rules/*.mdc`, `rules/` directories, any `*.rules.md` |
| Setup/install | `scripts/setup.sh`, `install.sh`, scripts that install skills or tools |
| Config | `~/.config/skill-forge/config.md`, `.skillforge` |

**Go as deep as the tree goes.** A project may have:
- Global skills registered in `~/.claude/skills/`
- Local skills in `<project>/.claude/skills/`
- Nested subproject skills in `<project>/packages/*/SKILL.md`
- Rules scattered across multiple subdirectories

Inventory everything found before classifying. Do not skip files because they are in unexpected locations.

## Classification

Apply to every item in the discovery inventory. Use the Decision Framework from `references/publishing-strategy.md` as the primary lens.

| Type | Signals | Action |
|------|---------|--------|
| **In-repo maintenance** | References this repo's specific files, paths, or conventions; only useful to this repo's developers/maintainers | Stay in-repo — validate in-place |
| **Product skill** | Designed to be distributed with the product; end users install it to use the product better | Stay in-repo — validate + check distribution structure + reorganize if needed |
| **Personal tool** | Generic enough to work outside this project; developer uses or would use it across multiple projects | Proactive graduation → `<skill_workspace>/<name>/`, full Review, register globally |
| **External (imported)** | Installed via `npx skills add`, content unmodified | Inventory only — do not touch |
| **Rules file** | `.claude/rules/`, CLAUDE.md, condition-based instruction files | Assess quality + conversion potential (see [Rules Conversion](#rules-conversion)) |

**When classification is ambiguous:** ask the user once with your reasoning. Present the two most likely types and your recommendation. Do not assume graduation for something that might be project-specific.

**Product skill distribution:** if a product skill should be distributed to users, determine the right structure:
- One skill → standalone repo (`npx skills add <org>/<name>`)
- Multiple skills that belong together → collection (`npx skills add <org>/<collection>`)
- Execute the reorganization — do not just recommend it. Copy files, set up repo structure via Fix Phase (git init, README, LICENSE, local registration — no external scaffolding tool needed), run full Review on each extracted skill.

**Collection vs. standalone — detection signals:**

| Signal | Suggests |
|--------|---------|
| Skills reference each other as dependencies | Collection |
| The product workflow breaks if any one skill is missing | Collection |
| All skills share the same install audience (users always need all of them) | Collection |
| Each skill delivers value independently; users might want only one | Separate standalone repos |
| Skills have distinct trigger scenarios with no overlap | Separate standalone repos |

When ambiguous, default to **separate standalone repos** — easier to install selectively, easier to version independently. Collection is the exception, not the default.

## Plan File

**Always created** at the start of every Review. Deleted when all steps are complete.

**Path:** `/tmp/skill-forge-<name>.md` where `<name>` is the last path segment of the target (e.g., `booth`, `skill-forge`, `my-project`).

**If a plan file already exists at that path:** re-read it, find the first incomplete step (`- [ ]`), resume from there. Do not restart discovery — trust the existing plan.

**Format:**

```markdown
# Skill Forge Plan
## Target: <absolute path>
## Date: <YYYY-MM-DD>

## Discovery Summary
- X skills found
- Y rules files found
- Z project instruction files found

## Classification
| Item | Type | Action |
|------|------|--------|
| .claude/skills/booth/ | Product skill | Validate in-place |
| .claude/skills/deck/ | In-repo maintenance | Validate in-place |
| .claude/skills/formatter/ | Personal tool | Graduate → ~/skills/formatter/ |
| CLAUDE.md | Rules | Assess for conversion |
| .claude/rules/api.md | Rules (trigger-based) | Convert → rule-skill |

## Steps
- [ ] 1. Validate .claude/skills/booth/ (in-place)
- [ ] 2. Validate .claude/skills/deck/ (in-place)
- [ ] 3. Graduate .claude/skills/formatter/ → ~/skills/formatter/
- [ ] 4. Assess CLAUDE.md — always-on, no conversion
- [ ] 5. Convert .claude/rules/api.md → rule-skill

## Progress
Completed: 0 / 5
```

Update `- [ ]` to `- [x]` and increment `Completed` after each step. Delete the file when `Completed: N / N`.

## Rules Quality

Before deciding whether to convert a rules file, assess its quality. Poor-quality rules stay poor-quality after conversion — fix the content first.

**Quality signals to check for every rules file:**

| Issue | What it looks like | Fix |
|-------|-------------------|-----|
| **Vague constraint** | "write good code", "be careful" | Rewrite with specific, actionable criteria |
| **Missing scope** | No indication of when the rule applies | Add trigger: file type, task context, or user action |
| **Negation without alternative** | "don't do X" with no "do Y instead" | Add the positive case |
| **Multiple unrelated concerns** | One file covering 5 different domains | Split into separate rule files |
| **Stale reference** | Mentions outdated tools, APIs, or practices | Update or remove |
| **Redundant with platform defaults** | Re-states what the agent already does | Remove |
| **Contradicts another rule** | Two rules in the same project conflict | Resolve before continuing |

**Size signal:** a rules file over 100 lines is probably doing too much. Split by domain.

Report quality issues alongside the conversion assessment. Fix quality first, then decide on conversion.

## Rules Conversion

Rules files come in two kinds. **Do not treat them the same.**

### Always-On Rules

**Signals:** No `description` field, or `alwaysApply: true`, or loaded unconditionally by the platform.

**Do NOT convert to a skill.** Skills are semantically triggered — an always-on rule converted to a skill goes from "always active" to "only active when the description matches a user request." This is a regression in agent behavior. Always tell the user explicitly when a rule is being kept as-is and why.

**Action:** Validate format and content quality only. Keep as rule file.

### Trigger-Based Rules

**Signals:** Has a `description` field with trigger conditions, or activates on specific file/glob patterns.

**Can convert to a rule-skill.** The rule's `description` → skill's `description`. Full rule content → skill body.

**When to split into multiple rule-skills:**
- Conditions are unrelated (different domains, different contexts) → always split
- Conditions are related but too many to fit in a single description (~300 chars) → split by sub-cluster
- Rule body exceeds 500 lines after grouping → split

A skill's description is the trigger index. If the description needs to list 8 scenarios to cover all conditions, that's 8 separate skills, not one overloaded skill.

**Conversion steps:**
1. `Skill("rules-as-skills")` — owns the three-layer model and description format. Load before writing any rule-skill. If the skill does not load or returns no usable methodology, stop conversion and tell the user: "rules-as-skills is required for this step — run `npx skills add motiful/rules-as-skills -g` to install it."
2. Identify all trigger conditions in the rule file
3. Group related conditions into one skill; split unrelated ones into separate skills
4. Validate each resulting rule-skill through the standard Review flow (Step 3 → Fix → Local Ready)
5. Report to user: "Converted X trigger-based rules to Y rule-skills. Z always-on rules kept as-is — converting them would remove their unconditional activation."

**Effect risk is real.** Never silently convert. If unsure whether a rule is always-on or trigger-based, treat it as always-on and flag it for the user.

## Execution Order

Within a plan, execute in this priority:

1. **Security** — leaked secrets or credential files found during discovery (Critical, block everything else)
2. **In-repo maintenance skills** — validate in-place, fastest, no structural changes
3. **Personal tool graduation** — copy to `<skill_workspace>`, validate, register globally
4. **Product skill validation + reorganization** — may trigger collection or standalone repo decision, executes the structural changes
5. **Rules conversion** — after skills are settled; converts trigger-based rules, keeps always-on rules
6. **External skills** — inventory report only, no action taken

Within each category: Critical issues before Warnings. Items of the same type are processed in discovery order.
