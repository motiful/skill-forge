# Skill Forge v4 Renovation Plan

Date: 2026-03-16
Status: Executed (2026-03-17)

## Problem Diagnosis

v3.0/3.1 的 quality-principles.md 存在 6 个内部矛盾，导致 skill-forge 的依赖处理、初始化、组合能力全面弱化。

### 矛盾清单

| # | 矛盾 | 位置 | 影响 |
|---|------|------|------|
| 1 | "Skills deserve engineering discipline"（像软件一样）但 Composition 用 "inline mention + fallback" 降级 | quality-principles.md L63-71 | 三种 capability 态度不一致 |
| 2 | "Not a package manager" 把"有依赖"和"做依赖管理"混为一谈 | quality-principles.md L116, L160 | 一刀切拒绝所有安装行为 |
| 3 | Litmus test（"删了还能跑"）跟 precondition-checks.md（"删了就重建"）互相打架 | quality-principles.md L75 vs precondition-checks.md L79 | 优雅降级 vs 自愈，两个哲学并存 |
| 4 | precondition-checks.md 自己承认 auto-install 是合法策略，但只给 npm 用，不给 skill 用 | precondition-checks.md L55-58 | 同类操作区别对待 |
| 5 | Decision Test 第 7 条循环论证：不做 → 不处方 → 不做 | quality-principles.md L177 | 锁死了改进空间 |
| 6 | "Skills are not software" 但要求 skill work alone——实际无 non-trivial skill 满足此标准 | quality-principles.md L46, L89 | self-contained 被过度解释 |

### 根因

quality-principles.md 用防御姿态写成——大量定义"我们不是什么"。画边界时画过头，把 onboarding、dependency install、companion discovery 都划出去了。SKILL.md 把这些边界当硬规则执行，结果所有依赖变成 "works better with"，AI 看到 fallback 就走 fallback，永远不装。

### 历史证据

- v2.0 有 **Capability Detection 表**（Onboarding / State Management / Rule-Skill Split）— 在 v3.0 被删
- v2.0 有 **`onboarding-pattern.md`**，含 dependency check + companion discovery + config creation — v3.0 改名为 `precondition-checks.md`，丢失安装动作
- 2026-03-15 加了 **JIT dependency pattern** — 第二天 v3.0 就删了
- Design thesis (`~/.claude/design/skills-as-code-thesis.md`) 明确说 dependency 是生态爆发的第三步，"agent is the resolver"

---

## Agreed Concepts

### 三层分离

| 层 | 定义 | 自动化程度 | 类比 |
|---|------|-----------|------|
| **Installation** | 安装依赖：工具、skill、npm 包 | 全自动（setup.sh） | `apt-get install`、`npm install` |
| **Onboarding** | 用户引导：首次使用的体验流程，帮用户了解产品、设置偏好、配置 profile | 交互式（用户参与） | App 首次打开的引导页 |
| **Configuration** | 存储用户偏好数据 | 数据层 | dotfile、config.md |

**关系**：
- Onboarding 过程中可能包含 Installation 和 Configuration 步骤
- 但三者是独立概念，各自有独立 reference
- Installation 是自动化的（setup.sh），Onboarding 是交互式的（用户参与），Configuration 是数据定义

### 安装机制：scripts/setup.sh（硬性标准）

**所有有依赖的 skill 必须包含 `scripts/setup.sh`。** 这是标准化机制，不仅限于 skill-forge。

**流程**：

```
Step 0:
  1. scripts/setup.sh 存在？ → 执行
  2. setup.sh 负责：
     - check 所有依赖（工具、skill、npm 包）
     - 缺的 → 安装
     - 装不上 → 报错并停止
  3. 全部就绪 → 进入主流程
```

**Prompt 的职责**：调用 setup.sh，不是自己判断依赖状态。AI 是执行者，setup.sh 是检测器。

**为什么不用 package.json postinstall**：
- `npx skills add` 不触发 `npm install`
- 但如果 skill 有 npm 依赖，setup.sh 内部可以调用 `npm install`
- 两者不冲突：setup.sh 是入口，npm install 是 setup.sh 调用的一个子步骤

#### Skill 安装检测

当前生态中 skill 安装位置是碎片化的：

