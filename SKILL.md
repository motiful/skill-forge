---
name: skill-forge
description: 'Create, validate, scan for security issues, and review skills as publishable GitHub repos. Structures workflow skills for execution fidelity. Use when the user says "create a skill", "forge a skill", "review this skill repo", "audit this skill", "audit all my skills", "audit this project", "clean up my skills", "check my skill", "publish this skill", "push this to GitHub", "structure my workflow skill", or points to a project directory with mixed skills and rules. Forge entry: discover existing → review path, nothing found → create path. Both → validate → fix → local ready. Publish to GitHub when requested (Step 4).'
license: MIT
metadata:
  author: motiful
  version: "7.2"
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

## Execution Procedure

Follow the pseudocode step by step. At STEP 2, write a plan file with per-item checklists — this IS your execution checklist. Re-read the plan before each item to stay on track.

### Forge

**Trigger**: "review", "check", "audit", "audit this project", "audit all my skills", "clean up my skills", "create a skill", "forge a skill", "build a skill for X", "publish this skill", "push this to GitHub", "put this on GitHub"

```python
def forge(target):
    # STEP 0: Environment
    run("scripts/setup.sh")                            # exit non-zero → STOP
    config = read_or_create_config()                   # ~/.config/skill-forge/config.md
    # First use? Onboard: detect github_org, ask skill_workspace, write config
    # references/onboarding.md — ask workspace path, don't assume default
    # Scan user conventions: forge config → CLAUDE.md/AGENTS.md → platform rules
    # Follow user's conventions; provide defaults only if none exist
    # Positioning: skill-forge creates independent, publishable repos
    # User wants quick project-internal skill? → guide to platform's built-in creator

    # STEP 1: Assess
    items = discover(target)                           # traverse FULL project tree
    # Find: SKILL.md (any depth), rules files, project instructions, setup scripts
    # references/project-audit.md — discovery signals + classification framework

    if items:                                          # --- Review path ---
        classified = classify(items)
        # in-repo    → validate in-place, relative cross-vendor symlinks
        # product    → validate + check distribution structure
        # personal   → proactive graduation to skill_workspace (don't ask, just do)
        # external   → inventory only, do not touch
        # rules      → always-on: keep as-is. trigger-based: convert to rule-skill
        # Ambiguous? → ask user once with your reasoning

    else:                                              # --- Create path ---
        context = detect_existing()
        # Scan: .claude/skills/*/SKILL.md, skill/SKILL.md, skill_workspace/*/SKILL.md
        # Also: conversation context, explicit user references
        # One match → proceed. Multiple → ask. None → ask user:
        if not context:
            ask_user("What does this skill do? When should it trigger?")
        search_ecosystem(target)                       # npx skills find / skills.sh
        # Good match? → depend on it (setup.sh). Partial? → fork. None? → create
        capabilities = detect_capabilities(context)    # not optional — detect and act
        # dependencies?    → add setup.sh              (references/installation.md)
        # invokes skills?  → Skill() pattern           (references/skill-invocation.md)
        # onboarding?      → first-use flow            (references/onboarding.md)
        # 3+ MUST/NEVER?   → auto-create rule-skill    (references/rule-skill-pattern.md)
        # >300 lines/3+ deps? → maintenance-rules      (references/maintenance-guide.md)
        # multi-step workflow? → Execution Procedure    (references/execution-procedure.md)
        # Rule-Skill Split is detection-driven: if detected, create automatically
        # Location: existing path → in-place. New → skill_workspace/<name>/
        # One skill → SKILL.md at root. Coupled set → references/publishing-strategy.md
        path = f"{config.skill_workspace}/{name}/"
        write_skill_md(path, context, capabilities)    # references/skill-format.md
        # Write for AI agents, not humans. Body < 500 lines. Bake capabilities in:
        # Installation → setup.sh + Step 0. Invocation → explicit Skill() at every call site.
        # Onboarding → first-use guidance. Rule-Skill → Skill("rules-as-skills") + paired skill.
        # Maintenance → in-repo .claude/skills/maintenance-rules/ + cross-vendor symlink.
        # Workflow → Execution Procedure pseudocode + plan-as-checklist + GATE assertions.
        write_artifacts(path)                          # README, LICENSE, .gitignore
        # README via Skill("readme-craft"). Templates: references/templates.md
        items = [SkillItem(path)]

    # STEP 2: Plan — GATE: file must exist before Step 3
    plan_path = f"/tmp/skill-forge-{name}.md"
    delete_if_exists(plan_path)                        # always fresh, no resume between runs
    write_plan(plan_path, items)                       # use Bash if Write tool requires Read
    assert file_exists(plan_path)
    # Plan = instantiated procedure with per-item SUB-STEPS:
    #   - [ ] 1. Validate X
    #     - [ ] Core Validation + Repo Hygiene
    #     - [ ] Fix Critical/Warning
    #     - [ ] Skill("readme-craft")
    #     - [ ] Skill("self-review")
    #     - [ ] Local Ready
    # Full template: references/project-audit.md
    # This plan IS your checklist. Re-read it before each item.

    # STEP 3: Validate & Fix
    # Priority: security > in-repo > personal > product > rules
    for item in plan.items:
        review_plan(plan_path)                         # re-read plan, check progress

        # Scan project-specific standards (CLAUDE.md, AGENTS.md, linter configs, rules/)
        # → additional checks on top of Core Validation
        findings = core_validate(item)                 # see Core Validation section
        findings += content_review(item)               # see Content Review section — read EVERY file
        findings += repo_hygiene(item)                 # see Repo Hygiene section
        report_to_user(findings)
        # Severity: Critical = must fix. Warning = user confirms. Info = report only

        fix_critical(findings)                         # mandatory
        if user_approves: fix_warnings(findings)

        # REQUIRED — use Skill tool, do not substitute with manual action
        # Skip readme-craft/self-review for in-repo items with no independent README/repo
        if not item.is_in_repo:
            Skill("readme-craft", f"review {item.path}")   # see Fix Phase
            Skill("self-review", item.path)                # see Fix Phase

        register_locally(item)                         # references/platform-registry.md
        if not item.has_git: git_init(item)
        assert local_ready(item)                       # see Local Ready Definition
        update_plan(plan_path, item, "done")

    close_plan(plan_path)

    # STEP 4: Publish (optional — only when trigger includes publish intent)
    # Triggers: "publish this skill", "push this to GitHub", "put this on GitHub"
    if publish_requested:
        confirm_with_user(org=config.github_org, name=skill_name, visibility="public")
        run(f"gh repo create {org}/{name} --public --source=. --push")
        # Non-GitHub: git remote add origin <url> && git push -u origin main
        meta = read_repo_meta(skill_path)              # references/github-metadata.md
        assert meta.description and len(meta.description) <= 350
        assert 8 <= len(meta.topics) <= 20
        apply_github_metadata(org, name, meta)         # gh repo edit
        update_forge_config(skill_name)                # add to Published Skills
        # CC Market: check cc_market in config. Not set? → ask, recommend skip
        print(f"Install with: npx skills add {org}/{name}")
```

