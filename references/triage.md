---
name: triage
description: Pre-validation triage that distinguishes skill-shaped from workshop-shaped targets. Reads the project's directory semantics first, then either proceeds straight to audit (skill-shaped) or runs a guided dialogue to extract the skill from a chaotic engineering area (workshop). Prevents skill-forge from validating non-skill projects against gold-standard criteria.
---

# Triage

Pre-flight stage that decides what skill-forge is actually pointed at, before any validation runs.

## Why This Exists

Skill-forge's validation tables assume the target is shaped like a skill. When a user points it at an engineering area where they were *prototyping* a skill — fragments mixed with fixtures, scratch scripts, downloaded materials, language-specific source trees, `node_modules/` — validation jumps to gold-standard checks and produces noise instead of insight. The author has not yet decided what the skill IS, and skill-forge has no business grading what does not yet exist.

Triage closes this gap: understand the project's semantic layout, talk to the author about intent, extract the skill into a clean workspace, then hand off to the standard pipeline.

## Execution Procedure

```
triage(target) → {state, skill_path}

# Phase A: structural read (names, file types, header lines — no body reads, no validation)
tree = list_directory(target, depth=full)
semantics = infer_folder_purpose(tree)

# Phase B: state decision (AI judgment, no hardcoded thresholds)
state = classify_target(tree, semantics)
#   skill_shaped — SKILL.md present, references/-style layout, no extra-skill engineering
#   workshop     — skill fragments mixed with prototypes / fixtures / deps / multi-language code
#   empty        — no skill artifacts at all

if state == "skill_shaped":
    announce("This looks like a skill repo. Proceeding to audit.")
    return {state, skill_path: target}

if state == "empty":
    return {state, skill_path: None}            # falls into existing Nothing Found branch in SKILL.md STEP 1

# Phase C: workshop dialogue (HITL, options-driven, never open-ended)
map = render_semantic_map(tree, semantics)
report_to_user(map)
ask_about_unclassified(map)                     # GATE: do not proceed if any item is "I don't know what this is"

answers = ask_with_options(
    skill_scope        = options_derived_from(map.skill_candidates),
    leftover_handling  = options_derived_from(map.workshop_content),
    user_flow          = options_derived_from(map.skill_candidates)
)

if answers.user_flow == "cannot_articulate":
    stop("Skill intent unclear. Triage can scaffold structure but cannot invent product intent.")

# Phase D: extraction
new_path = extract_skill(answers.skill_scope, dest=config.skill_workspace)
annotate_workshop(target, new_path, answers.leftover_handling)
return {state: "skill_shaped_after_triage", skill_path: new_path}
```

After triage returns, skill-forge re-targets `skill_path` and continues with STEP 1 (Discover) on the extracted skill. Validation never runs against the original workshop directory.

## Workshop vs Skill-Shaped — Signals

AI judgment, not a checkbox count. Read the tree, weigh the signals, decide. Read folder names and file types first; do not open file bodies until intent is locked.

**Skill-shaped signals:**

- `SKILL.md` at root with valid frontmatter (name, description)
- `references/` directory with `.md` files only
- `scripts/` containing at most `setup.sh` and small helpers
- `README.md` written about the skill itself
- No language-specific source trees at root (`src/`, `lib/`, `app/`)
- No `package.json`, `requirements.txt`, `Cargo.toml` at root (unless the skill IS a tool with declared dependencies, in which case scripts/ would carry it)
- No `node_modules/`, `venv/`, `dist/`, `build/`, `.next/`, `target/`
- Total tree size proportional to a skill, not a working app

**Workshop signals (any one is enough to suspect; combination = certain):**

- `SKILL.md` missing, or present but with no frontmatter / placeholder body
- Top-level flooded with scratch markdown files instead of a `references/` structure
- Folders named like skill artifacts (`/validation`, `/examples`, `/starter`) but containing executable code or fixtures rather than skill content
- `node_modules/`, virtualenvs, build artifacts checked in
- Multiple languages mixed at root (Python + Node + others)
- Downloaded source materials (articles, datasets, fixtures) checked in
- Self-contained sub-services or runnable apps inside the tree
- Author describes it as "where I'm prototyping" / "my testing area" / "I don't know what counts as the skill yet"