| 来源 | 安装位置 | 示例 |
|------|---------|------|
| `npx skills add -g` | `~/.agents/skills/<name>/` | playwright-cli, skill-creator |
| 手动 symlink | `~/.claude/skills/<name>/` | skill-forge, readme-craft |
| 项目级安装 | `<project>/.claude/skills/<name>/` | 项目内 skill |

**setup.sh 检测逻辑**：

```bash
skill_installed() {
  local name=$1
  # 检查已知全局目录
  [ -d ~/.claude/skills/$name ] && return 0
  [ -d ~/.agents/skills/$name ] && return 0
  # 可扩展其他平台
  return 1
}
```

**安装方式**：`npx skills add <org>/<name> -g -y`（全局、免确认）

**默认安装级别**：全局（`-g`）。Skill 的依赖应该对用户全局可用，不限于单个项目。

**平台碎片化问题**：`npx skills add -g` 装到 `~/.agents/skills/`，但 Claude Code 读 `~/.claude/skills/`。setup.sh 可能需要在安装后补一个 symlink，或依赖 `npx skills add` 的 `-a` flag 指定目标 agent。这块在 `installation.md` 里要详细说明。

### 一种态度

不在就搞定。没有 graceful skip。

### 两种结果

| 结果 | 什么时候 |
|------|---------|
| **Installed** | 装上了，继续 |
| **Blocked** | 装不上（网络、权限、平台不支持）→ 具体错误 + 解法，停下来 |

没有中间态。

### 依赖声明两档制

| 档位 | 在哪声明 | 行为 |
|------|---------|------|
| **Dependencies** | SKILL.md Step 0 + scripts/setup.sh | 必须安装，缺了就装 |
| **Informational** | README.md only | 人类阅读，AI 不管 |

"Works Better With" 退出 SKILL.md 运行时逻辑。

### 入口级检查

所有依赖在 Step 0 一次性检查并安装。不做步骤级 JIT。

### Skill 是 Stateless 的

- Skill 本身不需要 state management
- Skill 唯一的"state"就是 config/preferences（数据层，由 skill-configuration.md 定义）
- Skill 可以服务有 state 的场景（PostgreSQL 管理、云端部署），但 skill 本身不管 state
- `references/state-management.md` 废弃，核心内容吸收进 `skill-configuration.md`

#### Skill 目录 = 只读发布物

**边界原则**：skill 目录下的所有内容（SKILL.md、references/、assets/、scripts/）是只读的发布物。任何运行时产生的数据（config、缓存、状态）必须在 skill 目录之外。

| 数据类型 | 存在哪 | 属于谁 |
|---------|--------|--------|
| 用户偏好 / config | `~/.config/<skill-name>/` | skill 的 Configuration 层 |
| 业务数据 / state | 项目目录、数据库、云端 | 用户的应用，不属于 skill |
| 运行时缓存 | `~/.cache/<skill-name>/` 或项目目录 | 临时的，可删除 |

**如果用户试图把数据存到 skill 目录下**（如 `.claude/skills/<name>/data/`），这是异常行为，应在 validation 中 warning。

#### Assets 的定位

`assets/` = **静态、只读、随 skill 发布的原材料**。AI 消费它来生成输出。

| 目录 | 内容 | AI 怎么用 |
|------|------|----------|
| `references/` | 领域知识（检查表、规范） | 读取来做决策 |
| `assets/` | 模板、schema、图片 | 读取来填充/生成输出 |
| `scripts/` | 可执行代码（含 setup.sh） | 执行 |

**assets 不是 state 存储。** 它不会被运行时修改。

**注意区分**：Logo、截图等服务于 GitHub/README 展示的图片是 **repo infrastructure**，不是 assets。它们应放在 `.github/` 或仓库根级别，不放在 `assets/`。（已修复：skill-forge 的 logo 从 `assets/` 移至 `.github/`，`assets/` 目录删除。）

### Onboarding 是独立且重要的概念

Onboarding 对 skill 的重要性等同于 onboarding 对软件的重要性。Skill 是软件的新界面，用户第一次用你的 skill 时：

- Playwright skill → 要设 Chrome Profile、登录 Google
- GitHub 工具 skill → 要配 username、default org
- Figma skill → 要创建 API token、设 workspace

