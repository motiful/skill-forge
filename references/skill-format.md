---
name: skill-format
description: Format specification for SKILL.md and reference files. Covers SKILL.md frontmatter (Agent Skills community standard), body rules, context budget, reference file module model (EP=interface, section=implementation, reference=imported module), positional test, alignment validation, and cross-platform compatibility. Reference extraction rules delegated to reference-extraction.md.
---

# SKILL.md and Reference File Format Specification

## Execution Procedure

```
validate_format(file) → format_findings[]

if SKILL.md:
    check: standard frontmatter (name, description, license, metadata)
    check: description FORMAT — single-line, < 1024 chars, non-empty, no angle brackets
    check: description QUALITY — validate_description_quality() → FAIL any missing gate
    check: body under 500 lines
    check: body opening — validate_body_opening() → FAIL if opener is meta not actionable
    check: ## Execution Procedure heading with pseudocode block for workflow skills
    check: file ordering (title → description → [preamble] → EP → content)
if reference file:
    check: frontmatter (name, description)
    check: ## Execution Procedure heading with pseudocode block
    check: EP signature declares input/output
    check: Content sections map to EP lines (alignment validation)
    check: file ordering (title → description → [preamble] → EP → content)
positional test: each section serves an EP line → stays. No EP line → docs/README

review_reference(file) → content_findings[]

check: three-layer format (frontmatter + EP + content)
positional test: each paragraph → which EP line? (not section level)
check: parent SKILL.md has invocation point for this module's EP (referenced ≠ invoked)
check: terminology consistent with parent SKILL.md
check: cross-references resolve
check: no hardcoded paths
check: line count reasonable (< 300 or has TOC)
# Reference extraction: references/reference-extraction.md

validate_description_quality(description) → FAIL | PASS   # MUST-level, see §Description Quality

fail if: states only WHAT (no trigger) OR only WHEN (no capability)  # both halves required
fail if: no explicit "Use when..." trigger + concrete keywords/phrases/file-types
fail if: first/second person — "I" / "you" / "we" / "help you"       # third person only
fail if: vague filler — "helps with" / "processes data" / "does stuff" / "utilities for"
fail if: LEAKS BODY — implementation steps, concept-teaching, cross-refs used as content,
         internal conventions, OR restates the skill's own MUST/NEVER rules  # KEY new check
warn if: sibling skill overlaps but no negative trigger ("Do NOT use for X, use Y instead")
# "pushy"/assertive phrasing is ALLOWED (combats under-triggering) — never a fail

validate_body_opening(body) → FAIL | PASS                # MUST-level, see §Body Opening

opener := first lines / blockquote directly after the H1 title
fail if: opener self-describes epistemic category ("this skill is descriptive/prescriptive")
fail if: opener is an authority declaration ("hard constraints per X meta-protocol",
         "same authority as a platform-native rule file")
fail if: opener's FIRST thing is cross-skill navigation ("Read ../other/SKILL.md first")
fail if: opener is an internal maintenance citation ("Boundary: ADR 00xx")
pass if: opener is actionable — the model / Execution Procedure / the procedure itself
# one plain one-line pointer to a needed definition is OK; a STACK of meta blockquotes = FAIL
```

## TOC