### Parallel Execution

If your platform supports sub-agents (e.g., Claude Code `Agent` tool): setup.sh and discovery can run in parallel; independent items can validate in parallel; readme-craft then self-review are sequential.

## Core Validation

Before running checks, scan the target project for its own quality standards (`CLAUDE.md`, `AGENTS.md`, `.editorconfig`, rules directories). These become additional criteria on top of the table below. Report violations attributed to the project's own standard.

| Check | Criteria |
|-------|----------|
| Frontmatter fields | Only standard top-level fields: `name`, `description`, `license`, `metadata`, `compatibility`, `allowed-tools`. Put CC-specific or custom fields inside `metadata` |
| `name` | kebab-case, max 64 chars, lowercase alphanumeric + hyphens. Must not start/end with hyphen, no consecutive hyphens (`--`), must match parent directory name |
| `description` | Present, < 1024 chars, **single-line** (no YAML multi-line `>-` or `|` — causes skills to silently disappear in CC). If value contains `: ` (colon-space), must be quoted — strict YAML parsers (e.g. Codex) will reject unquoted colons as mapping indicators |
| Description coverage | Does the description mention the key trigger scenarios from the SKILL.md body? For each major capability or workflow in the body, check if the description includes a corresponding trigger phrase. Report gaps as warnings. Report description claims absent from body as over-promises |
| Body | Under 500 lines, has meaningful content (not just TODOs) |
| References exist | All files referenced in SKILL.md actually exist. Orphan files (in references/ but not referenced) → Warning |
| No junk files | For multi-skill repos: no README.md, CHANGELOG.md, or docs inside `skills/<name>/`. For single-skill repos: SKILL.md, references/, assets/, scripts/ at root alongside README.md and LICENSE is the expected structure |
| Dependencies | If the skill declares dependencies, verify `scripts/setup.sh` exists and handles each one. Dependencies must be installed, not optional |
| Invocation reliability | For each skill dependency: does every invocation point use explicit `Skill(...)` syntax + output gate? Natural-language invocations ("invoke X", "run X") are flagged. See `references/skill-invocation.md` |
| Runtime write | Skill directory should have no runtime-written data files. Flag data/, cache/, or any non-published file |
| Assets misuse | `assets/` only holds AI-consumed source material. Logo, screenshots, repo infrastructure belong in `.github/` or root level |
| Meta-skill contamination | Skill repo should not contain tooling skills (skill-forge, skill-creator) as subdirectories. Remediation: `rm -rf <path>` then `npx skills add <org>/<name> -g` |
| Collection context budget | For multi-skill repos: 15+ skills → warn about context flooding. Recommend selective install (`--skill`) in README |
| Collection name collision | For multi-skill repos: flag generic names likely to collide. Recommend namespacing (`<domain>-<name>`) |
| Terminology consistency | Extract core terms. Check for: conflicts with skill name, different meanings across sections, conflicts with platform concepts. Report — don't auto-fix |
| Directory names | Standard: `references/`, `assets/`, `scripts/`. Non-standard dirs referenced by SKILL.md → Warning. Not referenced → not skill content, don't flag |
| Script quality | No file >500 lines; CLI parsing separated from business logic. See `references/script-quality.md` |
| README quality | Deferred to Fix Phase. Flag only obvious issues (missing file, stale content). Full assessment after readme-craft, combined with `references/readme-quality.md` |
| Install command | Primary: `npx skills add <org>/<repo>`. Manual clone as fallback only |
| Dependency mirroring | If SKILL.md declares dependencies, mirror them in README "Dependencies" section |
| No hardcoded paths | No personal paths (~/ expanded, /Users/specific/) in published files |
| LICENSE exists | Required for community platforms |
| Description clarity | Description alone should tell a stranger what this skill does and when to use it |
| Script documentation | If scripts exist, document what they do and what permissions they need |
| Discoverability claims | Do not imply GitHub publication guarantees immediate listing or search placement |
| Graceful skip | Conditional branches must have actions on both sides. Flag "if applicable" / "optionally" / "if exists" that suppress capabilities. See `references/anti-graceful-skip.md` |
| Entry complexity | Multiple modes must produce different deliverables or follow different core workflows. Flag capability gaps between modes |
| Execution Procedure | Workflow skills (ordered multi-step flow with dependencies between steps) without pseudocode Execution Procedure → Warning. See `references/execution-procedure.md` |
| Reference format | Reference files follow three-layer format: frontmatter (name, description) + Execution Procedure (pseudocode with input/output signature) + Content. EP ↔ Content aligned. See `references/skill-format.md` |
| GitHub metadata | `.github/repo-meta.yml` exists. Description ≤ 350 chars, aligns with README one-liner and SKILL.md description. Topics cover 3 tiers (Tier 1 universal, Tier 2 domain-researched, Tier 3 platform). See `references/github-metadata.md` |