这些是**用户参与的交互式引导**，不是自动安装。它值得一个独立 reference，因为好的 onboarding 直接决定 skill 的存活率。

### Rule-Skill Split 的定位：检测驱动，不是"可选"

**`rules-as-skills` 是 skill-forge 的硬依赖**（setup.sh 装上）。

Rule-Skill pattern 不是"可选"——"可选"会被跳过。它是**检测驱动**的：

| 检测到什么 | skill-forge 做什么 |
|-----------|-------------------|
| Skill 内容含 3+ 条 MUST/NEVER 约束 | 自动创建 paired `<name>-rules` skill |
| 约束需要按项目定制 | 自动创建 |
| 没检测到约束 | 不创建——不是"跳过"，是不需要 |

区别：
- 旧：用户决定（"要不要加 rule-skill？"）→ 用户不懂，跳过
- 新：forge 检测约束 → 有就创建，没有就不创建。用户不需要理解 pattern 本身

**skill-forge 自己的 rule-skill**：skill-forge 的 7 条 Engagement Principles 就是约束。拆成 `skill-forge-rules` 可以让用户按项目定制（某些项目可能不需要 "security > structure" 优先级）。这是自洽的体现。

**仓库结构选项**：
- (a) 单 skill 仓库 + 生成时按需创建 rule-skill → 当前模式的强化版
- (b) 多 skill 仓库（skill-forge + skill-forge-rules 在同一个 repo）→ Collection 结构
- 待定，需要评估哪种更自然

### skill-forge 自洽（同构）

skill-forge 应该是自己的最佳案例：

1. 自己有 `scripts/setup.sh`，安装 readme-craft 和 rules-as-skills
2. 自己的 Step 0 用自己规定的 Installation 模式
3. 删掉所有 "Without it, forge uses built-in..." 的 fallback
4. 自己规定的每个模式，自己必须先用上
5. 如果决定做 `skill-forge-rules`，自己就是多 skill 仓库的示范

**处方驱动实践，不是实践限制处方。**

---

## Modification Plan

### 优先级 1: quality-principles.md（根因修复）

| 修改点 | 现在 | 改为 |
|--------|------|------|
| L116 "Not a package manager" | 一刀切拒绝所有安装 | 明确区分：安装依赖 ≠ package management。只排除传递依赖解析和版本仲裁 |
| L65-71 Engineering discipline 表 | 三行三种态度 | 两行一种态度：Preferences（数据）+ Dependencies（环境），都是"不在就搞定" |
| L75 Litmus test | "删了还能跑 = config" | "删了能自动重建 = config（自愈）" |
| L89 Self-contained | 被过度解释为 work alone | 明确只指"不依赖 skill-forge 本身"，不指"不依赖其他 skill/tool" |
| L160 Boundaries 表 | "Dependency resolution or auto-install" outside scope | "Transitive dependency resolution / version conflict arbitration" outside scope |
| L177 Decision Test #7 | "不做就不处方"（循环论证） | "处方了就必须做。不做是 gap，不是理由" |

### 优先级 2: 新建 references/installation.md

定义 setup.sh 标准：
- 文件结构和命名约定（`scripts/setup.sh`）
- Skill 安装检测逻辑（跨平台目录扫描）
- 安装方法（npx skills add -g -y、npm install、brew install 等）
- 平台碎片化处理（安装后 symlink 补齐）
- 两种结果（installed / blocked）
- 跟 SKILL.md Step 0 的关系（prompt 调用 setup.sh）
- 示例 setup.sh（skill-forge 自己的作为范本）

### 优先级 3: 恢复 references/onboarding.md

独立 reference，描述用户引导的完整模式：
- 什么时候需要 onboarding（首次使用 + 配置不存在）
- Onboarding 可以包含什么（profile 设置、偏好收集、账号配置、功能介绍）
- 跟 Installation 的关系（onboarding 可能包含 installation 步骤，但不等于 installation）
- 跟 Configuration 的关系（onboarding 可能创建 config，但 config 定义在 skill-configuration.md）
- 示例（Playwright profile setup、GitHub username 配置等）

### 优先级 4: precondition-checks.md → 废弃

