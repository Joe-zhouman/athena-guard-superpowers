# Athena Guardians — Overview

9 个单一职责 subagent,内置于本插件,替换 superpowers 默认的 `general-purpose` 调用。性格驱动,职责从性格长出来。探索/审查/研究的发现**持久化到磁盘**,让大项目能跨 session 重建 context。

## 设计原则

1. **单一职责**——每个 agent 只做一件事。性格定,职责从性格长出来。
2. **独立 context**——subagent 的核心价值是隔离上下文。**自己审自己写的东西总是不太好**,所以实现者(capricorn/cancer)和审查者(scorpio/taurus/libra)必须是不同 agent、不同 context。
3. **持久化**——有"发现"的 agent 把结论写到 `docs/superpowers/`,主 agent 读盘重建 context。
4. **面向 superpowers 优化**——前 5 个直接对齐 superpowers 流程节点,已在本插件的 SKILL.md 里接好。

## The Nine (9/9)

### 核心五员 — 已接入 superpowers 流程

| Guardian | 性格 | 职责 | 接入点 |
|----------|------|------|--------|
| [capricorn](../../.claude/agents/capricorn.md) | 纪律执行者 | 实现 single task、vertical-slice TDD、自审、commit | `subagent-driven-development` 的 implementer |
| [cancer](../../.claude/agents/cancer.md) | 螃钳精准的诊断者 | 修**别人代码**里的 bug:先读、写 failing test 复现、最小修复、regression test 永久 | bug 修复任务(起点是复现/报错,不是 plan) |
| [scorpio](../../.claude/agents/scorpio.md) | 不信任的审查者 | 审规格符合性、不信报告、独立读码验证 | `subagent-driven-development` 的 spec-reviewer |
| [taurus](../../.claude/agents/taurus.md) | 不妥协的标准者 | 审代码质量、按行号说话 | `subagent-driven-development` 的 code-quality-reviewer + `requesting-code-review` |
| [libra](../../.claude/agents/libra.md) | 公正的裁决者 | 审 plan/spec 是否可执行、approve by default | `brainstorming` + `writing-plans` 的 reviewer(替换原 Self-Review) |

### 补充四员 — 主 agent 按需派发

| Guardian | 性格 | 职责 | 何时派 |
|----------|------|------|--------|
| [virgo](../../.claude/agents/virgo.md) | 留档探索者 | 项目级代码地图、流追踪、模式编目,**写 findings-local.md** | 大项目摸底、跨 session 重建 context |
| [sagittarius](../../.claude/agents/sagittarius.md) | 追根溯源的研究者 | 外部资料、库怎么用、多源交叉、必引证 | capricorn 报 NEEDS_CONTEXT、外部依赖调研 |
| [aries](../../.claude/agents/aries.md) | 对抗性的破坏者 | 边界测试、并发混乱、资源耗尽、输入攻击 + **skills/agents/hooks/MCP 对抗审查** | 声称"done"后验证扛得住;改 skills/agents/hooks/MCP 时**强制派** |
| [pisces](../../.claude/agents/pisces.md) | 克制的润色者 | 文本润色、去 AI 味、代码+非代码 | 已有文档需要听起来像人话 |

## 持久化架构(subagent 写盘,主 agent 读盘)

```
docs/superpowers/
├── specs/            ← brainstorming 产出(用 spec-writer 格式)
├── plans/            ← writing-plans 产出
├── findings-local.md    ← virgo(本地探索)追加
├── findings-external.md ← sagittarius(外部研究)追加
├── progress.md       ← capricorn/cancer 每次提交后追加一行
├── diagnoses/        ← cancer 写 bug 诊断(root cause + evidence)
└── reviews/
    ├── <task>-spec.md          ← scorpio
    ├── <task>-quality.md       ← taurus
    ├── <task>-adversarial.md   ← aries
    ├── <doc>-plan-review.md    ← libra(审 plan)
    └── <doc>-spec-review.md    ← libra(审 spec)
```

## virgo vs 内置 Explore 的分工

| | 内置 Explore agent | virgo |
|---|---|---|
| 用途 | "X 在哪?" 单次快查 | 项目级地图、流追踪、模式编目 |
| 产出 | excerpt 塞回主 context | 结构化结论写 `findings-local.md` |
| 跨 session | 丢失 | 持久化 |

单次快查用内置 Explore;要留档的大范围探索用 virgo。

## 完整流程

```
brainstorming(主 agent + 用户,用 spec-writer 格式产出 spec)
    ↓ 派 libra 审 spec
writing-plans(主 agent 产出 plan)
    ↓ 派 libra 审 plan
[对每个 task:]
    ↓
capricorn 实现(更新 progress.md)
    ↓
scorpio 审规格符合性  →  taurus 审代码质量
    ↓
(卡住:capricorn 报 BLOCKED → 主 agent 派 virgo/sagittarius 调研,结论落 findings-local.md / findings-external.md)
    ↓
aries 对抗测试(可选)→ pisces 润色文档(可选)
```

**bug 修复走平行流程**(不进 brainstorming/writing-plans):

```
用户报告 bug(给复现/报错)
    ↓
cancer 读码 → 写 failing test 复现(RED)→ 写 diagnosis.md → 最小修复 → 验证(GREEN)
    ↓
taurus 审质量(跳过 scorpio,因为 bug 没有 spec,test 就是 spec)
    ↓
aries 对抗测试(可选)
```

scorpio / taurus / libra 都是**独立 context 审查别人写的**——这是本套体系的核心价值。cancer 也是:他修的不是自己写的代码,所以**先读懂**再改。

## model 分层

- **fable**(高认知):scorpio + capricorn
- **sonnet**(常规):cancer / taurus / libra / aries / pisces
- **haiku**(搜索/研究):virgo / sagittarius

不可用的 model 静默回退到 inherit。
