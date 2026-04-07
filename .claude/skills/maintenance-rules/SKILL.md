---
name: maintenance-rules
description: 'Maintenance rules for the skill-forge repo. MUST run Decision Test before accepting changes. MUST update platform-registry when platforms change. MUST keep SKILL.md under 500 lines. MUST verify cross-file consistency after changes. Triggers on "update skill-forge", "maintain skill-forge", "refresh platform registry", "check community tools".'
metadata:
  author: motiful
---

# skill-forge Maintenance Rules

Constraints and procedures for maintaining the skill-forge repository.

## Execution Procedure

```
maintain(trigger) → updated | no_change

if "platform registry" in trigger:
    update_platform_registry()
    update_downstream()                               # SKILL.md Fix Phase, README install, Detection logic
if "community tools" in trigger:
    update_community_tools()
if change proposed:
    run_decision_test()                               # 7 criteria → accept | reject
    verify_constraints()                              # each MUST's parenthesized method
    run_consistency_checks()
    update_changelog()                                # max 5, trim oldest
after significant changes:
    run_self_governance()                             # 4 steps
```

## Constraints

- MUST run Decision Test (7 criteria below) before accepting any change
- MUST NOT push SKILL.md body over 500 lines
- MUST keep SKILL.md ↔ README ↔ references terminology consistent
- MUST add References section entry when adding new reference files
- MUST update "Dependencies" table in README when SKILL.md dependencies or setup.sh changes
- MUST NOT include content that fails the Positional Test (see references/skill-format.md)
- MUST verify reference files follow three-layer format (frontmatter + EP + aligned Content)
- MUST keep examples in standard-defining references generic — no skill-forge-specific labels in universal patterns
- MUST verify SKILL.md pseudocode function names align with sub-module EP entry signatures (run: grep function names from references/ EPs, diff against SKILL.md pseudocode calls)
- MUST verify lossless delegation when moving inline criteria to a sub-module: map every deleted parent line to a sub-module EP line. Unmapped criteria → add to sub-module first, then remove from parent (run: diff parent before/after, match each removed line to a sub-module line)
- MUST verify every defined standard has a corresponding enforcement check in Validation (Structure, Quality, or Publishing). A standard without a check is dead weight — either add the check or remove the standard

## Platform Registry Updates

1. Open `references/platform-registry.md`
2. For each platform, check Docs link for: user-level paths, project-level paths, shared compat directories, link validity
3. Search: "agent skills directory [platform name] 2026" for new platforms
4. Distinguish: vendor-native paths vs compat-scanned paths vs custom locations
5. Only actual skill roots count as strong signals (not bare parent dirs)
6. Treat Gemini CLI as adjacent tooling unless official docs add Agent Skills directory support
7. Update paths + "Last verified" date
8. Keep platform facts separate from forge behavior
9. If path changes affect SKILL.md Fix Phase, README install examples, or Detection logic, update those too
10. If README writing guidance changes, update both `references/templates.md` and `references/readme-quality.md`
11. Add changelog entry (keep max 5, trim oldest)

## Community Tools Updates

1. Check `npx skills add` — still maintained? New features?
2. Check `skills-ref validate` — new validation rules? Keep as optional, not required dependency
3. Check skills.sh FAQ before making visibility claims. Installability ≠ directory/leaderboard visibility
4. Update Community Tools table in `references/platform-registry.md` if needed

## Contribution Criteria

Use the **Decision Test**:

1. Does it help users' skills score higher on the 6 quality dimensions?
2. Is it simple enough that an AI agent will reliably follow it?
3. Can it be expressed as prompts instead of scripts?
4. Does it impose an architectural opinion most skills don't need?
5. Is it a platform or infrastructure concern, not skill quality?
6. Does the ecosystem actually use this pattern?
7. Do we practice it ourselves?

**Accept** when: yes, yes, yes, no, no, yes, yes. Wrong answers need justification.

PR hygiene:
- Changes to SKILL.md must not push body over 500 lines
- New reference files need a SKILL.md References entry
- Terminology changes must be consistent across SKILL.md, README.md, and all affected references

## Self-Governance

skill-forge validates other skills. It must also pass its own validation.

Protocol (run after significant changes):
1. Run skill-forge Review on this repo
2. Every README claim must be backed by a SKILL.md capability
3. Every reference listed in SKILL.md must exist and be current
4. Version in frontmatter, README badge, and changelog must agree

## Consistency Checks

