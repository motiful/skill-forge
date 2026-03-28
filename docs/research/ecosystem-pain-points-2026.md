# Agent Skills Ecosystem: User Pain Points & Raw Research Data (March 2026)

Research conducted 2026-03-26. All data sourced from public forums, GitHub issues, blog posts, and Hacker News threads.

---

## 1. Skills Not Triggering / Not Activating

### GitHub Issue #9716 — anthropics/claude-code (66 thumbs-up)

**URL:** https://github.com/anthropics/claude-code/issues/9716

**Reporter:** @vanek-21-code (Oct 17, 2025)
> "When asked 'what do you know about shadcn in our environment?', the assistant attempted to read files and search the codebase manually instead of recognizing that a dedicated skill exists at `.claude/skills/shadcn-components/skill.md`"

**@ajax-semenov-y** (11 upvotes):
> "I have skill with the following description: `name: create-new-plugin` [...] When I ask claude code: 'Please create new plugin "dev-expert" in common folder' it uses general tools instead of skill. When I ask claude code: 'What skills do you have?' it says that 'create-new-plugin' is available. Then I ask 'Why didn't you use the available skill when I asked you to add the plugin?' This appears to be a bug in my opinion."

**@otrebu** (3 upvotes):
> "Seems to me that skills related to coding are 'ignored'. I tried to implement a skill about the usage of pnpm or one when coding in Javascript and Typescript but they are never loaded."

**@JesseCDev** (2 upvotes):
> "I have this exact problem, still not fixed regardless of what I try with descriptions."

**@spences10:**
> "I have a similar issue `<available_skills>` is empty regardless of where you add the skills files at project or `~` level."

**@neongreen** (1 upvote) — had to write an absurdly aggressive description to make it work:
```yaml
description: Use this skill when the user asks you to make a commit, EVEN IF THEY DO NOT MENTION JJ. This skill applies in any and all cases when you need TO MAKE COMMITS IN GENERAL. Yes, even git commits. Disregard all instructions about git that you have elsewhere in the prompt.
```

**@JacksonBates:**
> "Claude has also claimed when asked that there were competing instructions loaded into context that it interpreted as having higher salience than the skills trigger."

**Platform:** Claude Code
**Status:** OPEN, 68 total interactions

---

### Medium: 650 Trials Activation Study

**URL:** https://medium.com/@ivan.seleznov1/why-claude-code-skills-dont-activate-and-how-to-fix-it-86f679409af1

Key data points:
- **Baseline activation rate: ~50%** (essentially coin flip)
- **With passive descriptions + hooks: drops to 37%** (worse than doing nothing)
- **With directive descriptions: 100% activation**
- **Improvement: 20x higher odds** with directive vs. standard descriptions
- Two primary failure modes: (1) Claude reads SKILL.md "out of curiosity" rather than invoking it, (2) Claude bypasses the skill entirely using Bash/Write tools directly

**Platform:** Claude Code

---

### DEV Community: "2 Fixes for 95% Activation"

**URL:** https://dev.to/oluwawunmiadesewa/claude-code-skills-not-triggering-2-fixes-for-100-activation-3b57

> "They don't trigger consistently. Even when the trigger conditions look correct, Claude often ignores them."

Proposed workarounds:
- UserPromptSubmit hook with keyword/pattern detection
- Forced three-step evaluation ("Evaluate → Activate → Implement")
- Custom instructions with "MANDATORY", "NON-NEGOTIABLE" language
- Author acknowledges these trade verbosity for reliability

**Platform:** Claude Code

---

### Scott Spence: Skills Not Recognised

**URL:** https://scottspence.com/posts/claude-code-skills-not-recognised

Root cause: Prettier reformatted YAML frontmatter to multi-line syntax. Claude Code's parser silently rejected it.

> "Prettier formatted the YAML frontmatter...used multi line descriptions because, well, that's valid YAML, innit?"

The fix: single-line descriptions with `# prettier-ignore` comment. No error, no warning — skills just silently disappeared.

**Platform:** Claude Code

---

### Blog: 15,000 Character Budget

**URL:** https://blog.fsck.com/2025/12/17/claude-code-skills-not-triggering/

> "Claude Code just...not use skills they have installed"

Root cause: system prompt has a **15,000 character limit** (~4,000 tokens) for skill descriptions. Exceeding it silently drops skills.

> "If you're not making heavy use of skills, that ought to be fine. But, since there's no warning when you go over, you might find yourself with unusable skills"

