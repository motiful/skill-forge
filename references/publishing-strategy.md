# Publishing Strategy

## TOC

- [Terminology](#terminology)
- [Skill (Single Repo)](#skill-single-repo)
- [Collection (Multi-Skill Repo)](#collection-multi-skill-repo)
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

### Companion Tools

If a skill works better with companion tools (other skills, CLI tools), handle it simply:

- **In SKILL.md**: mention the companion at the relevant workflow step with what it does and how to proceed without it
- **In README**: add a "Works Better With" section (max 3 companions, each with one-line description + install command)
- **State clearly** that the skill works fully on its own

Do not use this for repo-local scripts, package installs, or ordinary conditional logic — those belong in the skill's workflow steps or prerequisites.

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

## Decision Framework

```
How many skills are you publishing?

1. Just one skill?
   → Skill (one repo, default)
   → If companion tools would help, mention them inline + README
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
