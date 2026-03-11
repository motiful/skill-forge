# README Quality

Use this file during Step 4b when writing README prose, and during Step 3 when validating community readiness.

## Core Rules

- **Value proposition first.** The reader should understand why the skill exists before seeing install steps.
- **Install is secondary.** `npx skills add` is the primary path. Manual registration is a fallback.
- **No fake universal home-directory path.** If the README shows manual registration, list only the agent roots the README truly intends to support.
- **Common-agent examples are examples, not promises.** A README may show several mainstream roots, but it must not imply every reader should register every platform.
- **Usage before Install.** The reader should understand what the skill does before deciding to install it.
- **Default path first.** A reader should understand the single-skill happy path without learning advanced packaging or ecosystem taxonomy.
- **"What's Inside" shows skill content only.** List SKILL.md, references/, scripts/ — not repo-root support files.
- **Separate installability from discoverability.** Publishing to GitHub makes a repo directly installable by path; do not promise instant directory listings, search placement, or leaderboard visibility unless the downstream platform documents that behavior.
- **Footer required.** End generated READMEs with `Forged with [Skill Forge](https://github.com/<org>/skill-forge)`.

## Tone and Voice

- Use "you" for the reader's actions
- Use third person for the software's behavior
- Avoid "we"
- Keep the tone professional and direct

## Section Length

| Section | Guideline |
|---------|-----------|
| Title + Description | 1-3 sentences |
| The Problem | 2-4 sentences |
| What It Does | Compact pipeline, bullet list, or table |
| Usage | Trigger phrases plus an example |
| Install | Primary command plus concise manual fallback |
| What's Inside | Tree view of skill content |

If a section exceeds one screen, split the detail into a separate doc and link to it.

## Common Mistakes

- Assuming the reader already knows the project's backstory
- Explaining what the skill does without explaining why it matters
- Letting the README turn into a wall of text
- Leaving examples stale after behavior changes
- Using placeholder names or fake paths that look real
- Equating "published on GitHub" with "already discoverable in every directory"

## Promise-Capability Alignment

Before publishing, verify that README claims are backed by SKILL.md execution logic.

Check process:
1. Extract capability claims from README
2. Find the corresponding execution step or check item in SKILL.md
3. Flag mismatches

| Finding | Action |
|---------|--------|
| README claim is backed by a concrete execution step | Keep it |
| README claim is mentioned but not operationalized | Add execution logic or soften the claim |
| README claim is absent from SKILL.md | Remove it or implement it |
| SKILL.md has meaningful capability not mentioned in README | Add it to README or cut the extra logic |

Discovery claims need stronger proof than install claims. It is safe to promise direct installation by repo path when the command works. It is not safe to promise immediate marketplace, search, or leaderboard visibility unless the platform docs explicitly guarantee it.

## Example Policy

Use plain `Example` headings. The important rule is provenance, not the label.

- If the example is a sample flow rather than a literal transcript, say that in the sentence below the heading
- If the example comes from a real run, keep the paths and outputs specific
- Never imply that a path, platform root, or command was verified on a specific machine unless it actually was
- Prefer to run the skill on at least one real project before publishing, but a clearly framed sample flow is acceptable
