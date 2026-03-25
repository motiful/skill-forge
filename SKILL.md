---
name: skill-forge
description: 'Create, validate, scan for security issues, and review skills as publishable GitHub repos. Structures workflow skills for execution fidelity. Use when the user says "create a skill", "forge a skill", "review this skill repo", "audit this skill", "audit all my skills", "audit this project", "clean up my skills", "check my skill", "publish this skill", "push this to GitHub", "structure my workflow skill", or points to a project directory with mixed skills and rules. Forge entry: discover existing → review path, nothing found → create path. Both → validate → fix → local ready. Publish to GitHub when requested (Step 4).'
license: MIT
metadata:
  author: motiful
  version: "8.0"
---

# Skill Forge

Skill engineering methodology and publishing pipeline. Defines what "well-engineered skill" means, validates skills against that standard, and produces publishable GitHub repos.

## Engagement Principles

These rules always apply. Read them before acting.

1. **Assess before acting** — first step is always understanding the situation (scan, inventory, read)
2. **Report before modifying** — show findings, get user approval, then act
3. **Security > Structure > Quality > Polish** — when multiple issues exist, fix in this priority
4. **Default to local-ready** — forge runs through validation and fixes until local-ready. User can stop at any point
5. **One skill at a time for changes** — diagnose in batch, modify one by one with user confirmation
6. **Local-ready = publish-ready** — publishing only sends to remote, never re-validates
7. **Understand context** — a skill may belong to a tool, or relate to other skills. Don't treat each in isolation
8. **Follow module interfaces** — when the procedure calls a reference file, read the file and follow its EP. The module's own EP is the authority, not any inline summary in the parent

## Execution Procedure

Follow the pseudocode step by step. At STEP 2, write a plan file with per-item checklists — this IS your execution checklist. Re-read the plan before each item to stay on track.

### Forge

**Trigger**: "review", "check", "audit", "audit this project", "audit all my skills", "clean up my skills", "create a skill", "forge a skill", "build a skill for X", "publish this skill", "push this to GitHub", "put this on GitHub"