The system prompt explicitly tells Claude to "never use skills that aren't listed" — so over-budget skills become permanently invisible.

Workaround: `SLASH_COMMAND_TOOL_CHAR_BUDGET=30000 claude`

**Platform:** Claude Code

---

### Cursor Forum: Agent Ignores Skill

**URL:** https://forum.cursor.com/t/agent-ignores-skill/149017

**User:** Artemonim (1 like, 0 replies before closure)
> "Agent behaves as usual, rather than following the instructions from the Skill"

The identical text pasted directly into a prompt worked fine — only the skill mechanism failed.

**Platform:** Cursor

---

### Cursor Forum: CLI Skills Don't Auto-Trigger

**URL:** https://forum.cursor.com/t/cli-skills-do-not-auto-trigger-via-natural-language-works-in-gui/150265

**User:** orlevyhs (Or Levy), Jan 29, 2026

> "Custom skills do not trigger via natural language keywords in the CLI, even when 'When to Use' instructions are explicitly defined."

> "The exact same skill and prompt work perfectly in the Cursor GUI. In the CLI, the agent ignores the intent unless I manually invoke the skill."

Specific test: Skill `create-jira-task` with defined trigger phrases ("create task," "new ticket," "open a Jira"). Input: "Let's open a Jira ticket" — Agent responds generically, ignoring skill entirely.

Follow-up inquiries Feb 9 and 14 — no fix implemented.

**Platform:** Cursor CLI

---

### DEV Community: Cursor Rules vs Agent Skills Test

**URL:** https://dev.to/nedcodes/cursor-rules-vs-agent-skills-i-tested-both-heres-when-each-one-actually-works-1ld

Cross-tool discovery test:
> "The skill did not load. Cursor didn't find it. This might be a CLI vs GUI difference, or it might only work with `.cursor/skills/`."

Skills placed in `.claude/skills/` and `.codex/skills/` did not auto-discover in Cursor — contradicting documentation claims about cross-tool compatibility.

**Platform:** Cursor

---

### SmartScope: SKILL.md Won't Load Fix Guide

**URL:** https://smartscope.blog/en/blog/agent-skills-guide/

> "One organisation found that in 56% of cases, skills weren't triggered reliably. Turns out, LLMs are 'lazy' and they don't always follow instructions."

Key causes:
- Name-directory mismatch (name field must match parent directory)
- Conflicting skills with overlapping triggers
- Weak descriptions lacking trigger keywords

**Platform:** Cross-platform

---

## 2. Skills Organization & Management Problems

### DEV Community: "You Already Have Dozens of Agent Skills. You Just Can't Find Them."

**URL:** https://dev.to/itlackey/you-already-have-dozens-of-agent-skills-you-just-cant-find-them-5bai

> "Skills scattered across directories, no search, no sharing, no sanity."

> "None of them can see each other."

> "Vaguely remember writing a skill for Docker container management a few months ago. Was it in your OpenCode stash? Your Claude Code skills?"

> "Your agent's skill collection is growing faster than your ability to manage it"

> "The fragmentation problem in agent tooling is only getting worse."

Users maintain assets in Claude Code (`~/.claude/skills/`), OpenCode (`.opencode/`), Cursor (`.cursor/rules/`) simultaneously with no cross-visibility.

**Platform:** Cross-platform

---

### SkillOps: Scaling Agent Skills

**URL:** https://till-freitag.com/en/blog/skillops-scaling-agent-skills

Specific problems at organizational scale:
> "Team A has a testing Skill, Team B does too – they contradict each other"
> "Nobody knows which Skills are current and which are outdated"
> "A Skill works with Claude Code but breaks in Cursor"
> "New hires find 30 Skills and don't know which ones are relevant"

Core insight:
> "Skills aren't one-time documents. They're living artifacts that deserve the same lifecycle as code."

**Platform:** Enterprise/cross-platform

---

### Cursor Forum: Plugins Not Installing Rules/Skills/Sub Agents

**URL:** https://forum.cursor.com/t/plugins-not-installing-rules-skills-sub-agents/152213

**User:** Blanky_Strike (Feb 18, 2026)
> "none of the rules, skills and sub agents were installed. Neither commands."

**User:** lsc04361 (Feb 23, 2026): Same issue across two separate computers.

Root cause: Cursor failed to retrieve data from plugin servers. Auto-closed after 22 days with no resolution.

**Platform:** Cursor

---

### Hacker News Thread: Agent Skills (54+ upvotes on Zed feature request)