被 `installation.md` 和 `onboarding.md` 取代。
- 删除文件
- Installation 的检测逻辑 → installation.md
- Onboarding 的引导逻辑 → onboarding.md
- Config 创建逻辑 → skill-configuration.md（已有）

### 优先级 5: skill-configuration.md

- **保留为独立 reference**
- 修 litmus test：从 "删了还能跑" 改为 "删了能重建"
- 加边界原则：skill 目录 = 只读发布物，运行时数据在 skill 目录之外
- 吸收 state-management.md 核心内容：
  - Skill 是 stateless 的
  - Skill 可以服务有 state 的场景，但 skill 本身只有 config
  - 如果用户把数据存到 skill 目录下 → validation warning

### 优先级 6: state-management.md → 废弃

核心内容吸收进 skill-configuration.md。

### 优先级 7: SKILL.md

- Step 0 改为完整流程：
  1. 运行 `scripts/setup.sh`（Installation）
  2. 如果首次使用，运行 Onboarding 引导
  3. 检查 config，不存在就创建
- 恢复 Capability Detection 表（两项）：

  | Capability | 检测问题 | 引用 |
  |---|---|---|
  | **Installation** | skill 有依赖要安装吗？ | `references/installation.md` |
  | **Onboarding** | skill 需要首次用户引导吗？ | `references/onboarding.md` |

- Rule-Skill Split：从"可选模式"改为**检测驱动**——检测到约束就创建，不问用户
- "Works Better With" → "Dependencies"
- skill-forge 自己新增 `scripts/setup.sh`
- Step 3 Validation 新增检查项：

  | Check | Criteria | Severity |
  |---|---|---|
  | **Runtime write to skill directory** | skill 目录下不应有运行时写入的数据文件。检测 `.claude/skills/<name>/data/`、`.claude/skills/<name>/cache/`、或任何非发布物文件 | Warning |
  | **Assets misuse** | `assets/` 只放 AI 消费的原材料。Logo、截图等 repo infrastructure 应在 `.github/` 或根级别，不在 `assets/` | Warning |

### 优先级 8: rule-skill-pattern.md 更新

- 删除所有 "optional" 措辞
- 从"用户选择是否创建"改为"forge 检测到约束自动创建"
- 更新 Packaging 部分：删除 "optional for user-defined constraint enforcement"，改为 "paired rule-skill for user-customizable constraints"
- 评估 skill-forge 自己是否需要 `skill-forge-rules`

### 优先级 9: templates.md 更新

skill-forge 自己的 README 模板（用于生成其他 skill 的 README），目前包含旧哲学：
- L19: "Works Better With" section 指引 + "state that the skill still works on its own"
- L76-83: "Works Better With" 模板 + "This skill still works fully on its own"

改为 Dependencies 两档制表述，删除所有 "works on its own" 措辞。

### 优先级 10: readme-quality.md 更新

- L16: "Mirror companion tools" → 改为 "Mirror dependencies"
- L17: "Standalone fallback must stay explicit" → 删除
- L30: "Hiding a required dependency inside an optional-looking 'Works Better With' section" → 改为正面表述（依赖应在 SKILL.md Step 0 声明）
- L49: "companion tools" + "standalone fallback" → 对齐新措辞

### 优先级 11: skill-format.md 更新

- 文件结构模板加入 `scripts/setup.sh` 说明（有依赖的 skill 必须有）
- `scripts/` 描述从 "Executable code the AI runs. Generators, validators, CLI tools." 改为包含 "setup.sh (dependency installation)"
- 目录分类中加入 `.github/` = repo infrastructure（logo、截图等）

### 优先级 12: skill-composition.md 更新

- Dependencies 两档制（Dependencies / Informational）
- 删除 "skill must work fully without the recommended skill"
- 保留 context budget 分析，结论改为 "install what's declared, be aware of budget"

### 优先级 13: 维护文档归位

quality-principles.md 和 RENOVATION-v4.md 是维护文档，不是运行时 reference。移出 `references/`。

| 文件 | 现在 | 移到 | 理由 |
|------|------|------|------|
| quality-principles.md | `references/` | `docs/` | 维护 agent 的决策框架，运行时不加载 |
| RENOVATION-v4.md | 根目录 | `docs/` | 改造计划，维护文档 |