- SKILL.md description matches README positioning
- README "Dependencies" table matches SKILL.md Step 0 + setup.sh
- No residual terminology from previous versions: "five-layer", "Kit", "JIT", "Enhancement Report", "Quick Review", "Full Pipeline", "Multi-Skill Triage", "Scenario 1/2/3/4/5", "Operation Modules", "Step Reference", "Output Checklist", "Content Audience Check", "Interface" (as reference layer name), "Header" (as reference layer name), "Teaching" (as layer name), "Directing" (as layer name), "Review" (as independent EP entry name), "Create" (as independent EP entry name), "Push" (as independent EP entry name), "review_plan()", "update_plan()", "close_plan()", "checkpoint()", "content block" (replaced by "paragraph"), "register_locally()" (replaced by "detect_and_register()" per platform-registry.md EP), "read_repo_meta()" (replaced by Skill("readme-craft", "apply metadata") — github-metadata migrated to readme-craft), "lookup()" (replaced by "detect_and_register()"), "validate(repo_meta)" (replaced by Skill("readme-craft", "apply metadata")), "validate_and_apply()" (for github metadata context — replaced by readme-craft delegation), "detect(skill_md) → bool" (replaced by "assess_procedure_need() → workflow_skill | reference_only"), "design()" (replaced by "assess_config_needs()" / "assess_and_guide()"), "audit()" (replaced by "audit_conditional_branches()"), "create(skill_repo)" (replaced by "assess_and_create()"), "Execute reference" / "Read reference" (replaced by unified "reference" — file structure tells AI what to do), "Execute sub-module EPs" (replaced by "Follow module interfaces" — Engagement Principle #8), "EP-writability test" (replaced by module-based judgment: independent module with own interface → reference), "Parameterizing" (never adopted — sections are implementation, not parameters), "Core Validation" / "Content Review" / "Repo Hygiene" (replaced by unified "Security" gate + "Validation" section with Structure/Quality/Publishing sub-groups — categorize findings not execution), "read_or_create_config()" (replaced by "assess_config_needs()" per skill-configuration.md EP), "write_skill_md()" (replaced by "scaffold_skill_md()" — local operation following skill-format.md standards), "discover()" + "classify()" as separate calls (replaced by single "discover_and_classify()" per project-audit.md EP)
- Current terminology (across SKILL.md + references): "Engagement Principles", "Execution Procedure", "Security" (pre-flight gate), "Validation" (one section: Structure + Quality + Publishing), "Fix Phase", "Local Ready Definition", "Push to Remote", "Positional Test", "Alignment Validation", "Three-Layer Format", "Module Model" (EP=interface, Section=implementation, Reference=imported module), "Forge", "Publish" (as Step 4 of forge), "review_and_update_plan" (assert review_and_update_plan() at major step boundaries), "Follow module interfaces" (Engagement Principle #8), "Batch Principle", "Non-Overlapping Ownership", "EP Comment Discipline", "Step Granularity", "categorize findings, not execution" (corollary in execution-procedure.md §6), "Registration Audit" (pre-registration conflict detection), "audit_registrations()" (owned skills only, scoped by config.skill_root), "table-driven dispatch" (validation table rows as EP dispatch mechanism for reference EPs)

## Update Triggers

| Event | What to check |
|-------|--------------|
| Agent Skills standard changes | SKILL.md frontmatter, `references/skill-format.md` |
| New platform adopts Agent Skills | `references/platform-registry.md`, README install examples, SKILL.md Fix Phase |
| `npx skills add` breaking change | README install commands, Quick Start |
| skill-forge SKILL.md changes | README alignment, Dependencies table, version badge |
| New reference file added | SKILL.md References section |
| Community feedback or bug report | Relevant validation checks in SKILL.md Step 3 |
| Registration audit logic changes | `references/registration-audit.md`, SKILL.md EP audit_registrations() call |

## Changelog (max 5 entries)

- 2026-04-07: **v9.1 — Threshold + dispatch + docs.** Reference file split threshold raised from 300 to 450 lines (reference-extraction.md, skill-format.md). execution-procedure.md description updated for 14 sections (9 core + 5 attention). Documented table-driven dispatch mechanism in Validation section. Fixed stale TOC anchor in execution-procedure.md. Linked unlinked docs/ from README.
- 2026-03-31: **v9.0 — Self-review fixes.** Version badge synced to 9.0. EP enforcement made specific (each MUST constraint now has parenthesized verification method). Removed stale "Lossless delegation" from current terminology. Fixed "Categorize findings not execution" casing to match source.
- 2026-03-25: **v8.1 — Self-audit fixes.** GitHub metadata migrated to readme-craft. Skill() calls now use output capture + gate. setup.sh checks git. skill-format.md split: Content Splitting → references/reference-extraction.md, Batch/Non-Overlapping → execution-procedure.md (356→282 lines). platform-registry.md gets `assess_cc_market` EP entry. Create path reports when all caps are false. Description covers registration + onboarding.
- 2026-03-25: **v8.0 — Module Model architecture + Registration Audit.** EP=interface, Section=implementation, Reference=imported module. Added EP Comment Discipline, Step Granularity, Batch Principle, Non-Overlapping Ownership. Dropped Execute/Read reference distinction. Pseudocode cleaned: decision logic converted from comments to code. Merged Core Validation + Content Review + Repo Hygiene into Security gate + unified Validation (Structure/Quality/Publishing). Lossless delegation moved to maintenance-rules. New references/registration-audit.md.
- 2026-03-23: **v7.2 — Unified forge entry.** Merged Review + Create + Push into single `forge()` EP. Publish is Step 4 (optional, trigger-gated).

