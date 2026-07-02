# Athena Guardians — Overview

10 个单一职责 subagent,内置于本插件,替换 superpowers 默认的 `general-purpose` 调用。性格驱动,职责从性格长出来。探索/审查/研究的发现**持久化到磁盘**,让大项目能跨 session 重建 context。

## 设计原则

1. **单一职责**——每个 agent 只做一件事。性格定,职责从性格长出来。
2. **独立 context**——subagent 的核心价值是隔离上下文。**自己审自己写的东西总是不太好**,所以实现者(capricorn/cancer)和审查者(scorpio/taurus/libra)必须是不同 agent、不同 context。
3. **持久化**——有"发现"的 agent 把结论写到 `docs/superpowers/`,主 agent 读盘重建 context。
4. **面向 superpowers 优化**——前 5 个直接对齐 superpowers 流程节点,已在本插件的 SKILL.md 里接好。

## The Ten (10/10)

### 核心五员 — 已接入 superpowers 流程

| Guardian | 性格 | 职责 | 接入点 |
|----------|------|------|--------|
| [capricorn](../../user-agents/capricorn.md) | 纪律执行者 | 实现 single task、vertical-slice TDD、自审、commit | `subagent-driven-development` 的 implementer |
| [cancer](../../user-agents/cancer.md) | 螃钳精准的诊断者 | 修**别人代码**里的 bug:先读、写 failing test 复现、最小修复、regression test 永久 | bug 修复任务(起点是复现/报错,不是 plan) |
| [scorpio](../../user-agents/scorpio.md) | 不信任的审查者 | 审规格符合性、不信报告、独立读码验证 | `subagent-driven-development` 的 spec-reviewer |
| [taurus](../../user-agents/taurus.md) | 不妥协的标准者 | 审代码质量、按行号说话 | `subagent-driven-development` 的 code-quality-reviewer + `requesting-code-review` |
| [libra](../../user-agents/libra.md) | 公正的裁决者 | 审 plan 是否可执行、approve by default | `writing-plans` 的最后一道关卡(替换原 Self-Review) |

### 补充五员 — 主 agent 按需派发

| Guardian | 性格 | 职责 | 何时派 |
|----------|------|------|--------|
| [virgo](../../user-agents/virgo.md) | 留档探索者 | 项目级代码地图、流追踪、模式编目,**写 findings-local.md** | 大项目摸底、跨 session 重建 context |
| [sagittarius](../../user-agents/sagittarius.md) | 追根溯源的研究者 | 外部资料、库怎么用、多源交叉、必引证 | capricorn 报 NEEDS_CONTEXT、外部依赖调研 |
| [aries](../../user-agents/aries.md) | 对抗性的破坏者 | 边界测试、并发混乱、资源耗尽、输入攻击 + **skills/agents/hooks/MCP 对抗审查** | 声称"done"后验证扛得住;改 skills/agents/hooks/MCP 时**强制派** |
| [aquarius](../../user-agents/aquarius.md) | 冷澈的质疑者 | 五个标签审计任何产物的存在性——`delete:` `stdlib:` `native:` `yagni:` `shrink:`。编排者指定审什么(plan/spec/diff)和用什么视角(透镜/梯子) | spec/plan 过了 libra 但"太干净";capricorn diff 异常大或出现新依赖 |
| [pisces](../../user-agents/pisces.md) | 克制的润色者 | 文本润色、去 AI 味、代码+非代码 | 已有文档需要听起来像人话 |

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
    ├── <doc>-adversarial-plan.md ← aquarius(审设计逻辑)
    ├── <task>-overengineering.md  ← aquarius(审代码存在性)
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

## aquarius vs libra 的分工

| | libra | aquarius |
|---|---|---|
| 审查什么 | plan 的完备性——task 可执行吗?有没有缺的? | spec/plan 的逻辑性——前提成立吗?问题本身对吗? |
| 默认姿态 | APPROVE —— 拒绝是例外 | QUESTION —— 每个前提都是嫌疑犯 |
| 派发位置 | **plan** 阶段,最后一道关卡 | **spec 阶段**(唯一审查者)+ **plan 阶段**(先于 libra) |
| 产出 | `<name>-plan-review.md` | `<name>-adversarial-plan.md` |