配套改动：
- MAINTENANCE.md 第 30 行引用路径更新：`references/quality-principles.md` → `docs/quality-principles.md`
- SKILL.md References 部分移除 quality-principles.md（它不是 runtime reference）
- skill-format.md 的目录分类中确认：`docs/` = 人类/维护 agent 文档，不是 skill 运行时内容
- quality-principles.md 的 Audience 行修改："AI agents maintaining skill-forge. Loaded during maintenance and self-review, NOT during runtime execution (Steps 0-4)."

### 优先级 14: README.md

- 对齐新哲学
- "Works Better With" → "Dependencies"
- 移除 "still works fully on its own"

---

## Open Questions

### Q1: setup.sh 的跨平台性

setup.sh 是 bash 脚本，Windows 上怎么办？

选项：
- (a) 只支持 Unix-like（macOS/Linux），Windows 用户用 WSL
- (b) 同时提供 setup.sh + setup.ps1
- (c) 用 Node.js 脚本（setup.mjs）替代 bash，跨平台但增加 Node 依赖

### Q2: skill-forge 删除 fallback 后 references 文件处理

skill-forge 的 `references/templates.md`（README 模板）和 `references/rule-skill-pattern.md` 目前作为 fallback 存在。

新哲学下 readme-craft 和 rules-as-skills 是硬依赖，必须安装。那这些 reference 文件：
- (a) 删除——反正有了 readme-craft 和 rules-as-skills
- (b) 保留——它们不只是 fallback，也是 skill-forge 自己的知识库
- (c) 保留但改定位——从 "fallback when companion absent" 改为 "skill-forge's own domain knowledge, complementary to dependency skills"

倾向 (c)：这些文件有独立价值（定义 skill-forge 特有的模板和模式），不应该因为 dependency 存在就删掉。

### Q3: skill-forge-rules 仓库结构

如果 skill-forge 自己创建 `skill-forge-rules`：
- (a) 同一个仓库（Collection 结构）→ 自洽，锁定版本
- (b) 独立仓库 → 用户可以只装 rule 不装 forge（但这有意义吗？）

倾向 (a)：skill-forge + skill-forge-rules 是紧耦合的。

### Q4: `npx skills add` 平台碎片化

`npx skills add -g` 安装到 `~/.agents/skills/`，但 Claude Code 读 `~/.claude/skills/`。

**已验证（2026-03-17）**：`npx skills add -g` 自动 hardlink 到 `~/.agents/skills/` 和 `~/.claude/skills/`（同一 inode）。不需要额外 symlink。Q4 关闭。

### Q5: CC Market 等社区平台

是否有 Claude Code 官方或社区 marketplace 需要纳入发布流程？当前 platform-registry.md 列了 skills.sh、SkillsMP、LobeHub，但定位为"downstream discovery"，不承诺即时上架。需要确认是否有遗漏的平台或新的发布渠道。

---

## Downstream TODOs（非 skill-forge 仓库的改动）

### TODO-1: readme-craft 更新 logo 存放指引

**仓库**：`~/motifpool/readme-craft/`

readme-craft 当前把 logo 放在项目根目录或 `assets/`。应加一条指引：
- README 服务的图片资源（logo、截图、badge 图标）放 `.github/`
- `assets/` 只放 AI 消费的原材料
- 更新 `references/logo-generation.md` 中的候选文件最终存放路径
- 更新 `assets/universal-readme.md` 和 `assets/skill-readme.md` 模板中的 logo srcset 路径

### TODO-2: readme-craft 更新 "Works Better With" → "Dependencies"

对齐 skill-forge v4 的新哲学。readme-craft 模板中的 "Works Better With" section 和 "This skill still works fully on its own" 需要调整。

---

## Execution Addenda (beyond original 14 priorities)

Changes made during execution that were not in the original plan:

### A1: self-review added as dependency
- Rationale: self-review strengthens forge's validation capability. Per v4 principle, stronger = dependency, not "works better with"
- Affected: setup.sh, installation.md example, SKILL.md Step 0, README.md Dependencies section

