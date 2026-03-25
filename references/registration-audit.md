---
name: registration-audit
description: Pre-registration conflict detection for skill developers. Checks workspace-level registrations that shadow global ones, broken symlinks to owned skills, and real copies instead of symlinks. Scoped to skills the developer owns (source under config.skill_root). Does not audit consumer-installed skills.
---

```
audit_registrations(item, config) → findings[]

owned = skills whose resolved target is under config.skill_root
for each platform root (global + project-level):
    project_skills = scan(item.project_root / platform_root)
    global_skills = scan(~ / platform_root)
    overlap = project_skills ∩ global_skills (by name, owned only)
    for skill in overlap:
        if resolve(project) == resolve(global):
            if is_published(skill, config) → Warning: duplicate, remove project-level
            else → Info: unpublished, publish first then clean up
        if resolve(project) != resolve(global) → Critical: same name, different source
for each owned skill across all roots:
    if broken symlink → Warning
    if real directory and not in-repo → Warning: copy, not link
report findings (HITL)
if critical and unresolved → block registration
```

# Registration Audit

Pre-registration conflict detection scoped to skills the developer maintains.

## Scope

**Audits only skills the developer owns.** Ownership is determined by resolving symlink targets:

```
is_owned(skill_path, config) → bool
    target = resolve(skill_path)     # readlink -f
    return target starts with config.skill_root
```

`config.skill_root` is read from `~/.config/skill-forge/config.md` (set during onboarding).

Skills whose resolved target is outside `skill_root` are consumer-installed (the developer uses them but doesn't maintain them). **Skip these entirely** — skill-forge serves skill developers, not skill consumers.

## Three Valid Registration States

| State | Location | Example | How team gets it |
|-------|----------|---------|-----------------|
| **In-repo** | `<project>/.claude/skills/X/` (real directory, git-tracked) | maintenance-rules in skill-forge | `git clone` — comes with the repo |
| **Global** | `~/.claude/skills/X` (symlink → `skill_root/X/`) | skill-forge, self-review | `npx skills add <org>/<name> -g` |
| **Developer source** | `<skill_root>/X/` (real git repo) | The actual repo the developer edits | `git clone` — the developer's workspace |

**Any registration that doesn't fit these three states is a violation.**

## Violations

### 1. Workspace Shadows Global

**The most common problem.** The developer's workspace root (e.g., `skill_root` itself) has project-level skill registrations (`.claude/skills/`, `.agents/skills/`) that duplicate global registrations.

```
When agent works in skill_root:
  → loads skill_root/.claude/skills/X  (project-level)
  → loads ~/.claude/skills/X           (global)
  → same skill, double context load
```

**Detection**: For each platform root, intersect project-level skills with global skills (owned only).

| Finding | Severity | Resolution |
|---------|----------|------------|
| Same name, same resolved target | Warning | Remove project-level symlink — global is sufficient |
| Same name, different resolved target | Critical | User must decide which source is correct |

**Rule**: Project-level registration is for in-repo skills only (git-tracked, project-specific). Published skills that are globally registered must not be duplicated at project level.

### 2. Broken Symlink

An owned skill's symlink target no longer exists (source directory deleted or moved).

| Finding | Severity | Resolution |
|---------|----------|------------|
| Symlink target does not exist | Warning | Remove broken link, or fix target path |

**Detection**: `[ -e "$(readlink -f "$path")" ]` fails.

### 3. Copy Instead of Symlink

An owned skill is registered as a real directory copy instead of a symlink. The copy won't receive updates when the source changes.

| Finding | Severity | Resolution |
|---------|----------|------------|
| Real directory (not symlink) for an owned skill at global level | Warning | Replace with symlink to source |

**Exception**: In-repo skills (`.claude/skills/X/` inside a project repo) are always real directories — this is correct. Only flag copies at **global** registration paths.

**Detection**: `[ -d "$path" ] && ! [ -L "$path" ]` and path is a global root, not in-repo.

## When This Runs

| Trigger | Scope | Behavior |
|---------|-------|----------|
| Before `detect_and_register()` in forge Step 3 | Single skill being registered | Check if this skill would create a duplicate |
| During project audit (`forge(project_dir)`) | All skills in project | Full scan of project-level vs global |

## Team Collaboration Model

Published skills are dependencies. Teams install them the same way they install any tool:

```markdown
## Prerequisites (in project CLAUDE.md or README)
npx skills add motiful/skill-forge -g
npx skills add motiful/self-review -g
```

**Project-level registration for in-repo skills only.** External tool skills are globally installed by each team member once. This mirrors how CLI tools work — you don't commit ESLint into your repo, you declare it as a devDependency and each developer installs it.

Skill ecosystem does not yet have a `skills.json` manifest with automatic resolution. Current standard: declare in documentation, install manually once. `scripts/setup.sh` automates this for skill repos specifically.