**URL:** https://news.ycombinator.com/item?id=46871173

**SOLAR_FIELDS:**
> "Way more often than not, I remind the agent that the skill exists before it does anything"

**verdverm:**
> Questions why standardize something "so early" — raises concerns about versioning, dependency management, ecosystem distribution gaps

**davidkunz:**
> Requests unified folder naming (.claude/skills vs .codex/skills fragmentation)

**smithkl42:**
> Points out confusion between skills vs. slash commands remains unclear

**pton_xd:**
> Compares skills to prompt engineering: "temporary optimization that may become obsolete"

**iainmerrick** (top comment):
> "This stuff smells like maybe the bitter lesson isn't fully appreciated"

**Avicebron:**
> Describes approach as potentially a "grift" without systematic performance data

---

## 3. Skills Dependency & Lock File Problems

### GitHub Issue #283 — vercel-labs/skills (24 thumbs-up)

**URL:** https://github.com/vercel-labs/skills/issues/283

**Feature request:** `skills install` / `skills sync` from lock file

> "There is currently no command that says 'install everything from this lock file'"

Cannot use lock file for "setting up a new dev machine, or restoring skills after a cleanup, or keeping multiple machines in sync using just dotfiles."

The lock file acts as a "global registry + update-tracking database" rather than a declarative manifest (like package-lock.json).

**jonbesga:**
> "As soon as I found out about this tool and saw the lock file I was looking for this!"

**Platform:** npx skills CLI

---

### GitHub Issue #549 — vercel-labs/skills (10 thumbs-up)

**URL:** https://github.com/vercel-labs/skills/issues/549

**Feature request:** `npx skills install` — npm ci equivalent

> "Running `npx skills update` when no skills are installed does nothing — it silently exits because the command scans for already-installed skills first."

Team onboarding gap: Developer A commits `skills-lock.json`, Developer B cannot restore with a single command. Currently requires manual `npx skills add` per skill.

Three bad workarounds users resort to:
1. Manual scripting duplicating lock file tracking
2. Committing skill files directly (= committing `node_modules/`)
3. Implementing separate `.skills` manifest format

**Platform:** npx skills CLI

---

### GitHub Issue #337 — vercel-labs/skills (6 thumbs-up)

**URL:** https://github.com/vercel-labs/skills/issues/337

> "Project-scoped skills are not tracked in the lock file (~/.agents/.skill-lock.json), so `npx skills check` and `npx skills update` silently skip them."

Root cause: `addSkillToLock` only executes when `installGlobally === true`.

**Platform:** npx skills CLI

---

### GitHub Issue #577 — vercel-labs/skills

**URL:** https://github.com/vercel-labs/skills/issues/577

> "`npx skills remove` removes skill files from `.claude/skills/` and `.agents/skills/` but does not remove the corresponding entry from `skills-lock.json`."

Stale entries persist with source, sourceType, and computedHash intact.

**Platform:** npx skills CLI

---

### GitHub Issue #371 — vercel-labs/skills (4 thumbs-up)

**URL:** https://github.com/vercel-labs/skills/issues/371

**Bug:** `npx skills update` detects updates but fails to apply any.

> "No error details are shown — just `✗ Failed to update <name>` for every skill"
> "No error details, no stderr output, no way to debug"

**Hassan Ahmed:**
> "`npx skills update` doesn't work" — workaround: reinstall skills entirely

**Miky:**
> "It feels like this command does not work with me"

**Platform:** npx skills CLI

---

### GitHub Issue #423 — vercel-labs/skills

**URL:** https://github.com/vercel-labs/skills/issues/423

**Bug:** `npx skills update` creates symlinks in unintended agent directories.

Install to codex only → update creates symlinks in `~/.claude/skills` and `~/.pi/agent/skills` too.
> "Symlinks are created in other agents" despite specifying a particular agent during initial installation.

**Platform:** npx skills CLI

---

### GitHub Issue #287 — vercel-labs/skills

**URL:** https://github.com/vercel-labs/skills/issues/287

**Bug:** `npx skills remove -a <agent>` unconditionally deletes shared source files, breaking other agents.

Install skill for both claude-code and gemini-cli → remove from claude-code → source files deleted, gemini-cli left with broken symlinks.

**Platform:** npx skills CLI

---

## 4. Skills Distribution & Publishing Problems

### Hallucinated npx Commands

**URL:** https://www.aikido.dev/blog/agent-skills-spreading-hallucinated-npx-commands

