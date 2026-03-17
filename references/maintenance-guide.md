# Maintenance Guide

How to write MAINTENANCE.md for skill repositories. This reference tells skill-forge when and how to generate one.

## What MAINTENANCE.md Is

A maintenance playbook for skill maintainers (human or AI). Answers: "How do I keep this skill working over time?"

- Not loaded at runtime — serves maintainers, not the executing agent
- Not user-facing — users read README, not MAINTENANCE.md
- Not a duplicate of SKILL.md — says HOW to maintain, not WHAT the skill does

## When to Create

Generate MAINTENANCE.md when the skill meets **any** of these:

| Condition | Why it needs maintenance |
|-----------|------------------------|
| 3+ external dependencies (tools, skills, APIs) | Versions change, APIs deprecate |
| References platform-specific paths | Platforms update their skill directories |
| Has `scripts/` directory | Scripts need update instructions and permission docs |
| SKILL.md body > 300 lines | Complexity warrants a consistency checklist |
| Reads external data sources or URLs | Data formats and endpoints change |

**Skip** for simple skills: single-purpose, no dependencies, < 200 line SKILL.md.

## Required Sections

### 1. Purpose Statement

Who this file is for and when to read it. Two lines max.

```markdown
This file is for the agent maintaining <skill-name> — not for users or the runtime agent.
Trigger: "update <skill-name>", "refresh <skill-name>", or during self-review.
```

### 2. Update Triggers

Table of events that should prompt a maintenance pass. Map each event to specific files to check.

```markdown
| Event | What to check |
|-------|--------------|
| <dependency> releases new version | <affected files> |
| <platform> changes skill paths | <affected files> |
| SKILL.md content changes | README alignment, version badge |
```

### 3. Verification Steps

How to confirm the skill still works after changes. Include cross-file consistency checks.

```markdown
1. Run skill-forge Review on this repo
2. Every README claim must be backed by a SKILL.md capability
3. Every reference file listed in SKILL.md must exist and be current
```

### 4. Changelog

Recent changes. Keep max 5 entries, trim oldest.

```markdown
## Changelog (max 5 entries)
- YYYY-MM-DD: **vX.Y — Summary.** Details.
```

## Recommended Sections

Add these when applicable:

| Section | When to include |
|---------|----------------|
| **Dependency update instructions** | Skill has 3+ dependencies with their own release cycles |
| **Contribution criteria** | Skill has collaborators or accepts PRs |
| **Self-governance** | Skill has self-referential capabilities (e.g., skill-forge validates itself) |
| **Consistency checks** | Multiple files must stay aligned (SKILL.md ↔ README ↔ references) |

## Anti-Patterns

- Don't duplicate SKILL.md content — maintain ≠ describe
- Don't include runtime instructions — MAINTENANCE.md is never loaded during execution
- Don't put user-facing information here — that belongs in README
- Don't make it a changelog-only file — the changelog is one section, not the whole file
