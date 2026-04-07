---
name: skill-forge
description: 'Validate, fix, and publish skills as GitHub repos. Structures workflow skills for execution fidelity. Registers skills across platforms via symlinks and guides first-use onboarding. Use when the user says "create a skill", "forge a skill", "review this skill repo", "audit this skill", "audit all my skills", "audit this project", "clean up my skills", "check my skill", "publish this skill", "push this to GitHub", "structure my workflow skill", or points to a project directory with mixed skills and rules. Forge: discover → classify → validate → fix → local ready. Nothing found → onboard user, scaffold, then same pipeline. Publish to GitHub when requested (Step 4).'
license: MIT
metadata:
  author: motiful
  version: "9.0"
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
9. **Report what you can't resolve** — severity follows the check's own criteria, not assumed user preference. A finding explained by another explicit rule is resolved, not a discrepancy — dismiss it with the reason

## Execution Procedure

Follow the pseudocode step by step. At STEP 2, write a plan file with per-item checklists — this IS your execution checklist. Re-read the plan before each item to stay on track.

### Forge

**Trigger**: "review", "check", "audit", "audit this project", "audit all my skills", "clean up my skills", "create a skill", "forge a skill", "build a skill for X", "publish this skill", "push this to GitHub", "put this on GitHub"

```python
def forge(target):
    # STEP 0: Environment
    run("scripts/setup.sh")                            # exit non-zero → STOP
    config = assess_config_needs()                     # references/skill-configuration.md
    if not config: assess_and_guide(target)            # references/onboarding.md

    # STEP 1: Discover — paths and classification ONLY
    classified = discover_and_classify(target)         # references/project-audit.md
    # Find: SKILL.md (any depth), rules files, project instructions, setup scripts
    #
    # BOUNDARY: Discovery reads file PATHS and FRONTMATTER (for classification).
    # Discovery also reads project standards (CLAUDE.md, AGENTS.md) — shared context.
    # Discovery does NOT read: SKILL.md body, reference file content.
    # Discovery does NOT validate: quality, structure, reference integrity.
    # Discovery does NOT check git log, git diff, or previous review reports.
    # Every review is a FULL review — no incremental/delta mode, no "nothing changed
    # since last review" shortcuts. Prior results do not reduce current scope.
    # Content reading and validation happen in STEP 3, driven by the plan.
    # If you finish STEP 1 having already validated content → you collapsed the loop.

    if classified:                                     # --- Existing items ---

    else:                                              # --- Nothing found ---
        context = detect_existing()                    # scan skills dirs + conversation
        if len(context) > 1: context = ask_user("Which existing skill?")
        elif not context: ask_user("What does this skill do? When should it trigger?")
        search_ecosystem(target)                       # npx skills find / skills.sh

        # Workspace: standalone + design-heavy → full workspace with backstage
        # Signals: public/publishable, 3+ expected references, multi-session,
        #   user mentioned design docs. Rule-skill/in-repo/prototype → skip.
        if assess_workspace_need(name, context):       # HITL — user confirms
            Skill("repo-scaffold", f"scaffold {name}, git init but skip push")
            path = f"{config.skill_workspace}/{name}-project/{name}/"
        else:
            path = f"{config.skill_workspace}/{name}/"

        source_docs = detect_source_documents(context) # backstage, research, outputs
        scaffold_skill_md(path, context)                # follows references/skill-format.md standards
        ep_contract = extract_ep_signatures(path)      # function calls in SKILL.md EP

        if source_docs:
            transform_references(source_docs, ep_contract)
        else:
            write_references(path, ep_contract)

        assert all_ep_calls_have_matching_defs(path)   # GATE

        readme = Skill("readme-craft", f"create {path}")  # references/templates.md
        assert readme.delivered                        # README required for local ready
        write_artifacts(path)                          # LICENSE, .gitignore — skip if exist
        items = [SkillItem(path)]

    # From here: all items — new or existing — go through the same pipeline.
    # Capability detection is NOT a separate step. Each reference module defines
    # its own applicability criteria. The validation tables cover every reference.
    # No explicit caps.X enumeration — all references are checked uniformly.

    # STEP 2: Plan — GATE: file must exist AND be per-item structured before Step 3
    plan_path = f"/tmp/skill-forge-{name}.md"
    delete_if_exists(plan_path)                        # always fresh, no resume between runs

    # Plan MUST be organized per-item, NOT per-check-type.
    # Each discovered item gets its own top-level checklist entry with sub-steps.
    # Step 3 iterates this plan item by item — no plan means no loop.
    #
    # Plan structure (every plan follows this, no exceptions):
    #
    #   ## Steps
    #   - [ ] 1. Validate <item-path>
    #     - [ ] Security scan
    #     - [ ] Validate (all table rows)
    #   - [ ] 2. Validate <item-path>
    #     - [ ] ...
    #   ## Findings                                     # appended by STEP 3b
    #   ### <skill-name>
    #   - [ ] must-fix | check | file | description
    #   - [ ] suggestion | check | file | description
    #   ## Progress
    #   Completed: 0 / N
    #
    # STEP 3a checks off validation steps. STEP 3b appends ## Findings.
    # STEP 3c reads ## Findings, fixes [ ] rows, marks [x].
    # STEP 3d runs readme-craft + self-review on TARGET root (not per-item).

    write_plan(plan_path, items)                       # use Bash if Write tool requires Read
    assert file_exists(plan_path)
    assert plan.is_per_item_structured                 # GATE: each item = top-level entry + sub-steps
    assert plan.top_level_step_count >= len(items)     # GATE: count top-level entries ≥ discovered items
    # ↑ If the plan batched N items into fewer entries, this fails. Rewrite: one entry per item.
    # review_and_update_plan between major steps: references/execution-procedure.md

    # STEP 3a: Validate — in batches of up to 5, one agent per item
    plan.items.sort(priority="security > in-repo > personal > product > rules")
    findings_dir = f"/tmp/skill-forge-findings-{name}/"
    rm_rf(findings_dir)                                # clean stale results from prior runs
    mkdir(findings_dir)

    for batch in chunk(plan.items, 5):                 # at most 5 at a time
        agents = []
        for item in batch:
            findings_path = f"{findings_dir}/{item.name}.md"
            agents.append(Agent(
                f"Validate ONE skill: {item.path}. "
                f"Read the Security/Structure/Quality/Publishing validation tables "
                f"in {skill_forge_skill_md}, then read {item.skill_md} and EVERY "
                f"file under {item.path}/references/. "
                f"Check every row in the validation tables against SKILL.md and each reference file. "
                f"Write one row per check to {findings_path}: "
                f"'- PASS | check | file | description' or "
                f"'- [ ] must-fix/suggestion | check | file | description'. "
                f"Do NOT skip rows. Do NOT fix. Write to file only."
            ))
        run_parallel(agents)                           # launch this batch
        # WAIT for batch to complete. Do NOT launch next batch until all findings
        # files in this batch exist and pass the coverage assert.
        for item in batch:                             # collect before next batch
            findings_path = f"{findings_dir}/{item.name}.md"
            assert file_exists(findings_path)          # agent must have written findings
            findings = read(findings_path)
            assert row_count(findings) >= len(VALIDATION_TABLE_ROWS)
            review_and_update_plan(plan_path, item, "validated")

    # STEP 3b: Aggregate + report (Observe-Then-Act Phase B — references/execution-procedure.md §10)
    # 1. Extract [ ] rows from {findings_dir}/*.md, append as ## Findings to {plan_path}
    # 2. Cross-item analysis: identify systemic patterns across finding files
    # 3. Report plan path + patterns to user
    aggregate_and_append(findings_dir, plan_path)      # [ ] rows → ## Findings in plan
    patterns = cross_item_analysis(findings_dir)       # §10 Phase B: full-picture patterns
    report_to_user(plan_path, patterns)

    # STEP 3c: Fix — ## Findings in plan file is the todo list.
    # Each [ ] row = one fix. Mark [x] when done.
    fix_findings(plan_path)
    assert no_unchecked_must_fix(plan_path)

    # STEP 3d: Target-level quality gates — run on TARGET root, not per-item
    # These apply whether target is a standalone skill or a collection.
    rc_result = Skill("readme-craft", f"review {target}")  # REQUIRED — use Skill tool
    assert rc_result.delivered
    sr_result = Skill("self-review", target)               # REQUIRED — use Skill tool
    assert sr_result.no_broken_dimensions

    # Registration + git
    conflicts = audit_registrations(target, config)    # references/registration-audit.md
    if conflicts.critical: resolve_or_block()          # HITL
    detect_and_register(target)                        # references/platform-registry.md
    if not target.has_git: git_init(target)
    assert local_ready(target)                         # see Local Ready Definition

    # STEP 4: Publish (optional — only when trigger includes publish intent)
    # Triggers: "publish this skill", "push this to GitHub", "put this on GitHub"
    if publish_requested:
        confirm_with_user(org=config.github_org, name=skill_name, visibility="public")
        run(f"gh repo create {org}/{name} --public --source=. --push")
        # Non-GitHub: git remote add origin <url> && git push -u origin main
        # GitHub metadata (description + topics) already applied by readme-craft Step 7
        update_forge_config(skill_name)                # add to Published Skills
        assess_cc_market(config)                       # references/platform-registry.md
        print(f"Install with: npx skills add {org}/{name}")
```

