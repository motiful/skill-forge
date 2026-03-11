# Publishing Strategy

## TOC

- [Terminology](#terminology)
- [Skill (Single Repo)](#skill-single-repo)
- [Recommend (Loose Enhancement)](#recommend-loose-enhancement)
- [Collection (Multi-Skill Repo)](#collection-multi-skill-repo)
- [Kit (Workflow Bundle)](#kit-workflow-bundle)
- [Decision Framework](#decision-framework)
- [Directory Standards](#directory-standards)

## Terminology

| Term | Definition | Repo naming |
|------|-----------|------------|
| **Skill** | One capability, one repo. The atomic unit. | `<org>/<skill-name>` |
| **Recommend** | Independent skills that hint at each other. No bundle, no install script — just `[!TIP]` blocks in SKILL.md. | Each skill keeps its own repo |
| **Kit** | A curated bundle of independent skills for a specific workflow. Has install.sh. | `<org>/<domain>-kit` |
| **Collection** | Multiple skills in one repo. Simpler but skills are locked together. | `<org>/<domain>-skills` |

These form a spectrum from loosest to tightest coupling:

```
Skill → Recommend → Kit → Collection
(standalone)   (loose enhancement)   (bundle distribution)   (same-repo lock-in)
```

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

## Recommend (Loose Enhancement)

Independent skills that work alone but work better together. No shared repo, no install script — each skill stays in its own repo and uses `[!TIP]` blocks to point to recommended skills.

**Structure:**

Each skill is a standalone repo. The only connection is an inline hint:

```markdown
> [!TIP]
> **Enhanced <capability>**: If `<recommended-skill>` is installed, it provides
> <specific enhancement>.
> Install: `npx skills add <org>/<recommended-skill>`
> Without it, <what happens — must be a complete, working fallback>.
```

**Rules:**
- The skill MUST work fully without the recommended skill. "Without it" must describe real behavior, not a degraded stub.
- Maximum 2 recommend tips per skill (context budget).
- Place the tip at the step where the recommended skill would activate, not at the top of the file.
- Mirror the same recommended skills in README with a short human-facing section (for example, "Works Better With").
- Each skill is independently installable, discoverable, and star-able.

**Best for:**
- Skills that enhance each other but have independent value (e.g., readme-craft enhances skill-forge's Step 4, but readme-craft is useful without forge)
- Different release cycles or maintainers
- When a Kit would be overkill (only 2-3 skills, no shared workflow narrative)

**Comparison with Kit:**

| | Recommend | Kit |
|---|----------|-----|
| Coupling | None — inline hints only | Loose — shared install.sh |
| Install | User installs each individually | `curl install.sh` installs all |
| Discovery | Each skill found independently | Kit README lists all |
| When to upgrade | 2-3 skills, casual "works better together" | 4+ skills, or a coherent workflow story |

**When forge creates a skill:** If the user's skill would benefit from recommended skills, bake in `[!TIP]` blocks following the pattern above and mirror them in README. This is the recommend capability that forge offers — it helps users express "works better together" without creating a Kit.

## Collection (Multi-Skill Repo)

Multiple skills in one GitHub repo. Used when skills are always consumed together.

**Note:** Consider whether a Kit (below) better fits your needs. Collections lock skills to a single repo — they can't appear in other Kits without duplication.

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

Present both Kit and Collection options. The user decides. If they choose Collection, support it fully.

## Kit (Workflow Bundle)

Independent repos for each skill + a Kit repo that bundles them for a specific workflow. Use this when Recommend is too loose and Collection is too locked together.

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

Each Kit is a **view over independent skill repos**, not a container. The same skill can appear in multiple Kits — this enables multi-to-multi distribution:

```
self-review  ──→  authoring-kit
skill-forge  ──→  authoring-kit
self-review  ──→  quality-kit
lint-rules   ──→  quality-kit
```

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

### Kit Naming

`<problem-domain>-kit`. The domain should tell a stranger what workflow this Kit supports.

An org-wide Kit (listing everything by one org) is just a Kit with broad scope — name it `<org>/skills` or `<org>/<org>-kit`.

### install.sh Template

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Installing <kit-name> skills..."
echo ""

skills=(
  "<org>/skill-a"
  "<org>/skill-b"
  "<org>/skill-c"
)

for skill in "${skills[@]}"; do
  echo "→ $skill"
  npx skills add "$skill" -y
done

echo ""
echo "✓ All skills installed."
```

### README Template

````markdown
# <Kit Name>

> <One line: what workflow this Kit supports>

## What's Included

| Skill | Description | Standalone install |
|-------|-------------|--------------------|
| [skill-a](<url>) | ... | `npx skills add <org>/skill-a` |
| [skill-b](<url>) | ... | `npx skills add <org>/skill-b` |
| [skill-c](<url>) | ... | `npx skills add <org>/skill-c` |

## Install All

```bash
curl -fsSL https://raw.githubusercontent.com/<org>/<kit>/main/install.sh | bash
```

Or install individually — each skill works on its own.

## Why These Together

<2-4 sentences explaining why this combination is useful>
````

For the philosophy behind composition (context budget, ecosystem), see `references/skill-composition.md`.

## Decision Framework

```
How many skills are you publishing?

1. Just one skill?
   → Skill (one repo, default)
   → Does it recommend other skills?
     YES → Add [!TIP] recommend blocks (see Recommend section)
     NO  → Done

2. Multiple skills?
   → Do they each have independent value?
     NO  → Collection (one repo, locked together)
     YES → How many, and is there a workflow story?
       2-3 skills, casual enhancement → Recommend (each gets own repo, [!TIP] hints)
       4+ skills, or a coherent workflow → Kit (own repos + Kit bundle repo)
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