- [Standard Frontmatter](#standard-frontmatter)
  - [Description Quality](#description-quality)
- [CC-Specific Extensions](#cc-specific-extensions)
- [Body](#body)
  - [Body Opening](#body-opening)
  - [Positional Test](#positional-test)
  - [Context Budget](#context-budget)
- [Reference File Format](#reference-file-format)
  - [Module Model](#module-model)
  - [Three Layers](#three-layers)
  - [File Ordering](#file-ordering)
  - [Reference Frontmatter](#reference-frontmatter)
  - [Execution Procedure](#execution-procedure)
  - [Content Rules](#content-rules)
  - [HITL Convention](#hitl-convention)
  - [Alignment Validation](#alignment-validation)
- [File Structure](#file-structure)
  - [Directory Taxonomy](#directory-taxonomy)
- [Cross-Platform Compatibility](#cross-platform-compatibility)

## Standard Frontmatter

Skills follow the [Agent Skills open standard](https://agentskills.io). Works on all platforms:

```yaml
---
name: kebab-case-name       # required, max 64 chars, lowercase alphanumeric + hyphens
description: What it does and when to trigger. All trigger conditions go here — the description IS the trigger mechanism. Must be single-line (YAML multi-line >- or | causes skills to silently disappear in CC).
license: MIT                # optional
compatibility: node>=18     # optional, system requirements
metadata:                   # optional, custom key-value pairs
  author: name
  version: "1.0"
---
```

**Key rules:**
- `name` — kebab-case, max 64 chars. Must not start/end with hyphen, no consecutive hyphens (`--`), must match parent directory name
- `description` — max 1024 chars, no angle brackets. Must be quoted if value contains `: ` (colon-space) to avoid strict YAML parser failures. This is the trigger mechanism — the agent reads descriptions to decide relevance. All trigger conditions go here.
- `metadata` — free-form key-value pairs for author, version, tags, etc.

The bullets above are the FORMAT gate. Format alone is insufficient: a well-formed line can still be a poor trigger. Every `description` also passes the Description Quality gate below.

### Description Quality

MUST-level content gate — `validate_description_quality()`. A description that only passes format but fails any row below is a **must-fix**, not a suggestion. The description is injected into the system prompt as the sole trigger signal for skill selection among potentially 100+ skills; a description that teaches or restates rules instead of naming triggers under-triggers the skill and wastes the reader's selection budget.

| # | Criterion | FAIL when |
|---|-----------|-----------|
| 1 | **Both halves** | States only WHAT it does, or only WHEN to use it. Missing either half → FAIL |
| 2 | **Explicit triggers** | No "Use when…" clause with concrete keywords / phrases / file-types a user would actually say |
| 3 | **Third person** | Contains "I" / "you" / "we" / "help you" — first or second person → FAIL |
| 4 | **Specific, not vague** | Uses filler: "helps with", "processes data", "does stuff", "utilities for" → FAIL |
| 5 | **No body leak** (KEY) | Leaks body content: implementation steps, concept-teaching / explanation, cross-references to other skills or docs used AS content, internal conventions, OR restates the skill's own MUST / NEVER rules. A description that teaches or restates rules instead of naming triggers → FAIL |
| 6 | **Format** | > 1024 chars, empty, angle brackets, or multi-line (see FORMAT bullets above) → FAIL |

**Allowed / recommended (never a FAIL):**
- **Pushy is fine** — assertive, "always reach for this" phrasing is encouraged; it combats under-triggering.
- **Negative triggers recommended** — when a sibling skill overlaps, add "Do NOT use for X — use `<other-skill>` instead" to route correctly.

**GOOD** (verbatim, official example — states what + when, concrete triggers, third person, no body leak):

```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**BAD:**

```yaml
description: Helps with documents                         # vague filler, no trigger, no capability
description: I can help you process Excel files           # first person + second person
```

Standard: Anthropic *Skill authoring best practices* (`platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices`) §Writing effective descriptions + §Checklist — "include both what the Skill does and when to use it", "Always write in third person", "Be specific and include key terms". Validation limits (1024 chars, non-empty, no XML tags) from the API skills-guide. Example set from `anthropics/skills` skill-creator.

## CC-Specific Extensions

Claude Code supports additional frontmatter fields. For cross-platform compatibility, keep CC-specific settings inside `metadata`. This also keeps the optional `skills-ref validate` check green:

```yaml
metadata:
  cc-disable-model-invocation: true   # only user can invoke via /skill-name
  cc-user-invocable: false            # only Claude auto-triggers, not in / menu
  cc-model: claude-opus-4-6           # override model for this skill
  cc-context: fork                    # run in isolated subagent
  cc-agent: Explore                   # subagent type (Explore, Plan, general-purpose)
  cc-argument-hint: "[file] [format]" # show expected args in autocomplete
```

**Exception**: `allowed-tools` is a standard field accepted by `skills-ref` and can remain top-level:

```yaml
allowed-tools: Read, Grep, Bash  # restrict tool access when active
```

If you're building a CC-only skill and don't care about cross-platform portability, you can use the original top-level fields — CC runtime ignores unknown fields gracefully. For publishable cross-platform skills, keep custom fields inside `metadata`. If the user has `skills-ref` installed, this also ensures the optional validator passes cleanly.

## Body

- Supports string substitutions: `$ARGUMENTS`, `$0`, `$1`, `${CLAUDE_SKILL_DIR}`
- Keep under 500 lines. Use progressive disclosure — put details in `references/` files
- Write for another AI agent, not a human. Include non-obvious procedural knowledge
- Only add what the AI doesn't already know. Don't explain basic concepts
- Prefer concise examples over verbose explanations
- Default published skill content to English. Use another language only when the skill is explicitly language-specific or culture-specific

### Body Opening

MUST-level gate — `validate_body_opening()`. The body MUST open with actionable content — the model, the `## Execution Procedure`, or the procedure itself — so the agent starts DOING the thing. Self-referential meta-commentary as the opener is a **must-fix**: the reader burns its first attention on prose that produces no action.

The **opener** = the first lines / blockquote directly after the `# Title`. FAIL when the opener is any of:

| FAIL opener | Example |
|-------------|---------|
| Epistemic self-description | "This skill is descriptive / prescriptive / says what things ARE" |
| Authority declaration | "hard constraints per the X meta-protocol", "same authority as a platform-native rule file" |
| Cross-skill navigation as the very first thing | "Read `../other/SKILL.md` first" as the opener |
| Internal maintenance citation | "Boundary: ADR 00xx" |

**Allowed:** a single one-line plain pointer to a needed definition. A *stack* of meta blockquotes → FAIL. If the opener describes the skill instead of starting the work, move it to README and lead with the procedure.

Standard: Anthropic *Skill authoring best practices* §Concise is key + §Progressive disclosure — "Only add context Claude doesn't already have", lead SKILL.md with what to DO (quick-start / workflow), push background to references or README.

### Positional Test

Every paragraph in SKILL.md (and in reference files) must pass the positional test:
**Which EP line does this content serve?**

Can name one → keep, placed near that EP line.
Cannot → move to docs/ or README.

Three common ways content serves an EP line:
1. **Execution logic** — the content IS an EP operation (condition, assertion, step)
2. **Calibrating context** — helps the AI judge a specific condition more accurately
   (e.g., "3-5 skills ~ 15K-25K tokens" calibrates the "too many dependencies" threshold)
3. **HITL context** — supports a `report to user (HITL)` step
   (e.g., explaining impact so the user can approve/reject a finding)

**Common violations:**
- Concept explanations without a corresponding EP condition → translate to a Rule or move out
- Statistical persuasion used as argument (not as threshold) → move to README
- Authority citations → move to README
- Cross-references to README → delete (AI won't read README during execution)

**How to check:**
1. Read each paragraph
2. Ask: "Which EP line does this serve?"
3. Can name one → keep, place near that EP line
4. Cannot → move to docs/ or README

### Context Budget

Skill loading consumes context tokens. The total loaded content (SKILL.md + all references that get loaded) should be proportional to the skill's complexity.

**Guidelines:**
- SKILL.md body: under 500 lines (the always-loaded ceiling)
- Individual reference file: under 100 lines needs no TOC; 100-300 lines is acceptable with a TOC; 300-450 lines evaluate concerns (single concern + TOC = keep, mixed = split); above 450 lines split by default
- **Instruction density**: at least 60% of lines should be executable instructions (check tables, rules, process steps, templates). Below 60% suggests excessive explanation
- References are **loaded on-demand** — the agent reads them only when the process flow requires it. Budget is per-file, not sum-of-all-files. A skill with 250-line SKILL.md + five 100-line references is fine — peak load is ~350 lines, not 750

**How to estimate instruction density:**
Count lines that are: table rows with check actions, numbered/bulleted process steps, code blocks, report templates, Rules items. For domain-agnostic skills, also count domain examples that define execution scope (e.g., showing how a check applies to video or research projects). Divide by total non-blank lines. If the ratio is below 0.6, look for explanatory paragraphs that can be compressed or moved to README.

## Reference File Format

### Module Model

A skill file is a software module. This applies to both SKILL.md and every reference file:

| Programming | Skill file |
|---|---|
| Module | File (SKILL.md or reference) |
| Interface / signature | EP (pseudocode block) |
| Implementation | Content sections |
| Inline function | Section in the same file — tightly coupled, consumed at one call site |
| Imported module | Reference file — independent concern, own interface, may have multiple callers |
| Function call | EP line referencing a section (`# see X section`) or module (`# references/X.md`) |

**EP owns control flow** — sequence, conditions, gates, module calls.
**Sections own domain knowledge** — standards, rules, definitions, details, examples.

Section format is unconstrained — tables, prose, code, decision trees. Sections can reference other modules for deeper detail. SKILL.md is the entry point; references are imported modules — both follow the same three-layer structure.

### Three Layers

Every reference file has three layers — the same pattern as SKILL.md, at module scale:

| Layer | SKILL.md | Reference |
|-------|----------|-----------|
| Frontmatter | Agent Skills standard (name, description, license, metadata) | skill-forge convention (name, description) |
| Execution Procedure | Same spec — entry point, triggered by platform/user | Same spec — module, called by SKILL.md |
| Content | Sections expanding EP steps | Sections expanding EP lines |

Same EP specification, same structural capabilities, no functional restrictions. Only difference: SKILL.md is the entry point, references are called modules.

### File Ordering

Canonical section order — applies equally to SKILL.md and reference files:

| Position | Section | Required |
|----------|---------|----------|
| 1 | `---` Frontmatter `---` | Yes |
| 2 | `# Title` | Yes |
| 3 | Description (1+ paragraphs) | Yes |
| 4 | Preamble sections | Optional |
| 5 | `## Execution Procedure` | Yes (workflow) / No (reference-only exemption) |
| 6 | `## TOC` | Optional (recommended at 100+ lines) |
| 7 | Content sections | Yes |

**Strict order**: sections must appear in this sequence. No content sections before EP. No EP before title.

**`# Title`** must immediately follow frontmatter. States the module's name in human-readable form.

**Description** follows title. At least 1 paragraph. States what this module does and its scope.

**Preamble sections**: `##`-level sections between description and EP. Contain universal rules that apply to ALL EP paths (e.g., Engagement Principles, Security constraints). Must pass the Positional Test — they serve every EP line, not just one. Expected in complex skills; rare in reference modules.

**SKILL.md vs reference files**: the ordering is identical. The only structural differences are frontmatter format (Agent Skills standard vs skill-forge convention) and the role (entry point vs imported module). EP, preamble, content sections — all follow the same rules in both.

### Reference Frontmatter

```yaml
---
name: kebab-case-name
description: Complete scope description of this module — what it validates, decides, or generates, and what aspects it covers.
---
```

- `name` — kebab-case, must match filename (without `.md`)
- `description` — module's complete scope (more detailed than SKILL.md's trigger-oriented description)
- No `input`/`output` — declared by EP signature line. No `license` — inherits from parent repo

**Important**: This is a **skill-forge internal convention**, not the Agent Skills community standard. SKILL.md frontmatter is parsed by platforms (CC, Codex, etc.); reference frontmatter is parsed only by skill-forge during Review. The two are not interchangeable.

### Execution Procedure

Always under a `## Execution Procedure` heading. The heading is the identifier — same heading, same capabilities in both SKILL.md and reference files.

**Structure** (all elements available in both SKILL.md and reference files):

| Element | Required | Description |
|---------|----------|-------------|
| `## Execution Procedure` heading | Yes | Section identifier |
| Instruction paragraph | No | Brief execution guidance before pseudocode |
| `###` sub-procedures | No | Multiple triggers or entry points (e.g., `### Forge`, `### Create`) |
| Pseudocode block(s) | Yes (≥1) | Structured natural language in code fences, not strict syntax |
| `(HITL)` markers | When applicable | Inline in pseudocode to mark human-in-the-loop steps |

2-10 lines typical per entry, no artificial limit.

**Multiple entry points**: A file can declare multiple EP entries (like a module exporting multiple functions), each with its own signature. Use when one file serves multiple callers or steps. Signature naming conventions are in `references/execution-procedure.md`.

### Content Rules

Sections are the **implementation** of EP lines — inline functions consumed at one call site.

- Each `##` section serves one or more EP lines (Positional Test). No orphan sections
- Format is unconstrained — tables, prose, code, decision trees, examples
- **Inline Why**: follows the rule it serves, 1-2 lines max. Self-evident rules need no Why

### HITL Convention

HITL is an **execution step** in the EP, not file-level metadata. In EP: `report findings to user → get approval (HITL)`. In Content: the HITL section specifies what to present and what context the human needs.

Content supporting HITL presentation — impact explanations, decision context — is inside the system. It serves the HITL step. See Positional Test for the three content categories (HITL context, calibrating context, homeless content).

### Alignment Validation

Mechanical EP ↔ Content alignment check, run during Validation (Quality):

```
for each reference file:
    for each Content section:
        if no EP line references it → Warning: homeless content
    for each EP line:
        if no Content section expands it → Warning: possible drift
```

## File Structure

```
skill-name/
├── SKILL.md              # required (at repo root for npx skills add discovery)
├── references/           # optional, domain knowledge loaded on demand
├── assets/               # optional, templates and static resources consumed as material
├── scripts/              # setup.sh required if skill has dependencies; other executables optional
├── .claude/skills/       # optional, in-repo skills (e.g., maintenance-rules)
├── README.md             # required for GitHub
├── LICENSE               # required for GitHub (default: MIT)
└── .gitignore
```

- SKILL.md at repo root — `npx skills add` discovers root SKILL.md first
- References: one level deep from SKILL.md. Add a TOC at 100+ lines
- `.claude/skills/`: in-repo skills loaded via Agent Skills mechanism. See `maintenance-guide.md` for maintenance-rules, `publishing-strategy.md` for the in-repo publishing model
- Delete empty directories (don't create scripts/, references/, or assets/ if unused)

### Directory Taxonomy

**`references/`** — Domain knowledge loaded on-demand by the AI to make decisions. Checklists, format specs, evaluation criteria, rules. Reference files follow the three-layer format: frontmatter (name + description) + Execution Procedure (pseudocode) + Content (sections).

**`assets/`** — Static resources the AI consumes as raw material for output. Templates (to fill placeholders), data files, schemas, images.

**`scripts/`** — Executable code the AI runs. `setup.sh` (dependency installation — required for skills with dependencies), generators, validators, CLI tools.

**`.github/`** — Repo infrastructure serving GitHub presentation: logo, screenshots, badge images, workflow files. Not skill runtime content.

**Repo infrastructure** — Files serving GitHub/publishing, not skill runtime: README.md, LICENSE, CONTRIBUTING.md, .gitignore, `.github/`, docs/, examples/, package.json, requirements.txt.

The Agent Skills open standard names three skill directories: `references/`, `assets/`, `scripts/`. Additional directories (like `templates/`, `docs/`, `examples/`) are tolerated by the spec but non-standard. During validation (Step 3), flag non-standard directory names and suggest the canonical mapping: templates → assets, docs/examples → repo infrastructure.

## Cross-Platform Compatibility

For maximum portability, use only standard frontmatter fields and keep CC-specific settings inside `metadata`. Skill core knowledge in SKILL.md body is platform-agnostic markdown.