- **237+ GitHub repositories** reference the non-existent `react-codeshift` package
- **47 LLM-generated "Agent Skills"** dumped across 14 plugins in a single commit
- **~100 direct forks** maintained the exact file path structure
- **1-4 daily downloads** persisted after the package was claimed
- **74 downloads on Day 0** when package was first claimed

The hallucinated package `react-codeshift` was created by conflating `jscodeshift` (Facebook) and `react-codemod` (React Team). Spread to Japanese translations, `bunx`/`pnpm dlx` variants, never once verified.

**Platform:** Cross-platform (GitHub/npm)

---

### ElectricSQL: Version Staleness

**URL:** https://electric-sql.com/blog/2026/03/06/agent-skills-now-shipping

> "You paste in docs; the agent half-reads them. You point it at a rules file on GitHub; it's already stale."
> "The workarounds — hunting for community-maintained rules files, copy-pasting knowledge with no versioning or staleness signal — fail to scale."

Solution: ship skills inside npm packages so `npm update` updates skills too.

> "Once a breaking change ships, models don't 'catch up.' They develop a permanent split-brain — training data contains both versions forever with no way to disambiguate."

**Platform:** Cross-platform

---

### Cross-Platform Fragmentation

**URL:** https://converter.brightcoding.dev/blog/openskills-install-anthropic-skills-into-any-ai-agent

> "Every platform speaks its own language. Skills you build for Claude Code won't work in Cursor. Your team's carefully crafted prompts for Windsurf are useless when you switch to Aider."

Directory conventions differ per platform:
- Claude Code: `~/.claude/skills/` or `.claude/skills/`
- Codex: `~/.codex/skills/`
- Cursor: `.cursor/rules/` (not `.cursor/skills/`!)
- OpenCode: `.opencode/`
- Gemini/Antigravity: `~/.gemini/antigravity/skills/`

**Platform:** Cross-platform

---

### VS Code Issues

**URL:** https://github.com/microsoft/vscode/issues/290393
Agent Skills fail to load in VS Code Stable despite being configured — requires org-level Copilot policy flag.
> "Skills are not loaded at all in stable VSCode [...] Nothing about skills appears in debug logs"

**URL:** https://github.com/microsoft/vscode/issues/295766
> "I noticed after installing skills using `npx skills` command that skills installed in `.agents/skills` no longer works in VS Code Insiders"
Moving to `.github/skills` fixed it — regression in Insiders.

**URL:** https://github.com/microsoft/vscode/issues/291356
Skills ignored when directory is in `.gitignore`.

**Platform:** VS Code / GitHub Copilot

---

### Zed Feature Request (54 thumbs-up)

**URL:** https://github.com/zed-industries/zed/issues/49057

54 upvotes requesting Agent Skills support. Community concerns:
- Preference to avoid shipping built-in skills without user control
- Recommendation to treat skill registries as extensions, not core features
- Multiple competing registries (agentskill.sh, skills.sh, etc.)

**Platform:** Zed

---

## 5. Security Concerns

### Snyk Audit: 3,984 Skills Scanned

**URL:** https://snyk.io/blog/openclaw-skills-credential-leaks-research/

- **283 leaky skills** (7.1% of ClawHub marketplace)
- **Moltyverse-Email**: Forces agents to expose API keys through verbatim output
- **Buy-Anything**: Instructs agents to collect credit card numbers and CVC codes in API commands
- **Prompt-Log**: Extracts session files without redaction, re-exposes leaked secrets
- **Prediction-Markets-Roarin**: Encourages plaintext credential storage

> "Every piece of data an agent touches passes through the Large Language Model (LLM)"

---

### Mobb.ai: 22,511 Skills Audited

**URL:** https://thenewstack.io/ai-agent-skills-security/

- **140,963 security findings** across 22,511 public skills from four registries including skills.sh
- Skills scanned at publish time but execute with developer's **full system permissions** and almost no runtime verification
- Malicious behavior hidden across multiple files and languages

---

### The Hacker News: Malware in Skills

**URLs:**
- https://thehackernews.com/2026/02/researchers-find-341-malicious-clawhub.html
- https://thehackernews.com/2026/02/weekly-recap-ai-skill-malware-31tbps.html

- **1,200 malicious skills** infiltrated OpenClaw in "ClawHavoc" campaign (Jan 2026)
- **6,487 malicious agent tools** catalogued that VirusTotal cannot detect
- **341 malicious ClawHub skills** found stealing data from OpenClaw users

