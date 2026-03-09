# SKILL.md Format Specification

## TOC

- [Agent Skills Open Standard](#agent-skills-open-standard)
- [Standard Frontmatter](#standard-frontmatter)
- [CC-Specific Extensions](#cc-specific-extensions)
- [Body](#body)
- [Content Splitting Rules](#content-splitting-rules)
- [File Structure](#file-structure)
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

Claude Code supports additional frontmatter fields. However, `skills-ref validate` **rejects** non-standard top-level fields. For cross-platform compatibility, put CC-specific settings inside `metadata`:

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

If you're building a CC-only skill and don't care about `skills-ref` validation, you can use the original top-level fields — CC runtime ignores unknown fields gracefully. But for publishable skills, always use `metadata`.

## Body

- Supports string substitutions: `$ARGUMENTS`, `$0`, `$1`, `${CLAUDE_SKILL_DIR}`
- Keep under 500 lines. Use progressive disclosure — put details in `references/` files
- Write for another AI agent, not a human. Include non-obvious procedural knowledge
- Only add what the AI doesn't already know. Don't explain basic concepts
- Prefer concise examples over verbose explanations

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

### Context Budget

Skill loading consumes context tokens. The total loaded content (SKILL.md + all references that get loaded) should be proportional to the skill's complexity.

**Guidelines:**
- SKILL.md body: under 500 lines (the always-loaded ceiling)
- Individual reference file: under 200 lines (if larger, split further or add TOC)
- **Instruction density**: at least 60% of lines should be executable instructions (check tables, rules, process steps, templates). Below 60% suggests excessive explanation
- References are **loaded on-demand** — the agent reads them only when the process flow requires it. Budget is per-file, not sum-of-all-files. A skill with 250-line SKILL.md + five 100-line references is fine — peak load is ~350 lines, not 750

**How to estimate instruction density:**
Count lines that are: table rows with check actions, numbered/bulleted process steps, code blocks, report templates, Rules items. Divide by total non-blank lines. If the ratio is below 0.6, look for explanatory paragraphs that can be compressed or moved to README.

## Content Splitting Rules

**SKILL.md is the index and decision tree. References are the knowledge base.**

- SKILL.md answers: *what to do, in what order, under what conditions*
- References answer: *what specifically to check, how to check it, how to judge the result*

Split content into a reference file when it meets ALL three criteria:
1. **Large enough** — the section exceeds 80 lines of domain-specific content (check tables, format specs, templates)
2. **Single responsibility** — the content covers one coherent concern that can be understood on its own
3. **Different change cadence** — you'd update this content independently of the process flow

**Do NOT split** when content is small (<80 lines), tightly coupled to the process flow (report templates, decision tables), or would require the reader to constantly jump back to SKILL.md.

**Index quality checklist:**
- Every reference pointer in SKILL.md states what the reference contains and when to read it
- Conditional references have explicit gateways: "If X applies → see references/Y.md"
- Always-needed references have direct pointers: "Detailed checks are in references/Y.md"
- SKILL.md alone tells the AI the complete process flow — references fill in domain details

**Thresholds:**
- SKILL.md body: under 500 lines
- Individual reference file: under 200 lines (include TOC if over 100 lines)
- Budget is per-file (peak load), not sum-of-all-files — references load on-demand
- Don't split a 300-line skill into 6 tiny files — splitting has overhead too

## File Structure

```
skill-name/
├── skill/
│   ├── SKILL.md              # required
│   ├── references/           # optional, loaded on demand
│   └── scripts/              # optional, executable utilities
├── README.md                 # required for GitHub
├── LICENSE                   # required for GitHub (default: MIT)
└── .gitignore
```

- References: one level deep from SKILL.md. Large files (>100 lines) get a TOC
- Delete empty directories (don't create scripts/ or references/ if unused)

## Cross-Platform Compatibility

For maximum portability:
- Use only standard frontmatter fields (name, description, license, compatibility, metadata)
- Avoid CC-specific extensions unless the skill truly needs them
- README.md serves as the human-readable + other-AI-tool-readable entry point
- Skill's core knowledge in SKILL.md body is platform-agnostic markdown