### Parallel Execution

If your platform supports sub-agents (e.g., Claude Code `Agent` tool): setup.sh and discovery can run in parallel; independent items can validate in parallel; readme-craft then self-review are sequential.

**One agent per item.** Each Step 3 validation agent handles exactly one discovered item — do not batch multiple items into a single agent. This ensures each item gets isolated context and full validation depth. Launch all item agents in parallel.

## Security

Pre-flight gate. If must-fix findings → block push, stop validation.

| Check | Criteria |
|-------|----------|
| Leaked secrets | Scan for: API keys (`sk-`, `ghp_`, `AKIA`, `xox[bpas]-`), tokens, passwords, private keys (`-----BEGIN.*PRIVATE KEY-----`). **Fix — block push** |
| Credential files | `.env`, `credentials.json`, `*.pem`, `*.key` tracked → **Fix** |
| .gitignore coverage | `.env*`, `node_modules/`, `.DS_Store`, IDE configs, OS files |

## Validation

One pass, read every file, check everything. Each finding tagged by category. Before running, scan the project for its own quality standards (`CLAUDE.md`, `AGENTS.md`, `.editorconfig`, rules directories) — these add to the checks below. Break per-file review into plan sub-tasks; use sub-agents for parallelism.

**Result types** — every validation table row produces exactly one result:
- **PASS**: Meets the standard. Brief note on what was checked. Required for coverage proof.
- **Must fix**: Deviates from standard with concrete risk. State what the standard says, what was found, and what goes wrong for users.
- **Suggestion**: A better mechanism exists that would unlock higher capability. Describe the upgrade path and benefit. User decides.