When uncertain, default to workshop. The cost of running triage on a clean skill is one confirmation line; the cost of validating a workshop is a wasted audit and a confused author.

## Semantic Map

Before asking any question, present a map of what was found, organized by inferred purpose. The author must be able to recognize their own project in this map — if they can't, the reading is wrong and you re-read.

**Format:**

```
Project map: <target>

Skill candidates (might become THE skill):
  - <path>: <one-line guess at purpose>

Workshop content (lab / prototyping / fixtures):
  - <path>: <one-line guess>

Dependencies / build artifacts (will be ignored):
  - <path>

Unclassified — need your input:
  - <path>: <why ambiguous>
```

If "Unclassified" is non-empty, ask about those items before the intent dialogue. Do not guess on items you cannot place — ambiguity here propagates into wrong extraction.

## Author Intent Dialogue

Three questions, each with concrete options derived from the map. Never ask open-ended.

**Q1: Skill scope.** "Which of the candidates above is the skill you want to publish?"

- A) Just `<path-A>` — the cleanest methodology surface
- B) `<path-A>` + `<path-B>` as starter assets — bring the test harness along
- C) Something else — tell me which files

**Q2: Leftover handling.** "What should happen to the rest of `<target>`?"

- A) Leave it untouched — it's your lab, skill-forge will not modify it
- B) Drop a one-line `SKILL_EXTRACTED.md` at root pointing to the new skill location
- C) Move workshop content into a `lab/` subdirectory next to the new skill (only if you want them co-located)

**Q3: User experience.** "When someone installs your skill and uses it for the first time, what should happen?"

- A) [option derived from the skill candidate's apparent flow]
- B) [alternative based on what fixtures suggest]
- C) I cannot articulate this yet

If the author picks Q3-C, stop triage and report: *"Skill intent is not yet decided. Triage can scaffold structure but cannot invent product intent. Come back when you can describe the first-use flow in one sentence."*

## Extraction

Once intent is locked:

1. **Resolve `<name>`** in this order — detect first, ask second:
   1. If an existing SKILL.md fragment has `name:` in frontmatter → use that
   2. Else if `<target>` directory name is kebab-case and reads as a skill name → propose it as default, confirm in one line
   3. Else ask author: *"What should this skill be called? (kebab-case, e.g. `seo-blueprint`)"*
2. Create the destination at `<config.skill_workspace>/<name>/` (or, if Q2-C chosen, `<target>/skill/`)
3. **Copy** (not move) the agreed-upon skill files into the destination, normalizing structure:
   - Top-level prose intended as the skill body → `SKILL.md` (with frontmatter scaffolded if missing — `name` from step 1, `description` left as a TODO for the author)
   - Reference docs → `references/`
   - Helper scripts → `scripts/`
4. Apply the leftover handling chosen in Q2
5. Report what was copied and from where, then hand `skill_path` back to SKILL.md STEP 0.5

**Why copy, not move:** the workshop is the author's working memory. Moving files would break their existing scripts, IDE state, or git tracking. Copy is reversible; the author can delete originals later when satisfied with the extracted skill.

## Boundary

Triage owns: structural understanding, intent alignment, skill extraction.

Triage does NOT own: validation, quality fixes, reference rewriting, README generation. Those run in STEP 1+ on the extracted skill.

Triage does NOT touch the leftover workshop content beyond the optional annotation in Q2-B. That folder belongs to the author — skill-forge's job ends at "skill cleanly separated, relationship to the old folder stated".

Triage does NOT call `repo-scaffold`. `repo-scaffold` writes new standard repos from a blank slate; Triage extracts from existing chaos. Different jobs, no coupling.

## Cross-References

- `project-audit.md` — Discovery and classification (STEP 1, runs on the post-triage path)
- `onboarding.md` — Environment-level first-use config (different concern, runs STEP 0)
- `skill-format.md` — Standards the extracted skill will be validated against
