# Publishing Strategy

## TOC

- [Terminology](#terminology)
- [Skill (Single Repo)](#skill-single-repo)
- [Collection (Multi-Skill Repo)](#collection-multi-skill-repo)
- [Kit (Recommended for Multiple Skills)](#kit-recommended-for-multiple-skills)
- [Catalog (Org Directory)](#catalog-org-directory)
- [Decision Framework](#decision-framework)
- [Directory Standards](#directory-standards)

## Terminology

| Term | Definition | Repo naming |
|------|-----------|------------|
| **Skill** | One capability, one repo. The atomic unit. | `<org>/<skill-name>` |
| **Kit** | A curated bundle of independent skills for a specific workflow. | `<org>/<domain>-kit` |
| **Collection** | Multiple skills in one repo. Simpler but skills are locked together. | `<org>/<domain>-skills` |
| **Catalog** | Org-level directory listing all available skills. README only. | `<org>/skills` |

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

## Collection (Multi-Skill Repo)

Multiple skills in one GitHub repo. Used when skills are always consumed together.

**Note:** Consider whether a Kit (below) better fits your needs. Collections lock skills to a single repo — they can't appear in other Kits without duplication. If your skills might be consumed in different combinations, use a Kit instead. See `references/skill-composition.md` for detailed guidance.

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

## Kit (Recommended for Multiple Skills)

Independent repos for each skill + a Kit repo that bundles them for a specific workflow. The recommended default when publishing multiple skills.

**Structure:**

```
Independent repos (primary):
  <org>/self-review        ← own README, own stars, own SEO
  <org>/skill-forge
  <org>/rules-as-skills

Kit repo:
  <org>/authoring-kit
  ├── README.md            ← what workflow this Kit supports
  ├── install.sh           ← one-command installer
  └── LICENSE
```

Each Kit is a **view over independent skill repos**, not a container. The same skill can appear in multiple Kits — this enables multi-to-multi distribution.

**Best for:**
- Skills that may be consumed in different combinations
- Same skill needed in multiple workflows or product domains
- Skills with different release cycles or maintainers
- Maximizing both individual discoverability and collective brand presence

**Advantages:**
- Each skill has its own GitHub presence (stars, issues, README)
- Skills can appear in multiple themed Kits (multi-to-multi)
- Users discover individual skills via search → low friction install
- Users discover Kits via README → curated experience
- AI agents read Kit README to understand what to install

**Kit naming:** `<problem-domain>-kit`. The domain should tell a stranger what workflow this Kit supports.

For Kit templates (README + install.sh), see `references/skill-composition.md`.

## Catalog (Org Directory)

An org-level directory listing all available skills and Kits. Contains no skill code — just a README.

**Structure:**
```
<org>/skills
└── README.md            ← lists all skills + Kits with descriptions + install commands
```

**Template:**
```markdown
# <org> Skills

> All agent skills by <org>.

| Skill | Description | Install |
|-------|-------------|---------|
| [self-review](https://github.com/<org>/self-review) | 4-pillar alignment audit | `npx skills add <org>/self-review` |
| [skill-forge](https://github.com/<org>/skill-forge) | Create and publish skills | `npx skills add <org>/skill-forge` |

| Kit | Description | Install |
|-----|-------------|---------|
| [authoring-kit](https://github.com/<org>/authoring-kit) | Everything for skill authoring | `curl -fsSL .../install.sh \| bash` |

All skills are [Agent Skills](https://agentskills.io) compatible.
```

## Decision Framework

```
How many skills are you publishing?

1. Just one skill?
   → Skill (one repo, default)

2. Multiple skills?
   → Are these skills ALWAYS consumed together, never individually?
     YES → Collection (one repo, simpler, but locked together)
     NO  → Kit (each skill gets its own repo, Kit bundles them)

3. Want an org-level directory of everything?
   → Catalog (README-only repo listing all skills + Kits)
```

Present both Kit and Collection options. The user decides. If they choose Collection, support it fully.

For detailed composition guidance (Kit templates, context budget, tooling landscape), see `references/skill-composition.md`.

## Directory Standards

`npx skills add` discovers skills in this priority order:

1. **Root SKILL.md** → single Skill repo (returns immediately)
2. **`skills/*/SKILL.md`** → Collection (lists all for selection)
3. **Agent directories** (`.claude/skills/`, `.agents/skills/`, etc.) → 20+ paths checked
4. **Recursive search** (depth 5) → fallback

**Important:** `skill/` (singular) is NOT in the standard scan path. For `npx skills add` compatibility:
- Skill repos: put `SKILL.md` at repo root
- Collections: put skills in `skills/<name>/SKILL.md`