```python
def forge(target):
    # STEP 0: Environment
    run("scripts/setup.sh")                            # exit non-zero → STOP
    config = read_or_create_config()                   # ~/.config/skill-forge/config.md
    if not config: assess_and_guide(target)            # references/onboarding.md

    # STEP 1: Assess
    items = discover(target)                           # traverse FULL project tree
    # Find: SKILL.md (any depth), rules files, project instructions, setup scripts
    # references/project-audit.md — discovery signals + classification framework

    if items:                                          # --- Review path ---
        classified = classify(items)                   # references/project-audit.md

    else:                                              # --- Create path ---
        context = detect_existing()                    # scan skills dirs + conversation
        if len(context) > 1: context = ask_user("Which existing skill?")
        elif not context: ask_user("What does this skill do? When should it trigger?")
        search_ecosystem(target)                       # npx skills find / skills.sh

        caps = detect_capabilities(context)            # not optional — detect and act
        if caps.deps:      install(caps.deps)          # references/installation.md
        if caps.invokes:   write_call_site(dep, loc)   # references/skill-invocation.md
        if caps.onboard:   assess_and_guide(scope)     # references/onboarding.md
        if caps.rules:     detect_and_create(skill_md) # references/rule-skill-pattern.md
        if caps.complex:   assess_and_create(repo)     # references/maintenance-guide.md
        if caps.config:    assess_config_needs(scope)    # references/skill-configuration.md
        if caps.workflow:  assess_procedure_need(md)    # references/execution-procedure.md

        path = f"{config.skill_workspace}/{name}/"
        write_skill_md(path, context, caps)            # references/skill-format.md
        Skill("readme-craft", f"create {path}")        # references/templates.md for skeletons
        write_artifacts(path)                          # LICENSE, .gitignore
        items = [SkillItem(path)]

    # STEP 2: Plan — GATE: file must exist before Step 3
    plan_path = f"/tmp/skill-forge-{name}.md"
    delete_if_exists(plan_path)                        # always fresh, no resume between runs
    write_plan(plan_path, items)                       # use Bash if Write tool requires Read
    assert file_exists(plan_path)
    # Plan template with per-item sub-steps: references/project-audit.md
    # review_and_update_plan between major steps: references/execution-procedure.md

    # STEP 3: Validate & Fix
    plan.items.sort(priority="security > in-repo > personal > product > rules")
    for item in plan.items:

        # Scan project-specific standards (CLAUDE.md, AGENTS.md, linter configs, rules/)
        if security_scan(item).has_critical: report_and_block()  # see Security section
        findings = validate(item)                      # see Validation section
        report_to_user(findings)                       # findings grouped by category

        fix_critical(findings)                         # mandatory
        if user_approves: fix_warnings(findings)
        assert review_and_update_plan(plan_path, item, "validated")

        # REQUIRED — use Skill tool, do not substitute with manual action
        # Skip readme-craft/self-review for in-repo items with no independent README/repo
        if not item.is_in_repo:
            Skill("readme-craft", f"review {item.path}")   # see Fix Phase
            assert review_and_update_plan(plan_path, item, "readme-craft")

            Skill("self-review", item.path)                # see Fix Phase
            assert review_and_update_plan(plan_path, item, "self-review")

        conflicts = audit_registrations(item, config)    # references/registration-audit.md
        if conflicts.critical: resolve_or_block()        # HITL
        detect_and_register(item)                        # references/platform-registry.md
        if not item.has_git: git_init(item)
        assert local_ready(item)                       # see Local Ready Definition
        review_and_update_plan(plan_path, item, "done")

    # STEP 4: Publish (optional — only when trigger includes publish intent)
    # Triggers: "publish this skill", "push this to GitHub", "put this on GitHub"
    if publish_requested:
        confirm_with_user(org=config.github_org, name=skill_name, visibility="public")
        run(f"gh repo create {org}/{name} --public --source=. --push")
        # Non-GitHub: git remote add origin <url> && git push -u origin main
        validate_and_apply(skill_path)                 # references/github-metadata.md
        update_forge_config(skill_name)                # add to Published Skills
        # CC Market: check cc_market in config. Not set? → ask, recommend skip
        print(f"Install with: npx skills add {org}/{name}")
```

### Parallel Execution

If your platform supports sub-agents (e.g., Claude Code `Agent` tool): setup.sh and discovery can run in parallel; independent items can validate in parallel; readme-craft then self-review are sequential.

## Security

Pre-flight gate. If Critical findings → block push, stop validation.

| Check | Criteria |
|-------|----------|
| Leaked secrets | Scan for: API keys (`sk-`, `ghp_`, `AKIA`, `xox[bpas]-`), tokens, passwords, private keys (`-----BEGIN.*PRIVATE KEY-----`). **Critical — block push** |
| Credential files | `.env`, `credentials.json`, `*.pem`, `*.key` tracked → **Critical** |
| .gitignore coverage | `.env*`, `node_modules/`, `.DS_Store`, IDE configs, OS files → Warning |

## Validation

One pass, read every file, check everything. Each finding tagged by category. Before running, scan the project for its own quality standards (`CLAUDE.md`, `AGENTS.md`, `.editorconfig`, rules directories) — these add to the checks below. Break per-file review into plan sub-tasks; use sub-agents for parallelism.

**Severity**: Critical = must fix. Warning = user confirms. Info = report only.
**Fix priority**: Structure first (reorganize), Quality second (improve content), Publishing last (polish).

### Structure

Organization, layout, file existence, dependencies.

