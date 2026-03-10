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

**Note:** Consider whether the Hybrid model (below) better fits your needs. Multi-skill repos lock skills to a single repo — they can't appear in other collections without duplication. If your skills might be consumed in different combinations, use independent repos + catalog instead. See `references/skill-composition.md` for detailed composition guidance.

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

## Hybrid Model (Recommended for multiple skills)

Independent repos for each skill + catalog repos for themed collections. The recommended default for publishing multiple skills.

**Structure:**

```
Independent repos (primary):
  <org>/self-review        ← own README, own stars, own SEO
  <org>/skill-forge
  <org>/booth

Catalog repos (secondary):
  <org>/authoring-toolkit
  ├── README.md            ← what this collection solves
  ├── install.sh           ← one-command installer
  └── LICENSE
```

Each catalog is a **view over independent skill repos**, not a container. The same skill can appear in multiple catalogs — this enables multi-to-multi distribution.

**Best for:**
- Skills that may be consumed in different combinations
- Maximizing both individual discoverability and collective brand presence
- Same skill needed in multiple product domains
- Skills with different release cycles or maintainers

**Advantages:**
- Each skill has its own GitHub presence (stars, issues, README)
- Skills can appear in multiple themed catalogs (multi-to-multi)
- Users discover individual skills via search → low friction install
- Users discover collections via catalog → curated experience
- AI agents read catalog README to understand what to install

**Catalog naming:** `<problem-domain>-toolkit` or `<problem-domain>-kit`. Not `<org>-skills` (too vague).

For catalog templates (README + install.sh), see `references/skill-composition.md`.

## Decision Framework

```
How many skills are you publishing?

1. Just one skill?
   → Single-skill repo (default)

2. Multiple skills?
   → Do these skills ALWAYS get consumed together, never individually?
     YES → Multi-skill repo (simpler, but skills are locked to this repo)
     NO  → Independent repos + catalog (recommended)
           Each skill gets its own repo. Catalog bundles them.

3. Already have independent repos, want themed collections?
   → Create catalog repos (README + install.sh)
     Same skill can appear in multiple catalogs.
```

For detailed composition guidance (catalog templates, context budget, tooling), see `references/skill-composition.md`.

## Directory Standards

`npx skills add` discovers skills in this priority order:

1. **Root SKILL.md** → single-skill repo (returns immediately)
2. **`skills/*/SKILL.md`** → multi-skill repo (lists all for selection)
3. **Agent directories** (`.claude/skills/`, `.agents/skills/`, etc.) → 20+ paths checked
4. **Recursive search** (depth 5) → fallback

**Important:** `skill/` (singular) is NOT in the standard scan path. For `npx skills add` compatibility:
- Single-skill repos: put `SKILL.md` at repo root
- Multi-skill repos: put skills in `skills/<name>/SKILL.md`
