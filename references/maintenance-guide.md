# Maintenance Guide

How to generate a maintenance-rules skill for complex skill repositories. This reference tells skill-forge when and how to create one.

## What maintenance-rules Is

An in-repo rule-skill containing maintenance constraints and procedures. Lives in `.claude/skills/maintenance-rules/` within the skill repo.

Unlike a dead MAINTENANCE.md file, it's discoverable by AI agents through the Agent Skills loading mechanism: description is always visible, body loads on trigger.

## When to Create

Generate when the skill meets **any** of these:

| Condition | Why |
|-----------|-----|
| 3+ external dependencies (tools, skills, APIs) | Versions change, APIs deprecate |
| SKILL.md content references platform-specific paths | Platforms update directories |
| Has `scripts/` directory | Scripts need update instructions |
| SKILL.md body > 300 lines | Complexity warrants consistency checklist |
| Reads external data sources or URLs | Endpoints change |

**Skip** for simple skills: single-purpose, no dependencies, < 200 line SKILL.md.

Note: "platform-specific paths" means the SKILL.md CONTENT references paths like `~/.claude/skills/`, NOT that the skill is installed in platform directories. A simple `code-review` skill installed via symlink does not trigger this condition.

## Generated Skill Structure

```yaml
---
name: maintenance-rules
description: 'Maintenance rules for <skill-name>. MUST [constraint 1]. MUST [constraint 2]. MUST [constraint 3]. Triggers on "update <skill-name>", "maintain <skill-name>".'
metadata:
  author: <author>
---
```

Directory placement:
```
<skill-repo>/
├── .claude/skills/maintenance-rules/
│   └── SKILL.md              ← source of truth
├── .agents/skills/maintenance-rules  → relative symlink
└── .gitignore                ← .claude/* + !.claude/skills/
```

## Required Content

### 1. Constraints (top of body)

MUST/NEVER statements — the core rules for maintainers.

### 2. Update Triggers

Table: event → what files to check.

### 3. Verification Steps

How to confirm the skill still works after changes.

### 4. Changelog

Recent changes. Max 5 entries, trim oldest.

## Optional Content

| Section | When |
|---------|------|
| Dependency update instructions | 3+ dependencies with own release cycles |
| Contribution criteria | Skill has collaborators |
| Self-governance | Skill has self-referential capabilities |
| Consistency checks | Multiple files must stay aligned |

## Anti-Patterns

- Don't duplicate SKILL.md content — maintain ≠ describe
- Don't include runtime instructions — maintenance-rules is for maintainers, not users
- Don't make it a changelog-only file — constraints come first