No other result types. If it's not PASS, must-fix, or suggestion — it's PASS.

For each finding, explain the user impact — not which rule was violated. Standards are defined in the reference files; the validation tables below point to them. Each table row referencing a file constitutes the EP dispatch — the agent reads the reference's EP when evaluating that check (per batch principle, `references/execution-procedure.md` §7).

### Structure

Organization, layout, file existence, dependencies.

| Check | Standard |
|-------|---------|
| Frontmatter fields | `references/skill-format.md` §Standard Frontmatter |
| `name` | `references/skill-format.md` §Standard Frontmatter — kebab-case, matches directory |
| `description` format | `references/skill-format.md` §Standard Frontmatter — single-line, < 1024 chars |
| Body size | `references/skill-format.md` §Body — under 500 lines |
| References exist | All SKILL.md references resolve, no orphans |
| Reference file frontmatter | Each .md in references/ must have `--- name + description ---` per `references/skill-format.md` §Reference Frontmatter |
| Reference file size | Each reference file under 300 lines per `references/reference-extraction.md`; over 300 = must split |
| Dependencies | `references/installation.md` — setup.sh handles each declared dependency |
| Directory names | `references/skill-format.md` §Directory Taxonomy |
| No junk files | Correct structure for single-skill / multi-skill repos |
| Collection risks | `references/skill-composition.md` — 15+ skills, context flooding, naming |
| Registration conflicts | `references/registration-audit.md` — workspace shadows, broken links |

### Quality

SKILL.md + references + scripts + assets reviewed as **one unit**. Read SKILL.md first, follow module references, check coherence across all files.

Shared checks (SKILL.md and every reference file):
- Three-layer format + Positional Test + EP-Content alignment → `validate_format()` + `review_reference()` — `references/skill-format.md`
- EP comment discipline — `references/execution-procedure.md` §5
- Terminology consistency across all files

