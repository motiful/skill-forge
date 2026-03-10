# Publishing Strategy

## TOC

- [Single-Skill Repo](#single-skill-repo)
- [Multi-Skill Repo](#multi-skill-repo)
- [Hybrid Model](#hybrid-model)
- [Decision Framework](#decision-framework)
- [Directory Standards](#directory-standards)

## Single-Skill Repo

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

**Advantages:**
- Own README with focused value proposition
- Own GitHub stars and issue tracker
- Easy to share on social media ("install this one skill")
- Users install only what they need — no bundle anxiety

## Multi-Skill Repo

Multiple skills in one GitHub repo. Used by organizations with a shared product domain.

**Structure:**
```
<org>/<collection-name>/
├── skills/
│   ├── <skill-a>/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── <skill-b>/
│   │   └── SKILL.md
│   └── <skill-c>/
│       └── SKILL.md
├── README.md              # catalog of all skills
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
- Skills that share a product domain (WordPress development, Vercel deployment)
- Organizations with a team maintaining multiple skills
- Skills that work better together (shared context, complementary capabilities)

**Advantages:**
- Single repo to maintain
- Brand coherence — users see the full offering
- Shared resources (common references, shared scripts)

**Real-world examples:**
- `WordPress/agent-skills` — 13 skills for WordPress development
- `vercel-labs/agent-skills` — 5 skills for Vercel + React
- `anthropics/skills` — 17 skills for Claude API

**Caveat:** Users may be cautious installing "all skills from an org." Individual skill discovery is harder — users see the collection, not individual skills.

## Hybrid Model

Independent repos for each skill + a catalog repo that lists them all. Best of both worlds.

**Structure:**

```
Independent repos (primary):
  <org>/self-review        ← own README, own stars, own SEO
  <org>/skill-forge
  <org>/booth

Catalog repo (secondary):
  <org>/skills
  └── README.md            ← lists all skills with descriptions + install commands
```

The catalog repo contains **no skill code** — it's a human-readable directory that links to independent repos.

**Best for:**
- Authors with diverse, multi-domain skills (not all related to one product)
- Maximizing both individual discoverability and collective brand presence
- Skills that each stand alone but benefit from being listed together

**Advantages:**
- Each skill has its own GitHub presence (stars, issues, README)
- Users discover individual skills via search → low friction install
- Users discover the org via catalog → see the full collection
- No maintenance burden on the catalog (it's just a README)

**Catalog README template:**
```markdown
# <org> Skills

> All agent skills by <org>.

| Skill | Description | Install |
|-------|-------------|---------|
| [self-review](https://github.com/<org>/self-review) | 4-pillar alignment audit | `npx skills add <org>/self-review` |
| [skill-forge](https://github.com/<org>/skill-forge) | Create and publish skills | `npx skills add <org>/skill-forge` |
| ... | ... | ... |

All skills are [Agent Skills](https://agentskills.io) compatible.
```

## Decision Framework

```
How many skills are you publishing?

1. Just one skill?
   → Single-skill repo (default)

2. Multiple skills, same product domain?
   (e.g., all related to WordPress, all related to your API)
   → Multi-skill repo

3. Multiple skills, diverse topics?
   (e.g., audit tool + publishing tool + browser tool)
   → Hybrid: independent repos + catalog

4. Already have independent repos, want collective presence?
   → Add a catalog repo alongside existing repos
```

## Directory Standards

`npx skills add` discovers skills in this priority order:

1. **Root SKILL.md** → single-skill repo (returns immediately)
2. **`skills/*/SKILL.md`** → multi-skill repo (lists all for selection)
3. **Agent directories** (`.claude/skills/`, `.agents/skills/`, etc.) → 20+ paths checked
4. **Recursive search** (depth 5) → fallback

**Important:** `skill/` (singular) is NOT in the standard scan path. For `npx skills add` compatibility:
- Single-skill repos: put `SKILL.md` at repo root
- Multi-skill repos: put skills in `skills/<name>/SKILL.md`