| Check | Criteria |
|-------|----------|
| Frontmatter fields | Standard top-level fields only: `name`, `description`, `license`, `metadata`, `compatibility`, `allowed-tools`. CC-specific inside `metadata` |
| `name` | kebab-case, max 64 chars, lowercase alphanumeric + hyphens. No start/end hyphen, no `--`, must match parent directory name |
| `description` format | Present, < 1024 chars, **single-line** (YAML multi-line `>-`/`|` causes silent disappear in CC). If contains `: ` → must be quoted |
| Body | Under 500 lines, meaningful content (not just TODOs) |
| References exist | All SKILL.md references resolve. Orphan files → Warning |
| Dependencies | `scripts/setup.sh` exists and handles each declared dependency |
| Directory names | Standard: `references/`, `assets/`, `scripts/`. Non-standard referenced by SKILL.md → Warning |
| No junk files | Correct structure for single-skill / multi-skill repos |
| Assets location | AI-consumed source material only. Logo, screenshots → `.github/` |
| Runtime write | No data/, cache/ in skill directory |
| Meta-skill contamination | No forge/creator as subdirectories |
| Collection risks | `decide(skill_count, usage_pattern)` — `references/skill-composition.md`. 15+ skills → context flooding warning; generic names → namespacing warning |
| Registration conflicts | `audit_registrations(item, config)` — `references/registration-audit.md`. Workspace shadows global → Warning; same name different source → Critical |

### Quality

SKILL.md + references + scripts + assets reviewed as **one unit**. Read SKILL.md first, follow module references, check coherence across all files.

Shared checks (SKILL.md and every reference file):
- Three-layer format + Positional Test + EP-Content alignment → `validate_format()` + `review_reference()` — `references/skill-format.md`
- EP comment discipline — `references/execution-procedure.md` §5
- Terminology consistency across all files

| Check | Criteria |
|-------|----------|
| Description coverage | Description mentions key trigger scenarios from body. Gaps → Warning. Over-promises → Warning |
| Description clarity | Standalone comprehensible to a stranger |
| Invocation reliability | `validate_invocations(skill_md, deps)` — `references/skill-invocation.md` |
| Graceful skip | `audit_conditional_branches(skill_md)` — `references/anti-graceful-skip.md` |
| Execution Procedure | `assess_procedure_need(skill_md)` — `references/execution-procedure.md` |
| Entry complexity | Multiple modes must produce different deliverables |
| Script quality | `validate_script()` + `review_script()` — `references/script-quality.md` |
| In-repo skills | Apply full validation recursively. Cross-vendor symlinks use relative paths |
| Standard enforcement | Every reference file with an EP must have at least one invocation point in SKILL.md (EP pseudocode or Validation table). Listed in References section but never invoked → Warning: standard exists but isn't enforced |
| Assets referenced | Every asset file referenced by SKILL.md or references. Unreferenced → Warning |

### Publishing

External-facing presentation and packaging.

