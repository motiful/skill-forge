# SKILL.md Format Specification

## TOC

- [Agent Skills Open Standard](#agent-skills-open-standard)
- [Standard Frontmatter](#standard-frontmatter)
- [CC-Specific Extensions](#cc-specific-extensions)
- [Body](#body)
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
- `name` — kebab-case, max 64 chars
- `description` — max 1024 chars, no angle brackets. This is the trigger mechanism — the agent reads descriptions to decide relevance. All trigger conditions go here.
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

### Content Audience Check

Every paragraph in SKILL.md should pass the **behavior test**: if you delete this paragraph, would the AI's execution change? If not, the content belongs in README.md (for humans) or should be translated into an actionable Rule.

**Common violations:**
- **Concept explanations** — "Pillars are lenses, not file categories" → AI doesn't need convincing. Translate to a Rule: "Scan by content, not file type."
- **Theoretical background** — "This draws from Feynman's criteria..." → Move to README's Design Philosophy section.
- **Motivational framing** — "The valid engineering sequence is: build one step, test one step..." → Replace with the concrete check: "Flag items that depend on unbuilt prerequisites."
- **Cross-references to README** — "For background, see README.md" → AI won't read README during execution. Delete.

**How to check:**
1. Read each paragraph in SKILL.md
2. Ask: "Does this tell the AI **what to do**, **when to do it**, or **how to judge the result**?"
3. If yes → keep
4. If it explains **why** without a corresponding **what** → translate to a Rule or move to README
5. **Exception for domain-agnostic skills**: if the skill is designed to work across domains (code, video, research, content), domain examples that show *how to apply a check in a non-obvious domain* pass the behavior test — they define execution scope, not explain concepts.

### Context Budget

Skill loading consumes context tokens. The total loaded content (SKILL.md + all references that get loaded) should be proportional to the skill's complexity.

**Guidelines:**
- SKILL.md body: under 500 lines (the always-loaded ceiling)
- Individual reference file: under 100 lines needs no TOC; 100-300 lines is acceptable with a TOC; above 300 lines should split by default
- **Instruction density**: at least 60% of lines should be executable instructions (check tables, rules, process steps, templates). Below 60% suggests excessive explanation
- References are **loaded on-demand** — the agent reads them only when the process flow requires it. Budget is per-file, not sum-of-all-files. A skill with 250-line SKILL.md + five 100-line references is fine — peak load is ~350 lines, not 750

**How to estimate instruction density:**
Count lines that are: table rows with check actions, numbered/bulleted process steps, code blocks, report templates, Rules items. For domain-agnostic skills, also count domain examples that define execution scope (e.g., showing how a check applies to video or research projects). Divide by total non-blank lines. If the ratio is below 0.6, look for explanatory paragraphs that can be compressed or moved to README.

## Content Splitting Rules

**SKILL.md is the index and decision tree. References are the knowledge base.**

- SKILL.md answers: *what to do, in what order, under what conditions*
- References answer: *what specifically to check, how to check it, how to judge the result*

Split content into a reference file when it meets ALL three criteria:
1. **Large enough** — the section exceeds 80 lines of domain-specific content (check tables, format specs, templates)
2. **Single responsibility** — the content covers one coherent concern that can be understood on its own
3. **Different change cadence** — you'd update this content independently of the process flow

**Do NOT split** when content is small (<80 lines), tightly coupled to the process flow (report templates, decision tables), or would require the reader to constantly jump back to SKILL.md.

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
├── scripts/              # optional, executable utilities
├── MAINTENANCE.md        # optional, maintenance playbook for skill maintainers
├── README.md             # required for GitHub
├── LICENSE               # required for GitHub (default: MIT)
└── .gitignore
```

- SKILL.md at repo root — `npx skills add` discovers root SKILL.md first
- References: one level deep from SKILL.md. Add a TOC at 100+ lines
- MAINTENANCE.md: update triggers, verification steps, changelog. Not loaded at runtime — serves maintainers, not the executing agent
- Delete empty directories (don't create scripts/, references/, or assets/ if unused)

### Directory Taxonomy

**`references/`** — Domain knowledge loaded on-demand by the AI to make decisions. Checklists, format specs, evaluation criteria, rules.

**`assets/`** — Static resources the AI consumes as raw material for output. Templates (to fill placeholders), data files, schemas, images.

**`scripts/`** — Executable code the AI runs. Generators, validators, CLI tools.

**Repo infrastructure** — Files serving GitHub/publishing, not skill runtime: README.md, LICENSE, CONTRIBUTING.md, .gitignore, MAINTENANCE.md, docs/, examples/, package.json, requirements.txt.

The Agent Skills open standard names three skill directories: `references/`, `assets/`, `scripts/`. Additional directories (like `templates/`, `docs/`, `examples/`) are tolerated by the spec but non-standard. During validation (Step 3), flag non-standard directory names and suggest the canonical mapping: templates → assets, docs/examples → repo infrastructure.

## Cross-Platform Compatibility

For maximum portability:
- Use only standard frontmatter fields (name, description, license, compatibility, metadata)
- Avoid CC-specific extensions unless the skill truly needs them
- README.md serves as the human-readable + other-AI-tool-readable entry point
- Skill's core knowledge in SKILL.md body is platform-agnostic markdown

## Skill Relationships

### Self-Containment

Each skill must function when installed alone — this is the Agent Skills spec norm. **"Functions alone" ≠ "exists alone."** Skills can be bundled, referenced, and recommended together. Multi-skill repos are common (WordPress ships 13 skills, Vercel ships 5). The only engineering requirement: each skill must be functional when installed individually.

### Referencing Other Skills

Skills can freely reference and recommend other skills, methodologies, and tools. This is encouraged — it's how the ecosystem grows.

**Do:**
- Mention recommended or related skills in README with install commands
- Reference methodologies in SKILL.md body (e.g., "consider using rules-as-skills for this")
- Bundle related skills in the same repo for convenience
- Recommend companion skills that enhance one specific step in your skill

**Don't:**
- Auto-install other skills without user consent
- Make your skill crash or error when a referenced skill isn't installed
