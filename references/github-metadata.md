---
name: github-metadata
description: GitHub repository metadata management including About/description rules (≤350 chars, alignment with README and SKILL.md), topic selection via 3-tier system (big traffic, domain-precise, ecosystem), and .github/repo-meta.yml format specification.
---

```
validate_and_apply(repo_path) → applied | findings[]

check: .github/repo-meta.yml exists and matches template format
check: description exists, len <= 350, aligns with README + SKILL.md
check: 8 <= topics <= 20, follow 3-tier system
assert no critical findings
report findings to user (HITL)
apply via gh repo edit
```

# GitHub Metadata

Source of truth: `.github/repo-meta.yml` in the skill repo root.

## `.github/repo-meta.yml` Format

```yaml
description: >
  One or two sentences. Max 350 chars.
topics:
  # Tier 1: big traffic
  - ai
  - llm
  # Tier 2: domain-specific (from Deep Research)
  - agent-skills
  # Tier 3: ecosystem
  - claude-code
homepage: ""  # fill when site exists
```

## About / Description

- Max 350 characters. GitHub silently truncates beyond this.
- Format: `[What it does] for [who]. [Key differentiator].` — one or two sentences.
- Must align with the README one-liner and SKILL.md `description` field. If they diverge, reconcile before publishing.
- Value proposition, not feature list. No bullet points, no version numbers.
- Do not repeat the repo name — GitHub already displays it above the description.

## Topic Selection

3-tier system. Target 12-18 topics total. Hard max 20 (GitHub enforced).

### Tier 1: Big Traffic (3-5 tags)

Universal tags every AI agent skill should have:
`ai`, `llm`, `ai-agents`, `developer-tools`

Add or remove only if the skill genuinely does not fit a tag (e.g., a non-dev-facing skill drops `developer-tools`).

### Tier 2: Precise Track (4-6 tags)

Domain-specific tags that match the skill's actual function.

1. Search `"<domain> github topics {current_year}"` to find trending tags.
2. Check each candidate: does the topic have >500 repos on GitHub? If not, skip.
3. Present 5-8 candidates to the user for confirmation. Do not auto-select.
4. Examples for a skill engineering tool: `agent-skills`, `skills`, `agentic-ai`, `context-engineering`, `prompt-engineering`.

### Tier 3: Ecosystem / Platform (3-5 tags)

- Platform tags (`claude-code`, `codex`, `cursor`, `windsurf`, `github-copilot`) — only when the skill actually supports that platform. Check SKILL.md compatibility or platform-registry references.
- Brand/tool tags (`ai-tools`, `automation`) — only when the brand IS a real discovery channel (>1000 repos on that topic on GitHub).

## Push-Time Workflow

```
meta = read(".github/repo-meta.yml")
assert meta.description exists and len(meta.description) <= 350
assert 8 <= len(meta.topics) <= 20
for topic in meta.topics:
    assert topic matches /^[a-z0-9][a-z0-9-]*$/   # GitHub topic format
gh repo edit <org>/<name> \
    --description "<meta.description>" \
    --homepage "<meta.homepage>" \
    $(for t in meta.topics: --add-topic "$t")
```

If `.github/repo-meta.yml` does not exist at push time, create it interactively:
1. Draft description from SKILL.md `description` field, trimmed to 350 chars.
2. Apply Tier 1 defaults. Research and propose Tier 2 candidates. Detect Tier 3 from platform-registry.
3. Write the file, commit, then proceed with push.