| Check | Criteria |
|-------|----------|
| README quality | Deferred to Fix Phase (readme-craft). Flag only obvious issues. Full: `validate_readme()` — `references/readme-quality.md` |
| Dependency mirroring | SKILL.md dependencies mirrored in README "Dependencies" section |
| Install command | Primary: `npx skills add <org>/<repo>`. Manual clone as fallback |
| No hardcoded paths | No personal paths (~/ expanded, /Users/specific/) in published files |
| LICENSE exists | Required for community platforms |
| Script documentation | If scripts exist, document what they do and permissions needed |
| Discoverability claims | No implied guarantees of immediate listing or search placement |
| GitHub metadata | `validate_and_apply(skill_path)` — `references/github-metadata.md` |
| docs/*.md | Accuracy vs SKILL.md claims, no stale content, no contradictions |
| Unnecessary files | Lock files without runtime, > 1MB media, build artifacts, IDE workspace files → Warning |
| `LICENSE`, `.gitignore` | Existence + content matches expected template |

## Fix Phase

After validation report is presented and user approves fixes:

1. Fix all Critical issues (mandatory)
2. Fix Warning issues (with user confirmation)
3. **README** — REQUIRED skill invocation:

   Run: `Skill("readme-craft", "review <path>")`
   Do not substitute with manual README review.
   readme-craft owns universal README quality. skill-forge owns skill-specific standards (`references/readme-quality.md`). Both apply, domain wins.

   If README does not exist, readme-craft will create it. After readme-craft completes,
   check skill-specific standards from `references/readme-quality.md` and fix any gaps.

4. Create missing repo artifacts (LICENSE, .gitignore) if they don't exist
5. Update remaining artifacts to pass validation
6. **Local registration** — detect platform roots, create symlinks:

   See `references/platform-registry.md` for the full path matrix.
   Paths found → symlink all. No paths → skip. User names undetected platform → create + link.
   Never link one vendor path to another. Every consumer path points to the skill's source directory.
   **In-repo skills**: cross-vendor symlinks like `.agents/skills/X → ../../.claude/skills/X` must use relative paths.

7. **Git init** (if not already a git repo) + initial commit
8. **Final quality review** — REQUIRED skill invocation:

   Run: `Skill("self-review", "<skill-path>")`
   Do not substitute with manual quality check.
   Do not declare local ready if self-review reports Broken dimensions.

9. Verify all Local Ready criteria are met

## Local Ready Definition

A skill is "local ready" when ALL of the following are true:

```
<skill-name>/
├── SKILL.md                           # validated (Step 3 passed)
├── references/                        # if needed, all links resolve
├── scripts/                           # if needed, setup.sh works
├── README.md                          # audited by readme-craft
├── LICENSE                            # exists
└── .gitignore                         # matches template
```

- `git init` done, initial commit made
- Local registration (symlinks) done for all detected platform roots
- All Critical and Warning issues resolved
- README audited by readme-craft (not just manually checked)

**Local ready = publish-ready.** The only remaining action is Step 4 (publish to remote).

## Publish to Remote

Step 4 of forge. Only runs when the trigger includes publish intent. Requires local ready.

1. **Confirm** — remote target (`<org>/<skill-name>`, visibility), local ready status

2. **Execute**:

   ```bash
   # Push to GitHub (default)
   gh repo create <org>/<skill-name> --public --source=. --push

   # Non-GitHub: ask for remote URL
   git remote add origin <url> && git push -u origin main
   ```

3. **Update config** — add to `~/.config/skill-forge/config.md` "Published Skills"

4. **Report**: *"Your skill is on GitHub. Install with `npx skills add <org>/<skill-name>`."*

**CC Market**: check `cc_market` in forge config. `true` → include. `false` → skip. Not set → ask once, recommend skip. See `references/platform-registry.md`.

## References

- `references/installation.md` — setup.sh standard: dependency detection, installation, two outcomes
- `references/skill-invocation.md` — Runtime invocation reliability: explicit `Skill(...)` call + output gate pattern
- `references/onboarding.md` — Interactive first-use guidance pattern
- `references/skill-configuration.md` — User preferences, config location, litmus test, stateless principle
- `references/skill-format.md` — Format specification for SKILL.md and reference files (frontmatter, Execution Procedure, content alignment, positional test)
- `references/skill-composition.md` — Composition philosophy: context budget, dependency tiers
- `references/rule-skill-pattern.md` — Forge integration: detection, auto-creation, and packaging of rule-skills
- `references/publishing-strategy.md` — Skill vs Collection publishing models
- `references/platform-registry.md` — Platform skill paths, detection logic, community directories
- `references/templates.md` — README, LICENSE, and .gitignore skeletons
- `references/readme-quality.md` — README writing, claim discipline, example rules
- `references/script-quality.md` — Script size limits, module split triggers, dependency policy
- `references/maintenance-guide.md` — In-repo maintenance-rules skill: when to create, required content, template
- `references/anti-graceful-skip.md` — Default-execute principle, skip conditions, no-downside enhancements, Step 3 audit criteria
- `references/execution-procedure.md` — Pseudocode + plan-as-checklist + GATE pattern for workflow skills
- `references/project-audit.md` — Discovery, Classification, Plan File, Rules Conversion, Execution Order for project-level forge
- `references/github-metadata.md` — About/description rules, topic 3-tier selection, .github/repo-meta.yml format
- `references/registration-audit.md` — Pre-registration conflict detection: workspace shadows global, broken links, copy vs symlink
