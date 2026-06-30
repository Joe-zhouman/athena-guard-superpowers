# Athena Guardians — 调用指南

8 个 subagent 的使用场景与反模式。前 4 个已接入 superpowers 流程(自动调用);后 4 个由主 agent 按需派发。

## 核心四员(superpowers 自动调用)

### capricorn — implementer
- 实现单个定义明确的任务(来自 plan)
- 有清晰复现步骤的 bug 修复
- **不派**:架构决策、模糊需求、需要研究的任务(他会报 BLOCKED)

### scorpio — spec-reviewer
- capricorn 声称"done"后,验证实现是否真的符合规格
- **不信 implementer 的报告**,独立读码
- 查 missing / extra / misunderstanding
- **不派**:代码质量(归 taurus)、运行时 bug(归 aries)

### taurus — code-quality-reviewer
- scorpio 通过后,审查代码质量
- 可读性、命名、重复、错误处理、文件职责单一、测试真实性
- 每条 issue 必须带 file:line
- **不派**:规格符合性(归 scorpio)、需运行才能确认的 bug(归 aries)

### libra — plan/spec reviewer
- 写完 spec 后、写 plan 前:审 spec
- 写完 plan 后、实现前:审 plan
- approve by default,只抓真阻断(最多 3 条)
- **不派**:实现审查(归 scorpio/taurus)、设计意见

## 补充四员(主 agent 按需派发)

### virgo — 留档探索者
- 大项目开始时摸底:架构地图、模块关系、关键流
- 跨 session 重建 context:读 `findings-local.md` 恢复
- 结论写 `docs/superpowers/findings-local.md`
- **不派**:单次"X 在哪"快查(用内置 Explore)

### sagittarius — 外部研究者
- "这个库/包怎么用?"
- 开源项目源码实现、API 行为、论文、最佳实践
- 多源交叉、必引证、标置信度
- 结论追加到 `docs/superpowers/findings-external.md`
- **不派**:本地代码搜索(归 virgo)

### aries — 对抗测试者
- 声称"done"且要确认扛得住时
- 边界值、状态机破坏、并发混乱、资源耗尽、输入攻击
- 报告写 `docs/superpowers/reviews/<task>-adversarial.md`
- **不派**:happy path 验证(归 capricorn)

### pisces — 文本润色者
- 已有文档的去 AI 味、语气校准
- 不限于代码:论文、报告、邮件
- **必须有草稿**——无草稿路由回原作者
- **不派**:从零写文档、界面微文案

## 反模式

- **简单任务不用 capricorn**——明确的小修直接做
- **capricorn 不自己委派审查**——他没 Agent 工具;审查由 superpowers 流程独立派 scorpio/taurus
- **没有草稿不用 pisces**
- **单次快查不用 virgo**(用内置 Explore)
- **happy path 验证不找 aries**
- **架构问题不找 taurus**(他审质量,不审设计)
- **spec 符合性不找 taurus**(归 scorpio)

## 持久化约定

| Agent | 写什么 | 路径 |
|-------|--------|------|
| virgo | 本地探索地图 | `findings-local.md`(追加) |
| sagittarius | 外部研究结论 | `findings-external.md`(追加) |
| capricorn | 提交后状态 | `progress.md`(追加一行) |
| scorpio | 规格审查 | `reviews/<task>-spec.md` |
| taurus | 质量审查 | `reviews/<task>-quality.md` |
| aries | 对抗测试 | `reviews/<task>-adversarial.md` |
| libra | plan/spec 审查 | `reviews/<doc>-{plan,spec}-review.md` |

主 agent 读这些文件重建 context——这是大项目跨 session 工作的基础。
