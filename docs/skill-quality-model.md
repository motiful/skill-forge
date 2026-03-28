# Skill Quality Model: Why Each Check Exists

Every check in skill-forge's validation tables exists because a real community pain point demanded it. This document maps pain points (with evidence) to mechanisms (with rationale).

Use this to understand WHY skill-forge checks what it checks — and to explain findings to skill authors in terms of user impact, not rule compliance.

## Review Philosophy

Skill-forge findings are not bug reports. They are **impact assessments**:

- **Fix**: Users will experience failure if they follow this skill's instructions (broken code, phantom files, wrong package names)
- **Improve**: Users get a degraded experience that a known better design would prevent (skill not triggering, agent ignoring workflow, context wasted)
- **Note**: Observation for the author's awareness, no user-facing impact

The skill author decides what to act on based on whether the impact is acceptable to them.

---

## Pain Point #1: Skills Not Triggering / Silent Disappearance

**Community evidence**: GitHub issue #9716 (66 thumbs-up), 650-trial study showing ~50% baseline activation rate, Anthropic official: "Claude has a tendency to undertrigger skills", users resorting to ALL-CAPS in descriptions.

**User impact**: Skill exists but never activates. User gets generic responses instead of domain-specific guidance. Author's work is invisible.

| Check | What it prevents |
|-------|-----------------|
| description single-line | Multi-line YAML → skill silently disappears in CC |
| description no unquoted `: ` | YAML parse error → skill dropped without error |
| description < 1024 chars | Truncated description → trigger phrases lost |
| Description coverage | Missing trigger phrases → skill doesn't activate for relevant queries |
| Description clarity | Incomprehensible description → platform can't match to user intent |
| anti-graceful-skip default-execute | AI's "undertrigger" tendency → skill loaded but not used |

## Pain Point #2: Wrong Directory → Silent Non-Loading

**Community evidence**: skill.md (lowercase) fails silently, skills/ vs skill/ confusion, symlink issues across platforms, users debugging for hours.

**User impact**: Skill is installed but platform doesn't see it. No error message.

| Check | What it prevents |
|-------|-----------------|
| name kebab-case + matches directory | Name mismatch → discovery failure |
| SKILL.md at repo root | npx skills add can't find the skill |
| Platform registry paths | Installed to wrong directory → platform ignores it |
| Registration audit | Duplicate registration → loaded twice, wastes context |
| Broken symlink check | Symlink target missing → silent failure |

## Pain Point #3: Cross-Platform Incompatibility

**Community evidence**: CC validator rejects its own allowed-tools field, Cursor's disable-model-invocation makes skills vanish, .claude/ vs .agents/ format differences.

**User impact**: Skill works on one platform, breaks on another. Author doesn't know.

| Check | What it prevents |
|-------|-----------------|
| CC-specific fields inside metadata | Validator rejection on CC |
| Standard frontmatter only | Cross-platform parse failures |
| Per-platform path detection | Wrong path for target platform |

## Pain Point #4: Context Waste / Oversized Skills

**Community evidence**: Model effective capacity ~60-70% of window, 47 skills installed → 40 hurt performance, LLM-generated context reduced success by 2-3% while increasing cost 20%.

**User impact**: Skill loads but pushes out user's actual task context. Agent becomes less capable, not more.

| Check | What it prevents |
|-------|-----------------|
| Body < 500 lines | Skill alone consuming 5K+ tokens |
| Instruction density ≥ 60% | Filler text wasting context |
| References on-demand | Loading all reference content upfront |
| Positional Test | Content that doesn't serve any execution step |
| 15+ skills → warn | Collection flooding agent's description cache |

## Pain Point #5: No Dependency Management

**Community evidence**: No dependencies field in spec, no npx skills install equivalent, team onboarding requires manual individual installation.

**User impact**: Skill depends on another skill that isn't installed. Fails silently or produces incomplete results.

| Check | What it prevents |
|-------|-----------------|
| setup.sh standard | Missing dependencies not detected |
| Skill() + output gate | Inter-skill calls fail silently |
| Two-tier dependency model | Ambiguous "works better with" → either require or don't |

## Pain Point #6: No Way to Verify Skills Work

**Community evidence**: "Most developers deploy based on a vibe check", skills degrade silently across model versions, one eval run surfaced 3 months of manual workarounds.

**User impact**: Skill appears to work but produces subtly wrong guidance. Author has no feedback mechanism.

| Check | What it prevents |
|-------|-----------------|
| Full validation matrix | Systematic check vs vibe check |
| EP pseudocode | Rewording steps silently breaks behavior |
| GATE assertions | Steps getting silently skipped |
| maintenance-rules in-repo | Skill rotting as codebase evolves |

## Pain Point #7: Security

**Community evidence**: Snyk audit of 3,984 skills: 7.1% leaked credentials, 36% had security defects. ClawHavoc: 1,200 malicious skills infiltrated marketplace.

**User impact**: Real API keys exposed. Malicious code executed via trusted-looking skill.

| Check | What it prevents |
|-------|-----------------|
| Secret pattern scan | Leaked API keys in published skill |
| .gitignore coverage | .env accidentally committed |
| No hardcoded paths | Personal directory structure exposed |

## Pain Point #8: Scattered Skills Can't Be Found

**Community evidence**: "You already have dozens of agent skills — you just can't find them", Team A and Team B have conflicting testing skills, new members see 30 skills and don't know which matter.

**User impact**: Useful skills exist but nobody knows. Conflicting skills produce inconsistent behavior.

| Check | What it prevents |
|-------|-----------------|
| Full-tree discovery | Missing skills in unexpected locations |
| 5-type classification | Confusion between in-repo, personal, product, external, rules |
| Rules conversion | Trigger-based rules that should be skills but aren't |
| Graduation path | Personal tools stuck in one project |

---

*Each pain point sourced from public GitHub issues, community forums, security audits, and official platform documentation. Full raw data in `docs/research/ecosystem-pain-points-2026.md`.*