## Content Review

Read **every file** in the skill repo. A skill is a codebase — validating SKILL.md alone is like reviewing main.py and assuming utils.py is fine. Break per-file review into plan sub-tasks; use sub-agents for parallelism.

| File type | What to check |
|-----------|---------------|
| `references/*.md` | **Three-Layer Format**: frontmatter present (name, description), Execution Procedure present (pseudocode with input/output signature), Content sections map to EP lines. **Positional Test**: each content block must serve a specific EP line — HITL context stays, calibrating context stays, homeless content → docs/README. Also: terminology consistent with SKILL.md, cross-references resolve, no hardcoded paths, line count reasonable |
| `scripts/*.sh` | Read and understand. Does it do what SKILL.md claims? Functional correctness, no dead code, no hardcoded paths, error handling for both outcomes (success/failure). See `references/script-quality.md` |
| `docs/*.md` | For humans, so Positional Test does not apply. Check: accuracy vs SKILL.md claims, no stale content, no contradictions with current version |
| `.claude/skills/**/SKILL.md` | In-repo skills: apply Core Validation recursively (frontmatter, description, body, terminology). Cross-vendor symlinks use relative paths |
| `assets/` | Every file is referenced by SKILL.md or references/. Unreferenced assets → Warning. AI-consumed source material only |
| `README.md` | Deferred to Fix Phase (readme-craft). Flag only obvious issues here |
| `LICENSE`, `.gitignore` | Existence + content matches expected template |

**Severity**: Positional Test violations (homeless content) in references/ → Warning. Stale or contradictory docs/ → Warning. Script functional issues → Critical.

## Repo Hygiene

| Check | Criteria |
|-------|----------|
| Leaked secrets | Scan for: API keys (`sk-`, `ghp_`, `AKIA`, `xox[bpas]-`), tokens, passwords, private keys (`-----BEGIN.*PRIVATE KEY-----`). **Block push** until resolved |
| .gitignore coverage | Verify: `.env*`, `node_modules/`, `.DS_Store`, IDE configs, OS files. Flag tracked files matching these patterns |
| Credential files | Warn if `.env`, `credentials.json`, `*.pem`, `*.key` are tracked |
| Unnecessary files | Lock files without `scripts/` runtime, large media (>1 MB), build artifacts, IDE workspace files |

**Severity**: Critical (secrets, credentials) — block push. Warning (gitignore, unnecessary files) — recommend, don't block.

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
