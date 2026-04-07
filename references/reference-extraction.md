---
name: reference-extraction
description: Decision framework for when to extract SKILL.md sections into reference files. Covers the module-vs-inline test, index quality (how SKILL.md points to references), and line count thresholds. EP design principles (batch, non-overlapping ownership) are in execution-procedure.md.
---

# Reference Extraction

When to extract SKILL.md content into a reference file, and how to maintain the connection.

In the module model: SKILL.md is the main program, references are imported modules, sections are inline implementations.

- **SKILL.md** answers: *what to do, in what order, under what conditions* (the orchestrator)
- **References** answer: *what specifically to check, how to check it, how to judge the result* (independent modules)
- **Sections** answer: *what does this specific EP step need to know?* (inline implementation)

## Execution Procedure

```
plan_reference_extraction(file) → split_recommendation

if independent module (own interface + own responsibility + changes independently) → reference
if tightly coupled to parent EP (one call site, no own interface) → section
if mixed responsibilities → split regardless of length
```

## When to Extract a Section into a Reference

Extract when the content is an **independent module**: it has its own meaningful interface (you can write an EP signature with input → operations → output), its own coherent responsibility, and changes independently of the parent's control flow.

Keep inline when the content is **tightly coupled** to the parent EP: consumed at exactly one point, no meaningful interface of its own, or extracting would require constant back-and-forth with the parent.

**Split early** when a file mixes multiple responsibilities, even if under 450 lines. Mixed examples:
- literal templates + writing rules
- validation logic + publishing strategy
- setup policy + troubleshooting appendix

## Index Quality

How SKILL.md points to its references:

- Every reference pointer in SKILL.md states what the reference contains and when to read it
- Conditional references have explicit gateways: "If X applies → see references/Y.md"
- Always-needed references have direct pointers: "Detailed checks are in references/Y.md"
- SKILL.md alone tells the AI the complete process flow — references fill in domain details

## Thresholds

- SKILL.md body: under 500 lines
- Reference file under 100 lines: TOC not needed
- Reference file 100-300 lines: add a TOC, no split needed purely for length
- Reference file 300-450 lines: evaluate — single cohesive concern with TOC = keep; mixed concerns = split
- Reference file above 450 lines: split by default
- Multi-responsibility reference files: split regardless of length
- Budget is per-file (peak load), not sum-of-all-files — references load on-demand
- Don't split a 250-line single-purpose reference into 6 tiny files — splitting has overhead too