| Check | Standard |
|-------|---------|
| Description coverage | Description covers key trigger scenarios from body |
| Description clarity | Comprehensible to a stranger without project context |
| Invocation reliability | `references/skill-invocation.md` |
| Graceful skip | `references/anti-graceful-skip.md` |
| Execution Procedure | `references/execution-procedure.md` — workflow skill + no EP = must fix |
| Entry complexity | Multiple modes must produce different deliverables |
| Script quality | `references/script-quality.md` |
| In-repo skills | Full validation recursively; cross-vendor symlinks use relative paths |
| Standard enforcement | Every reference must have an EP function call from SKILL.md — no call = 100% skip (`references/execution-procedure.md` §4) |
| EP contract integrity | Bidirectional: (1) every `ref.function()` call in SKILL.md EP has a matching `def function()` in the reference; (2) every reference `def` is called from SKILL.md. Parameter names must match. Reference with data but no `def` = must fix |
| Assets referenced | Every asset file referenced by SKILL.md or references |
| Maintenance-rules need | `references/maintenance-guide.md` |
| Onboarding need | `references/onboarding.md` — zero-config → PASS; first-use decisions or credentials needed → must fix |
| Configuration need | `references/skill-configuration.md` — user-adjustable preferences? litmus test applies |
| Rule-skill classification | `references/rule-skill-pattern.md` Mode A — is the skill itself a rule-skill? If yes, validate against rules-as-skills three-layer model |
| Rule-skill conversion | `references/rule-skill-pattern.md` Mode B/C — project has rules that should be skills? detection + packaging |
| Publishing model | `references/publishing-strategy.md` — single-skill vs collection, appropriate for project structure? |
| Reference extraction | `references/reference-extraction.md` — sections that should be references? line count thresholds, index quality |

### Publishing

External-facing presentation and packaging.

| Check | Standard |
|-------|---------|
| README quality | `references/readme-quality.md` — deferred to readme-craft in Fix Phase |
| Dependency mirroring | SKILL.md dependencies mirrored in README |
| Install command | `npx skills add <org>/<repo>` as primary |
| No hardcoded paths | No personal paths (~/, /Users/) in published files |
| LICENSE, .gitignore | `references/templates.md` — existence + content |
| Script documentation | Document what scripts do and permissions needed |
| GitHub metadata | Covered by readme-craft — do not duplicate |
| docs/ accuracy | No stale content vs SKILL.md claims |
| Unnecessary files | No lock files, > 1MB media, build artifacts |

## Fix Phase

**Plan-driven.** STEP 3b appends `## Findings` to the plan file (extracted from per-skill finding files). STEP 3c reads `[ ]` rows and fixes them, marking `[x]`. One file, entire lifecycle.

1. **Fix** (STEP 3c) — read `## Findings` in plan file. Each `[ ]` row = one fix action. Execute, then `[ ]` → `[x]`. Assert: zero unchecked must-fix rows.
2. **User decides** — must-fix is mandatory. Suggestion is optional (user approves/skips).
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
- All must-fix issues resolved, suggestions addressed or acknowledged
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

**CC Market**: `assess_cc_market(config)` — `references/platform-registry.md`.

## References

- `references/installation.md` — setup.sh standard: dependency detection, installation, two outcomes
- `references/skill-invocation.md` — Runtime invocation reliability: explicit `Skill(...)` call + output gate pattern
- `references/onboarding.md` — Interactive first-use guidance pattern
- `references/skill-configuration.md` — User preferences, config location, litmus test, stateless principle
- `references/skill-format.md` — Format specification for SKILL.md and reference files (frontmatter, Execution Procedure, content alignment, positional test)
- `references/skill-composition.md` — Composition philosophy: context budget, dependency tiers
- `references/rule-skill-pattern.md` — Forge integration: detection, auto-creation, and packaging of rule-skills
- `references/publishing-strategy.md` — Skill vs Collection publishing models (called by project-audit.md Classification)
- `references/platform-registry.md` — Platform skill paths, detection logic, community directories
- `references/templates.md` — README, LICENSE, and .gitignore skeletons
- `references/readme-quality.md` — README writing, claim discipline, example rules
- `references/script-quality.md` — Script size limits, module split triggers, dependency policy
- `references/maintenance-guide.md` — In-repo maintenance-rules skill: when to create, required content, template, reference dimension classification (D1/D2/D3)
- `references/anti-graceful-skip.md` — Default-execute principle, skip conditions, no-downside enhancements, Step 3 audit criteria
- `references/execution-procedure.md` — Pseudocode + plan-as-checklist + GATE pattern + attention model + non-overlapping ownership for workflow skills
- `references/project-audit.md` — Discovery, Classification, Plan File, Rules Conversion, Execution Order for project-level forge
- `references/reference-extraction.md` — When to extract sections into references, index quality, line count thresholds
- `references/registration-audit.md` — Pre-registration conflict detection: workspace shadows global, broken links, copy vs symlink
