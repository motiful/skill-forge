# Script Quality Standard

Applies to any skill that includes a `scripts/` directory. Scripts are executable artifacts shipped with the skill — they must meet a higher bar than reference docs because users run them directly.

## Line Count Guidance

| Threshold | Interpretation |
|-----------|---------------|
| < 200 lines | Single-purpose script. Ideal target for any individual file |
| < 400 lines | Multi-function script. Acceptable if responsibilities are cohesive |
| > 500 lines | Split needed. Must justify in a comment header why the file cannot be decomposed |
| > 800 lines | Hard limit. No single script file may exceed this regardless of justification |

Line counts exclude blank lines and comments. Measure with: `grep -cve '^\s*$' -e '^\s*//' <file>`

## Module Split Triggers

A script file should be split when any of the following are true:

- **> 3 responsibility groups** — e.g., CLI parsing, business logic, file I/O, and formatting all in one file
- **> 5 unrelated exports** — functions that serve different callers or different stages of a pipeline
- **CLI + logic + data mixed** — argument parsing, core algorithm, and data constants should live in separate modules

Split along responsibility boundaries, not arbitrary line counts. Each resulting module should have a single reason to change.

## Complexity Indicators

Flag files that exhibit any of these patterns:

| Indicator | Threshold | Action |
|-----------|-----------|--------|
| Functions per file | > 15 | Extract into focused modules |
| Nesting depth | > 3 levels (e.g., `if` inside `for` inside `try` inside callback) | Refactor to early returns, extract helpers |
| Switch/if-else branches | > 10 cases | Use a dispatch map or strategy pattern |
| Cyclomatic complexity | > 20 per function | Decompose into smaller functions |
| Parameter count | > 5 per function | Use an options object |

These are warning signals, not automatic failures. The validator should flag them for human review.

## Dependency Policy

| Scenario | Policy |
|----------|--------|
| Pure computation (math, string manipulation, data transforms) | Zero external dependencies. Use language built-ins only |
| Large optional dependencies (e.g., image processing, PDF generation) | Dynamic import. Script must gracefully degrade or error with a clear install message if the dep is missing |
| Required dependencies | Pin major versions in a manifest (`package.json`, `requirements.txt`). Document why the dep is necessary |
| Dev-only dependencies (linting, testing) | Keep in devDependencies. Never ship to users |

General principles:
- Fewer dependencies = fewer supply-chain risks for users who `npx skills add` your skill
- Prefer vendoring small utilities (< 50 lines) over adding a dependency
- Never require global installs. If a tool is needed, check for it and provide install instructions

## Example: readme-craft `generate-logo.mjs`

**Before** (1 file, 1126 lines):
```
scripts/
  generate-logo.mjs        # 1126 lines — CLI parsing, SVG generation,
                            # color math, layout engine, file I/O, all mixed
```

Problems:
- CLI arg parsing interleaved with SVG template strings
- Color utility functions buried between layout calculations
- Impossible to test logo generation without invoking the CLI
- Adding a new logo shape required reading 1000+ lines of context

**After** (8 files, each < 200 lines):
```
scripts/
  generate-logo.mjs        # 45 lines  — CLI entry point, arg parsing, calls run()
  lib/
    run.mjs                 # 80 lines  — orchestrator: parse args → generate → write
    svg-builder.mjs         # 150 lines — SVG element construction and composition
    color.mjs               # 90 lines  — color math: contrast, palette, accessibility
    layout.mjs              # 120 lines — positioning, sizing, grid calculations
    shapes.mjs              # 110 lines — shape primitives (circle, rounded-rect, badge)
    templates.mjs           # 95 lines  — predefined logo templates
    fs-output.mjs           # 60 lines  — file writing, format detection, path handling
```

Key improvements:
- CLI entry point does nothing but parse args and call `run()`
- Each module has one reason to change
- `color.mjs` and `shapes.mjs` are independently testable
- Adding a new logo shape means editing `shapes.mjs` only (110 lines of context, not 1126)