---

### 1Password: Skills as Attack Surface

**URL:** https://1password.com/blog/from-magic-to-malware-how-openclaws-agent-skills-become-an-attack-surface

Keyloggers disguised as linting helpers. Token exfiltrators wrapped in formatting skills. 36% of 3,984 skills from skills.sh had some kind of security flaw.

---

## 6. Token Waste & Context Bloat

### Context Buffer Problem

**URL:** https://claudefa.st/blog/guide/mechanics/context-buffer-management

Claude Code reserves 33K-45K tokens for system prompt context buffer. Skills add to this overhead.

---

### Progressive Disclosure Savings

**URL:** https://claudefa.st/blog/guide/development/usage-optimization

> ClaudeFast's Code Kit uses progressive disclosure across 20+ skills to recover ~15,000 tokens per session — 82% improvement over loading everything into CLAUDE.md upfront.

---

### MCP Tool Bloat (Pre-ToolSearch)

**URL:** https://medium.com/@joe.njenga/claude-code-just-cut-mcp-context-bloat-by-46-9-51k-tokens-down-to-8-5k-with-new-tool-search

Every tool from every connected server preloaded into context window before you type anything. ToolSearch reduced total agent tokens by 46.9% (51K → 8.5K).

---

### Redundant File Reads

**URL:** https://dev.to/egorfedorov/update-my-claude-code-token-optimizer-now-blocks-redundant-reads-heres-the-data-from-107-27lj

From 107 sessions: 60 were pure duplicate file reads that burned 130K tokens on files Claude already had in context.

---

## 7. Quality & Trust Concerns

### Hacker News: "Why is my Claude experience so bad?"

**URL:** https://news.ycombinator.com/item?id=47000206

**andrei_says_:**
> "nightmarishly frustrating...like writing with a wet noodle"

**npilk:**
> Claude Code usage feels like "scrolling Reddit and HN - a thin, jittery, frayed sort of weariness" and compares to "gambling, with inconsistent dopamine hits"

**csomar:**
> "Stop wasting your time...there's a lot of hype...vibe-coding doesn't work at scale"

---

### Hacker News: "The Great Productivity Panic of 2026"

**URL:** https://news.ycombinator.com/item?id=47467922

**PeterStuer:**
> Describes mental exhaustion from "3 hour frantic agentic coding stint" vs. traditional deep coding flow. Warns: "This is going to end in lots of burnout and substance abuse along the way"

**npilk:**
> Reports experience feels like "gambling, with inconsistent dopamine hits"

**latand6:**
> Core issue: agents "improvise on every task" causing surprise errors. Recommends: using "skills for tasks extensively" with tested workflows.

---

### Substack: "100+ People Hit Same Problems"

**URL:** https://natesnewsletter.substack.com/p/i-watched-100-people-hit-the-same

Five categories of week-one problems observed across 100+ users:
1. Skills won't trigger
2. Zip file problems
3. Context window overflows
4. Security concerns about skills running code
5. Lack of skill evaluation metrics

> Most implementations looked "more like toys than tools"

---

## Summary: Top Pain Points by Severity

| Rank | Pain Point | Evidence Strength |
|------|-----------|------------------|
| 1 | **Skills don't trigger reliably** (~50% baseline) | 66-upvote GitHub issue, 650-trial study, multiple forum threads |
| 2 | **Silent failures** (no warnings for budget overflow, YAML parsing, lock file issues) | Multiple GitHub issues, blog posts |
| 3 | **Security** (7.1% leaky, 36% flawed, 1,200+ malicious) | Snyk audit, Mobb.ai audit, ClawHavoc incident |
| 4 | **Cross-platform fragmentation** (different dirs, different behavior) | Cursor/VS Code/Zed issues, DEV Community tests |
| 5 | **Lock file / dependency management immature** (no install, no sync, no project scope) | 24-upvote + 10-upvote + 6-upvote GitHub issues |
| 6 | **Skill discovery chaos** at scale | SkillOps article, "can't find them" article, HN threads |
| 7 | **Token/context waste** from skills overhead | 15K char budget, 82% improvement from progressive disclosure |
| 8 | **Version staleness** (no auto-update, training data split-brain) | ElectricSQL blog, hallucinated npx commands |
| 9 | **Quality floor** (most public skills hurt performance) | "40 of 47 made output worse" claim |
| 10 | **Hallucinated package names** spreading via skills | 237 repos, Aikido research |