### A2: Q1-Q5 resolution
- Q1 (cross-platform): bash, done
- Q2 (reference files): (c) keep with repositioned framing — templates.md and rule-skill-pattern.md have independent value
- Q3 (skill-forge-rules): deferred — practical benefit low, dogfooding value marginal
- Q4 (platform fragmentation): **verified** — `npx skills add -g` auto-hardlinks to both `~/.agents/skills/` and `~/.claude/skills/`. No symlink needed. Removed symlink logic from setup.sh and installation.md
- Q5 (CC Market): added to platform-registry.md. Config-gated: first encounter → ask with recommendation to skip → save preference

### A3: scripts/setup.sh created
- Actual executable file, not just documentation
- Checks: gh, node, npx (CLI tools) + readme-craft, rules-as-skills, self-review (skill dependencies)

### A4: Install scope guidance
- installation.md: new "Install Scope" section — tooling skills default global, project skills default project-level
- README.md: install commands changed to `npx skills add motiful/skill-forge -g`
- templates.md: default install command is `-g` (forge output = publishable repos = global install)

### A5: Meta-skill contamination check (Step 3)
- Detects skill-forge/skill-creator accidentally installed inside a skill repo
- Remediation: `rm -rf <path>` then `npx skills add motiful/skill-forge -g`

### A6: Collection Risks (skill-composition.md)
- Context flooding: 50 skills = 5K tokens on descriptions alone. Warn at 15+ skills
- Name collision: generic names (`code-review`) collide with standalone skills. Recommend namespacing
- Internal deps without enforcement: custom frontmatter (`reads:`) has no runtime guarantee
- Ecosystem reality: most platforms (2026) cannot disable individual skills — install/uninstall only
- Two new Step 3 validation checks: collection context budget, collection name collision

### A7: Collection README template (templates.md)
- Skills catalog table for multi-skill repos
- Category grouping for 10+ skills
- Selective install examples (`--skill`)

### A8: Ecosystem Check (Step 1, Full Create only)
- Before creating new content, search `npx skills find` / skills.sh for existing similar skills
- Three outcomes: depend on it / fork and adapt / create from scratch

### A9: CC Market config-gated publishing
- platform-registry.md: assessment (strict review, low incremental value, recommend skip)
- SKILL.md Step 4: check cc_market in config. Not set → ask once with recommendation → save
- Forge config: `cc_market: true/false`

### A10: Location Rule (Step 4)
- Forge does not force-move author's files
- Existing skill → publish in-place
- Full Create → create in skill_root (default)
- Graduation → copy to skill_root (user-requested move)

### A11: publishing-strategy.md cleanup
- "Companion Tools" section → "Dependencies"
- Decision framework: "companion tools" → "dependencies in Step 0 + setup.sh"

---

## Changelog

- 2026-03-17 execution: All 14 priorities executed + 11 addenda (A1-A11). Q1-Q5 resolved. Status → Executed.
- 2026-03-16 iter7: Final review. 补充 3 个遗漏：templates.md（优先级 9）、readme-quality.md（优先级 10）、skill-format.md（优先级 11）。总优先级从 11 扩展到 14。Status → Ready for execution。
- 2026-03-16 iter6: 新增优先级 10（维护文档归位：quality-principles.md + RENOVATION-v4.md → docs/）。原优先级 10 README 改为优先级 11。
- 2026-03-16 iter5: 新增 Downstream TODOs（readme-craft logo 路径 + "Works Better With" 对齐）。新增 Q5（CC Market 等社区平台）。quality-principles.md 定位澄清：维护时加载，运行时不加载。
- 2026-03-16 iter4: Logo 从 `assets/` 移至 `.github/`（repo infrastructure）。空 `assets/` 目录删除。新增两个 Step 3 validation check：runtime write to skill directory、assets misuse。README.md 路径已更新。
- 2026-03-16 iter3: Skill 安装检测机制明确。Assets 定位澄清。Skill 目录只读原则确立。State Management 边界原则加入。Rule-Skill 从"可选"改为"检测驱动"。Q1/Q2 from iter2 保留，新增 Q3（skill-forge-rules 结构）和 Q4（平台碎片化）。
- 2026-03-16 iter2: Resolved Q1-Q4 from iter1. setup.sh 定为硬性标准。三层分离（Installation / Onboarding / Configuration）。State Management 废弃。skill-forge 自洽原则确立。
- 2026-03-16 iter1: Initial draft. 6 contradictions diagnosed. Agreed concepts + modification plan + 4 open questions.
