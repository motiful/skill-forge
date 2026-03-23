---
name: skill-format
description: Format specification for SKILL.md and reference files. Covers SKILL.md frontmatter (Agent Skills community standard), body rules, context budget, reference file three-layer format (skill-forge internal convention), Positional Test (replaces Content Audience Check), content splitting rules, alignment validation, and cross-platform compatibility.
---

```
validate(file) → format_findings[]

if SKILL.md:
    check: standard frontmatter (name, description, license, metadata)
    check: body under 500 lines
    check: Execution Procedure present for workflow skills
if reference file:
    check: frontmatter (name, description)
    check: Execution Procedure present (pseudocode block)
    check: EP signature declares input/output
    check: Content sections map to EP lines (alignment validation)
positional test: HITL context → stays, calibrating → stays, homeless → docs/README
```

# SKILL.md and Reference File Format Specification

## TOC

- [Agent Skills Open Standard](#agent-skills-open-standard)
- [Standard Frontmatter](#standard-frontmatter)
- [CC-Specific Extensions](#cc-specific-extensions)
- [Body](#body)
  - [Positional Test](#positional-test)
  - [Context Budget](#context-budget)
- [Reference File Format](#reference-file-format)
  - [Philosophy](#philosophy)
  - [Three Layers](#three-layers)
  - [Reference Frontmatter](#reference-frontmatter)
  - [Execution Procedure](#execution-procedure)
  - [Content Rules](#content-rules)
  - [HITL Convention](#hitl-convention)
  - [Alignment Validation](#alignment-validation)
- [Content Splitting Rules](#content-splitting-rules)
- [File Structure](#file-structure)
  - [Directory Taxonomy](#directory-taxonomy)
- [Cross-Platform Compatibility](#cross-platform-compatibility)

## Agent Skills Open Standard

Skills follow the **Agent Skills open standard** (agentskills.io), adopted by Claude Code, Microsoft Copilot, OpenAI ChatGPT, GitHub, Cursor, Atlassian, and Figma.

## Standard Frontmatter

Works on all Agent Skills platforms:

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

### Positional Test

Every content block in SKILL.md (and in reference files) must pass the positional test:
**Can this content be placed at a specific point in the Execution Procedure?**

Three ways to pass:
1. **Execution logic** — the content IS an EP operation (condition, assertion, step)
2. **Calibrating context** — the content helps the AI judge a specific condition more accurately
   (e.g., "3-5 skills ~ 15K-25K tokens" calibrates the "too many dependencies" threshold)
3. **HITL context** — the content supports a `report to user (HITL)` step
   (e.g., explaining impact so the user can approve/reject a finding)

Content that passes → stays, placed at the EP point it serves.
Content that fails (no EP point serves it) → docs/ or README.

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
- Individual reference file: under 100 lines needs no TOC; 100-300 lines is acceptable with a TOC; above 300 lines should split by default
- **Instruction density**: at least 60% of lines should be executable instructions (check tables, rules, process steps, templates). Below 60% suggests excessive explanation
- References are **loaded on-demand** — the agent reads them only when the process flow requires it. Budget is per-file, not sum-of-all-files. A skill with 250-line SKILL.md + five 100-line references is fine — peak load is ~350 lines, not 750

**How to estimate instruction density:**
Count lines that are: table rows with check actions, numbered/bulleted process steps, code blocks, report templates, Rules items. For domain-agnostic skills, also count domain examples that define execution scope (e.g., showing how a check applies to video or research projects). Divide by total non-blank lines. If the ratio is below 0.6, look for explanatory paragraphs that can be compressed or moved to README.

## Reference File Format

### Philosophy

**Skills are code. The LLM is the compiler.** Structured natural language → LLM → tool calls, file edits, code. This is mechanism, not metaphor.

References are **modules** in this compilation model. SKILL.md is the main program. Each reference is a callable unit with a declared interface (EP). A reference without an EP is a source file without exports — the compiler can process it, but unreliably.

### Three Layers

Every reference file has three layers — the same pattern as SKILL.md, at module scale:

| Layer | SKILL.md | Reference |
|-------|----------|-----------|
| Frontmatter | Agent Skills standard (name, description, license, metadata) | skill-forge convention (name, description) |
| Execution Procedure | Same spec — entry point, triggered by platform/user | Same spec — module, called by SKILL.md |
| Content | Sections expanding EP steps | Sections expanding EP lines |

Same EP specification, no functional restrictions. Only difference: SKILL.md is the entry point, references are called modules.

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

Pseudocode block after frontmatter, before the first `##` section. Always present. Signature line (first line) declares input/output: `validate(skill_md) → findings[]`. Structured natural language, not strict syntax. HITL steps marked inline: `(HITL)`. 2-10 lines typical, no artificial limit.

### Content Rules

- Each `##` Section corresponds to one or more EP lines
- **Inline Why**: follows the rule it serves, 1-2 lines max. Self-evident rules need no Why
- No orphan Sections (content not mapped to any EP line)
- Tables, lists, templates, pseudocode — whatever form fits

### HITL Convention

HITL is an **execution step** in the EP, not file-level metadata. In EP: `report findings to user → get approval (HITL)`. In Content: the HITL section specifies what to present and what context the human needs.

Content supporting HITL presentation — impact explanations, decision context — is inside the system. It serves the HITL step. See Positional Test for the three content categories (HITL context, calibrating context, homeless content).

### Alignment Validation

Mechanical EP ↔ Content alignment check, run during Content Review:

```
for each reference file:
    for each Content section:
        if no EP line references it → Warning: homeless content
    for each EP line:
        if no Content section expands it → Warning: possible drift
```

## Content Splitting Rules

**SKILL.md is the index and decision tree. References are the knowledge base.**

- SKILL.md answers: *what to do, in what order, under what conditions*
- References answer: *what specifically to check, how to check it, how to judge the result*

Split content into a reference file when it meets ALL three criteria:
1. **EP-writability test** — you can write 2+ lines of meaningful Execution Procedure for it (input → operations → output). Can't write an EP = content is either too trivial (keep inline) or purpose too vague (clarify first)
2. **Single responsibility** — the content covers one coherent concern that can be understood on its own
3. **Different change cadence** — you'd update this content independently of the process flow

**Do NOT split** when you can't write an EP for it, content is tightly coupled to the process flow (report templates, decision tables), or would require the reader to constantly jump back to SKILL.md.

**Split early** when a file mixes multiple responsibilities, even if it is under 300 lines. Mixed examples:
- literal templates + writing rules
- validation logic + publishing strategy
- setup policy + troubleshooting appendix

**Index quality checklist:**
- Every reference pointer in SKILL.md states what the reference contains and when to read it
- Conditional references have explicit gateways: "If X applies → see references/Y.md"
- Always-needed references have direct pointers: "Detailed checks are in references/Y.md"
- SKILL.md alone tells the AI the complete process flow — references fill in domain details

**Thresholds:**
- SKILL.md body: under 500 lines
- Reference file under 100 lines: TOC not needed
- Reference file 100-300 lines: add a TOC, no split needed purely for length
- Reference file above 300 lines: split by default
- Multi-responsibility reference files: split regardless of length
- Budget is per-file (peak load), not sum-of-all-files — references load on-demand
- Don't split a 250-line single-purpose reference into 6 tiny files — splitting has overhead too

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

For maximum portability:
- Use only standard frontmatter fields (name, description, license, compatibility, metadata)
- Avoid CC-specific extensions unless the skill truly needs them
- README.md serves as the human-readable + other-AI-tool-readable entry point
- Skill's core knowledge in SKILL.md body is platform-agnostic markdown

## Skill Relationships

### Self-Containment

Each generated skill must function without skill-forge installed — this is what "self-contained" means. It does NOT mean "has no dependencies on other skills or tools." Skills can and should declare their own dependencies, which `scripts/setup.sh` installs automatically.

**"Self-contained from forge" ≠ "independent from everything."**

### Dependencies and Composition

Skills declare dependencies in SKILL.md Step 0 and install them via `scripts/setup.sh`. This is normal engineering, not package management.

**Do:**
- Declare dependencies in SKILL.md Step 0 and `scripts/setup.sh`
- Mirror dependencies in README's "Dependencies" section
- Bundle related skills in the same repo for convenience

**Don't:**
- Silently depend on a tool without declaring it
- Use "works better with" language for things that are actually required
