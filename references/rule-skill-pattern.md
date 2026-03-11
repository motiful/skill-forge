# Rule-Skill Pattern

## What It Is

Rule-Skills are an advanced skill type that gives users the power to customize skill behavior with their own rules. When a skill has user-customizable constraints (MUST/NEVER rules, domain boundaries), those constraints are separated into a **paired rule-skill**. This enables:

- **User customization** — users define their own rules without modifying the capability skill
- **Dynamic loading** — the rule-skill's description is always visible in the skill listing, even when the capability skill isn't loaded
- **Independent evolution** — rules can be updated without touching the capability skill

The core advantage over native rule files: **always aware, pay on use**. Native rules are always-loaded (full context cost). Rule-Skills keep a summary in the description (~100 tokens, always visible) while loading full rules on-demand.

## Detection

The skill has constraints worth separating if:
- User explicitly states MUST/NEVER rules
- Skill description or content contains constraint patterns (must, never, always, forbidden, required)
- The skill imposes domain-specific boundaries ("no direct DB access", "must use parameterized queries")
- Behavior limits exist ("max N tabs", "must do X before Y")

## When to Create a Rule-Skill vs Native Rules

```
Is the constraint...

1. Universal (applies in ALL contexts, not domain-specific)?
   YES -> Short enough for a rule file (<10 lines)?
          YES -> Native rule (always-loaded, cheap)
          NO  -> Rule-skill (dynamic loading saves context)
                 + thin rule file as hard fallback
   NO  -> Continue

2. Domain-specific (only relevant in certain contexts)?
   YES -> Complex enough to justify a full SKILL.md (>3 statements)?
          YES -> Rule-skill (dynamic loading, portable, publishable)
          NO  -> Native rule (simpler infrastructure)
   NO  -> Continue

3. Does it need cross-platform portability?
   YES -> Rule-skill (Skills are the most portable mechanism)
   NO  -> Native rule is fine

4. Does it have a capability counterpart?
   YES -> Rule-skill, paired with capability skill
   NO  -> Consider if standalone rule-skill or native rule is simpler
```

### When to Use Both (Belt + Suspenders)

Use a rule-skill AND a native rule file when the constraint is **critical** — violation causes data loss, security breach, or irreversible damage. Deploy:
1. Full rule-skill for dynamic loading, portability, detailed context
2. Thin rule file (platform-native) that says: "See [skill-name] for full constraints. Summary: [1-2 line MUST/NEVER]."

### When to Use Neither

If the constraint is already enforced by **code/tooling** (mechanical enforcement), a rule-skill is redundant documentation.

### Quick Reference

| Scenario | Mechanism | Example |
|----------|-----------|---------|
| Short, universal constraint | Native rule | "Never commit .env files" |
| Domain-specific, complex constraint | Rule-skill | browser-rules (10+ MUST/NEVER) |
| Critical + must not miss | Rule-skill + rule file | memory-rules + thin fallback |
| Already code-enforced | Neither | Tab limit daemon |
| Needs cross-platform sharing | Rule-skill | Publish to npm/GitHub |
| Has capability counterpart | Rule-skill, paired | browser-hygiene + browser-rules |

## Creating a Rule-Skill

1. **Name**: `<skill-name>-rules` (e.g., `database-rules` for `database-access`)
2. **Move** all MUST/NEVER statements into the rule-skill
3. **Reference**: capability skill says "Optional: use with `<name>-rules` for user-defined constraint enforcement. Without it, the main skill still works on its own with its built-in/default behavior."
4. **Methodology**: follows the [rules-as-skills](https://github.com/motiful/rules-as-skills) three-layer model

## Packaging

In the generated capability skill:
- **README**: State that `<name>-rules` is optional for user-defined constraint enforcement. Include `npx skills add <org>/<name>-rules`, and explicitly say the main skill still works on its own; without `<name>-rules`, only the built-in/default behavior applies
- **SKILL.md body**: "Pairs optionally with `<name>-rules` for user-defined constraint enforcement. Without it, continue with the main skill's built-in/default behavior."

In the generated rule-skill:
- Standalone README with own install instructions
- Self-contained SKILL.md with all constraint rules
- No dependency on forge or rules-as-skills to function
