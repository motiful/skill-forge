---
name: publishing-strategy
description: Three publishing models (Skill, Collection, In-Repo) with decision framework and directory standards. Covers single-skill repo structure, collection multi-skill structure, in-repo skill placement, graduation path, and npx skills add discovery priority.
---

```
decide(skill_structure) → publishing_model

if only for this repo's maintainers → in-repo (.claude/skills/)
if one skill → skill repo (default)
if multiple skills:
    if always consumed together → collection repo
    if independent → separate skill repos
```

# Publishing Strategy

## TOC

- [Terminology](#terminology)
- [Skill (Single Repo)](#skill-single-repo)
- [Collection (Multi-Skill Repo)](#collection-multi-skill-repo)
- [In-Repo (Not Independently Published)](#in-repo-not-independently-published)
- [Decision Framework](#decision-framework)
- [Directory Standards](#directory-standards)

## Terminology

| Term | Definition | Repo naming |
|------|-----------|------------|
| **Skill** | One capability, one repo. The atomic unit. | `<org>/<skill-name>` |
| **Collection** | Multiple skills in one repo. Simpler but skills are locked together. | `<org>/<domain>-skills` |

Use these terms in conversation with the user. Avoid jargon like "monorepo" or "hybrid."

## Skill (Single Repo)

One skill, one GitHub repo. This is Skill-Forge's default output.

**Structure:**
```
<org>/<skill-name>/
├── SKILL.md              # skill content (at root)
├── references/            # if needed
├── scripts/               # if needed
├── README.md
├── LICENSE
└── .gitignore
```

**Install:** `npx skills add <org>/<skill-name>`

**Best for:**
- Independent, self-contained skills
- Social media promotion (one link = one skill)
- Community discovery (own GitHub stars, own SEO)
- Low install friction (user evaluates one thing)

### Dependencies

If a skill has dependencies (other skills, CLI tools, npm packages), declare them properly:

- **In SKILL.md Step 0**: declare dependencies, run `scripts/setup.sh`
- **In README**: add a "Dependencies" section listing what gets installed
- **In `scripts/setup.sh`**: check and install each dependency

See `references/installation.md` for the full setup.sh standard.

## Collection (Multi-Skill Repo)

Multiple skills in one GitHub repo. Used when skills are always consumed together.

**Structure:**
```
<org>/<domain>-skills/
├── skills/
│   ├── <skill-a>/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── <skill-b>/
│   │   └── SKILL.md
│   └── <skill-c>/
│       └── SKILL.md
├── README.md              # lists all skills
├── LICENSE
└── .gitignore
```

**Install:**
```bash
npx skills add <org>/<collection> --skill <name>   # one skill
npx skills add <org>/<collection> --all             # all skills
npx skills add <org>/<collection>                   # interactive picker
```

**Best for:**
- Skills that are ALWAYS consumed together, never individually
- Single team, single release cycle
- One-command install is the top priority

**Real-world examples:**
- `WordPress/agent-skills` — 13 skills for WordPress development
- `vercel-labs/agent-skills` — 5 skills for Vercel + React
- `anthropics/skills` — 17 skills for Claude API

## In-Repo (Not Independently Published)

Skills that ship with a project repo. Distributed via clone/fork, not `npx skills add`.

**Structure:**
```
project-repo/
├── SKILL.md                              ← main skill (published)
├── .claude/skills/<name>/
│   └── SKILL.md                          ← in-repo skill (source of truth)
├── .agents/skills/<name>                  → relative symlink
└── .gitignore                            ← .claude/* + !.claude/skills/
```

**Best for:**
- Maintenance constraints for the repo itself
- Project-specific coding standards or security rules
- Constraints that don't generalize to other projects
- Agent project internal skills that are crucial to project function

**Important**: `.claude/skills/` as source of truth. `.agents/skills/` as relative symlink for Codex/Windsurf coverage.

**Graduation**: In-repo skill that proves generally useful can be extracted to a standalone repo.

## Decision Framework

This framework is also used by the Classification step in `references/project-audit.md`. When classifying skills found during a project audit, apply this decision tree to determine whether each skill should stay in-repo, be extracted as a standalone repo, or grouped into a collection.

```
How many skills are you publishing?

0. Is this skill only for THIS repo's maintainers/developers?
   → In-repo (in .claude/skills/)
   → Done

1. Just one skill?
   → Skill (one repo, default)
   → If dependencies exist, declare in Step 0 + setup.sh + README
   → Done

2. Multiple skills?
   → Are they always consumed together?
     YES → Collection (one repo)
     NO  → Keep as separate Skill repos
```

## Directory Standards

`npx skills add` discovers skills in this priority order:

1. **Root SKILL.md** → single Skill repo (returns immediately)
2. **`skills/*/SKILL.md`** → Collection (lists all for selection)
3. **Agent directories** (`.claude/skills/`, `.agents/skills/`, etc.) → 20+ paths checked
4. **Recursive search** (depth 5) → fallback

**Important:** `skill/` (singular) is NOT in the standard scan path. For `npx skills add` compatibility:
- Skill repos: put `SKILL.md` at repo root
- Collections: put skills in `skills/<name>/SKILL.md`
