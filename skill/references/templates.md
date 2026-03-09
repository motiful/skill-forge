# Templates

## TOC

- [README.md Template](#readmemd-template)
- [LICENSE Template (MIT)](#license-template-mit)
- [.gitignore Template](#gitignore-template)

## README.md Template

The README follows a **value-first** structure: tell the reader what problem you solve before telling them how to install.

```markdown
# <skill-name>

> <one-line value proposition — what problem this solves, not what it is>

[Agent Skills](https://agentskills.io) compatible — works with Claude Code, Cursor, Codex, Windsurf, Gemini CLI, GitHub Copilot, and more.

## The Problem

<2-4 sentences describing the pain point. Be specific — what goes wrong without this skill?>

## What <skill-name> Does

<How the skill solves the problem. Show the workflow or key capabilities. Use a code block, table, or bullet list — whichever communicates fastest.>

## Usage

<Trigger phrases, example invocations, what the user says to activate the skill. This section answers "how do I use it?" not "how do I install it?">

## Install

```bash
npx skills add <org>/<skill-name>
```

Or manually:

```bash
git clone https://github.com/<org>/<skill-name> ~/skills/<skill-name>

# Claude Code
ln -sfn ~/skills/<skill-name>/skill ~/.claude/skills/<skill-name>

# Other platforms (Cursor, Codex, Windsurf, etc.)
ln -sfn ~/skills/<skill-name>/skill ~/.agents/skills/<skill-name>
```

## What's Inside

```
skill/
├── SKILL.md              — <short description>
└── references/            — <if applicable>
    └── ...
```

## License

<license>

---

Forged with [Skill Forge](https://github.com/<org>/skill-forge)
```

### Template Rules

- **Value Proposition is first citizen.** The reader should understand *why this skill exists* within the first 10 seconds of reading.
- **Install is second citizen.** Important but not the lead. `npx skills add` is the primary method; manual clone is the fallback.
- **No per-platform install sections.** `npx skills add` handles platform detection. Manual fallback is one generic block.
- **No `/skill install` or CC marketplace references.** Those are deprecated/unsupported paths.
- **"What's Inside" shows `skill/` structure only.** Don't list repo-root files (README, LICENSE, .gitignore).
- **Usage before Install.** The reader decides to install *after* understanding what the skill does and how to use it.
- **"Forged with Skill Forge" footer.** Add a separator line + attribution link at the bottom of every generated README. Use the org from forge config: `Forged with [Skill Forge](https://github.com/<org>/skill-forge)`. This is a signature, not a dependency — the generated skill works without forge installed.

### Writing Guidelines

#### Tone and Voice

- **Use "you"** for the reader's actions: "You can configure..." not "The user should configure..."
- **Use third person** for the software's behavior: "The skill automatically detects..."
- **Avoid "we"** — ambiguous (the dev team? you and the reader?). Say "Skill Forge does X" not "We do X"
- **Professional but friendly** — like an experienced colleague explaining, not a manual or a tweet

#### Value Proposition

The first 3 lines decide whether the reader stays or leaves.

- **Headline**: one sentence, describe the **result** the user gets, not the implementation
  - Bad: "A CLI tool that wraps git commands with AI-powered commit message generation"
  - Good: "Write better commit messages in seconds, not minutes"
- **Sub-headline** (2-3 sentences): how it works, who it's for, what's different from alternatives
- **"So what?" test**: if a stranger reads only the first 3 lines, can they decide "this is/isn't for me"? If not, rewrite

#### Description vs README Intro

The SKILL.md `description` (for agents) and README intro (for humans) serve different audiences but must align:

- **description**: one line, keyword-rich, states what the skill does and when to trigger it. Written for AI agents scanning skill listings
- **README intro**: more vivid, answers "why should I care?", can use emotion and storytelling. Written for humans deciding whether to install
- **Alignment**: write the README intro first, then compress it into the description. Keywords should overlap

#### Section Length

| Section | Guideline |
|---------|-----------|
| Title + Description | 1-3 sentences. Visible in GitHub search results |
| The Problem | 2-4 sentences. Specific pain points, not abstract |
| What It Does | Compact — a pipeline diagram, bullet list, or table. Not paragraphs |
| Usage | Trigger phrases + one real example with output |
| Install | Primary: 1 command. Manual: 3-5 lines max |
| What's Inside | Tree view of skill/ only |

If a section exceeds one screen, split the detail into a separate doc and link to it.

#### Common Mistakes

- **Curse of Knowledge** — you've been in the project for weeks; the reader arrived 30 seconds ago. Don't assume shared context
- **Only What, no Why** — explaining what the skill does without saying why the reader should care
- **Wall of Text** — break content with headers, bullets, code blocks. No paragraphs longer than 4 sentences
- **Stale examples** — README examples must reflect current behavior. If the skill changes, update the example
- **Placeholder text** — use real project names and real output, not `your-project-name`

### Promise-Capability Alignment

Before publishing, verify that README claims are backed by SKILL.md execution logic.

**Check process:**
1. Extract all capability claims from README (phrases like "works for X", "supports Y", "checks Z", "handles W")
2. For each claim, find the corresponding execution step or check item in SKILL.md
3. Flag mismatches:

| Finding | Label | Action |
|---------|-------|--------|
| README claims X, SKILL.md has execution logic for X | Backed | No action |
| README claims X, SKILL.md mentions X but has no specific execution logic | Weak backing | Add concrete checks to SKILL.md or soften the README claim |
| README claims X, SKILL.md doesn't mention X at all | Promise without backing | Either add execution logic or remove the claim |
| SKILL.md has detailed logic for Y, README doesn't mention Y | Undocumented capability | Add to README or evaluate if the logic is needed |

**Common "promise without backing" patterns:**
- "Works for video/design/research projects" but all check items are code-specific
- "Handles edge cases" but no edge case detection logic exists
- "Integrates with X" but no integration steps defined

### Example Authenticity

README examples build user trust. At least one example should be from a real execution.

**Rules:**
- A skill MUST have been run at least once on a real project before publishing
- At least one README example should use real output from that run (real file paths, real findings, real numbers)
- Fictional/hypothetical examples are fine for demonstrating scenarios the author hasn't encountered — label them as "(Hypothetical)" in the header
- The real example proves "this skill actually works." The hypothetical examples show "this skill also works for your use case."

**What makes an example "real":**
- References actual file paths from a real project
- Contains specific findings that were actually discovered (not pre-written)
- Shows real metrics (line counts, pass/fail results, actual drift found)

## LICENSE Template (MIT)

```
MIT License

Copyright (c) <year> <author>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## .gitignore Template

```
.DS_Store
*.skill
node_modules/
dist/
.env
```