aquarius 看地基有没有裂缝。libra 看房子能不能住人。spec 阶段只有 aquarius——spec 还在设计层,没到"能不能执行"那一步。

## aquarius: 一个本能,五个标签

aquarius 只有一个问题:"该不该存在?"编排者指定审什么(plan/spec/diff/依赖列表)和用什么方法(设计审查用五透镜,代码审计用决策梯子)。aquarius 不做分类——他只找不该存在的东西,标记,计分。

| 标签 | 含义 | 替代 |
|------|------|------|
| `delete:` | 死代码/投机功能/为以后搭的架子 | 无 |
| `stdlib:` | 手写轮子,标准库已提供 | 给出库函数名 |
| `native:` | 代码或依赖做的是平台原生功能 | 给出原生功能名 |
| `yagni:` | 只有一个实现的抽象/没人改的配置/多余依赖 | 指出已有方案的替代 |
| `shrink:` | 同样的逻辑,可以更短 | 给出更短写法 |

永远以 `net: -N lines deletable.` 或 `Lean. Ship.` 结尾。

## 完整流程

审查顺序按**失败成本排序**——先审高层次的、容易崩塌的,再审细节:

```
brainstorming(主 agent + 用户,用 spec-writer 格式产出 spec)
    ↓ 派 aquarius 审 spec(前提对不对?问题答对了吗?)
    ↓   ❌ 驳回 → 回到 brainstorming 重写 spec(不是修补)
writing-plans(主 agent 产出 plan)
    ↓ 派 aquarius 审 plan(逻辑性——继承了 spec 的错误前提吗?)
    ↓   ❌ 驳回 → 回到 writing-plans 重写 plan(不是修补)
    ↓ 派 libra 审 plan(完备性——task 可执行吗?有没有缺的?)
    ↓   ❌ 驳回 → 回到 writing-plans 修复
[对每个 task:]
    ↓
capricorn 实现(更新 progress.md)
    ↓
scorpio 审规格符合性  →  taurus 审代码质量
    ↓
aquarius 审代码存在性(可选——diff 异常大时派)
    ↓
(卡住:capricorn 报 BLOCKED → 主 agent 派 virgo/sagittarius 调研,结论落 findings-local.md / findings-external.md)
    ↓
aries 对抗测试(可选)→ pisces 润色文档(可选)
```

**驳回即重写,不修补。** aquarius 驳回意味着设计的前提假设有根本性问题——在错误的前提上修补就像在地基裂缝上刷漆。回到上一阶段重新来过。

**spec/plan 的所有审查产出都落在 `docs/superpowers/reviews/` 下**——不在 spec 或 plan 目录里。

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
- **sonnet**(常规):cancer / taurus / libra / aries / aquarius / pisces
- **haiku**(搜索/研究):virgo / sagittarius

不可用的 model 静默回退到 inherit。

## For Agents

<!-- 机器可读。主 agent 通过 grep 定位此段。包含代理调度和持久化规则，不需要读全文即可操作。 -->

### 关键规则

- **持久化是强制的。** virgo 写 `findings-local.md`，sagittarius 写 `findings-external.md`，scorpio/taurus/aries/aquarius 写 `docs/superpowers/reviews/`，cancer 写 `docs/superpowers/diagnoses/`。主 agent 读盘重建 context。
- **独立审查不能省略。** aquarius 审 spec(唯一审查者),aquarius + libra 审 plan(先逻辑后完备),scorpio 审 spec 符合性,taurus 审代码质量。实现者和审查者必须是不同 agent、不同 context。
- **流程入口是 brainstorming。** 其他流程都从 brainstorming 的输出出发。bug 修复走平行流程（cancer 直接介入），跳过 brainstorming/writing-plans。
- **子代理 model 分层：** fable → capricorn + scorpio（高认知任务）；sonnet → cancer / taurus / libra / aries / aquarius / pisces（常规审查和分析）；haiku → virgo / sagittarius（搜索和研究）。不可用的 model 静默回退到 inherit。
- **`general-purpose` 已被完全替换。** 所有调度点都按名字派发。看到 `general-purpose` 就是 bug。
