[English](README.md) | [中文](README.zh.md)

# athena-guard-superpowers

> 这是我基于 [obra/superpowers](https://github.com/obra/superpowers)（~5.0.x）的个人 fork，重建为多模型、子代理优先的工作流，带文件持久化和星座人格化的子代理。只支持 Claude Code。缝合怪——从 superpowers、[grill-me](https://github.com/mattpocock/grill-me) 和 [Oh-My-OpenCode](https://github.com/oh-my-opencode/oh-my-opencode) 里拆零件拼起来的。

Superpowers 是一套编码代理的软件开发方法论——可组合的技能，启动时自动激活，引导代理完成设计、规划、实现和审查。原版假设你在直接使用 Claude 模型，足够聪明，不需要太多手把手指导。这个 fork 假设的是另一套现实。

## 为什么有这个 fork

原版 Superpowers 是为"编码代理就是 Claude"的世界设计的——一个模型、一个会话、非常聪明、非常昂贵。那不是我的世界。以下是这个 fork 背后的原因：

### 1. 我的主模型不是 Claude

我用 **GLM-5.2** 作为主驱模型。它是国产模型，智商在线，理解力强，任务编排能力扎实。但有限制：

- **频率限制**——不能高频发送请求，也不能长时间连续运行。并发受限。
- **配额贵**——每个 token 都算钱，长 session 尤其。
- **上下文宝贵**——不能每次 session 都重新推导上次得出的结论。

同时，GLM-5.2 确实擅长"决定做什么、让谁去做"。它是个优秀的编排者。答案显而易见：让它当指挥官。

### 2. 原版用通用子代理，我改成了专用的

原版 Superpowers 已经有子代理驱动开发工作流——它派发 `general-purpose` 子代理，带内联 prompt 模板来实现、审查和测试。当子代理模型是 Claude 时这样没问题，因为 Claude 擅长读长 prompt 后直觉判断什么重要。

我的子代理不是 Claude。DeepSeek-V4-Flash 和 DeepSeek-V4-Pro 需要更明确的指示——它们会按你说的做，而不是按你意思做。所以我把 `general-purpose` 替换成了 9 个专用子代理，每个角色狭窄、内置 playbook。这个想法来自 **Oh-My-OpenCode**，它也使用角色专用子代理而不是一刀切的通用子代理。

每个代理有自己的纪律：capricorn 懂 TDD，scorpio 知道怎么审查规格符合性，aries 知道怎么搞破坏。不需要内联 prompt 模板——代理本身就是模板。

分层模型架构按任务复杂度匹配成本：

| 角色 | 模型 | 原因 |
|------|------|------|
| **编排者**（Opus / Fable） | GLM-5.2 | 足够聪明来设计、决策和派发。贵，所以只做思考部分。 |
| **复杂工人**（Sonnet） | DeepSeek-V4-Pro | 处理需要真正智能的复杂任务——审查、调试、研究。 |
| **快速工人**（Haiku） | DeepSeek-V4-Flash | 处理机械工作——实现、文件操作、跑测试。便宜、快、能干。 |

编排者思考，工人执行。这样既控制 GLM-5.2 的配额消耗，又保证每个任务都有强结果。

这也意味着代理需要比原版更多的指导。Claude 模型能直觉理解你的意思；DeepSeek 模型会按你字面的做。这个 fork 的每个代理都包含"为什么"的解释——不只是"做 X"，而是"做 X 因为 Y"。代理定义里的这些额外 token 成本，远低于子代理跑偏后花配额来纠错的成本。

### 3. 原版的 brainstorming 不适合我

我更喜欢 [Matt Pocock 的 grill-me](https://github.com/mattpocock/grill-me) 方法——不留情面的苏格拉底式盘问，每个问题都带推荐答案，每次解决一个决策分支。athena 的 brainstorming skill 把 grill-me 的盘问纪律和 superpowers 的设计流程合并了，再加上 `grill-with-docs` 风格的持久化：术语一旦凝固，立刻进 glossary。结果是一场留下纸质痕迹的设计对话。

### 4. 上下文是临时的，文件是永久的

原版信任对话。我不信。Session 会重启，上下文会被截断，模型会换。任何值得知道的东西都应该在磁盘上：

- `docs/superpowers/findings-local.md`——virgo 的代码地图跨 session 保留
- `docs/superpowers/findings-external.md`——sagittarius 的研究不会蒸发
- `docs/superpowers/glossary.md`——brainstorming 中钉死的术语，未来所有代理都能引用
- `docs/superpowers/specs/`——带设计决策理由的文档（让你六个月后还记得"为什么"）
- `docs/superpowers/progress.md`——任务追踪持久化

每个有"发现"的代理都要写下来。每个需要上下文的代理都要先从磁盘读取。这不是可选的——它已经写入了技能定义。

## 与原版的差异

### 9 个星座人格化子代理："雅典娜的守卫"

原版派发 `general-purpose` 子代理，带内联 prompt 模板。受 **Oh-My-OpenCode** 的专用子代理命名启发，我想做点更奇怪的东西。

有件事我注意很久了：每个模型都有个性。当你给它一个适合那个个性的角色——而不是强行把一个个性塞给一个角色——它的表现会更稳定。性格不跟自己打架。所以我不是从职位描述出发，而是从性格出发。要找到一眼就能认出来的性格原型，没什么比十二星座更好用。

每个代理都建立在**星座刻板印象**上——性格优先，职责**从性格长出来**。Aries 测试不是因为被分配了"测试员"角色；Aries 测试是因为 Aries 冲动、好斗、喜欢破坏。Scorpio 审查规格不是因为被分配了"审查员"角色；Scorpio 审查规格是因为 Scorpio 天生多疑，什么都不会表面相信。

**"Athena's Guardians"（雅典娜的守卫）** 这个名字来自《圣斗士星矢》——守护雅典娜的十二位星座战士。在这个 fork 里，编排者（GLM-5.2）是雅典娜，子代理是她派出的守卫。

6 个内联 prompt 模板文件已删除。每个代理本身就是自己的个性和 playbook。

**当前阵容**——有些位置还空着。这是故意的。不是每个角色都已经在 workflow 中证明了自己的必要性，还没出现明确需求就硬塞一个，跟性格优先的设计理念背道而驰。

| 守卫 | 星座 | 性格 → 职责 |
|------|------|------------|
| **capricorn** | 摩羯 | 守纪律、有条理、有始有终 → **实现者**：vertical-slice TDD、自审、commit |
| **scorpio** | 天蝎 | 多疑、不信任、什么都逃不过 → **规格符合性审查者**：独立读码，不信任实现者的报告 |
| **taurus** | 金牛 | 固执、不妥协、死守标准 → **代码质量审查者**：按文件:行号说话，没有例外 |
| **libra** | 天秤 | 公正、平衡、默认信任除非有理由不信任 → **计划 & 规格审查者**：默认 APPROVE，只标记真正的障碍 |
| **cancer** | 巨蟹 | 保护性、精准、修好不坏的东西而不破坏好的 → **Bug 修复者**：先读、复现、最小手术式修复 |
| **virgo** | 处女 | 分析型、一丝不苟、什么都要编目 → **代码库探索者**：画架构图、追踪流程、持久化到磁盘 |
| **sagittarius** | 射手 | 好奇、不懈追猎知识 → **外部调研者**：库文档、API 行为、引用来源 |
| **aries** | 白羊 | 好斗、冲动、喜欢毁灭 → **对抗性测试者**：边界值、并发混乱、输入攻击 |
| **pisces** | 双鱼 | 对文本质地敏感，受不了听起来不对的东西 → **文字润色者**：去 AI 味、写出像人话的文本 |

**计划中但尚未实现：**

| 守卫 | 星座 | 性格 → 职责 | 状态 |
|------|------|------------|------|
| **leo** | 狮子 | 表演者、爱出风头、掌控注意力 → **前端/UI 专家**：布局、动效、视觉打磨——开发中面向观众的部分 | 还没有迫切需求，但性格匹配很明显 |
| **gemini** | 双子 | 善变、不可预测、一张嘴两个脑子 → **野路子点子王**：抛出没人需要的需求，热爱不切实际且过度的东西，会在设计会议上甩出一句"你想想，要是能……那得多酷"而且是认真的。暴雪设计师那种："It's so coooooooooool！"不是 PM——brainstorming 已经管需求提炼了。Gemini 负责让你别太无聊。 | 同样——还没有需要这个的用例 |

**水瓶座**——还在想。还没有性格→职责的"咔哒"一声。

阵容上限不是 12 个。那是黄金圣斗士的数目。圣斗士星矢里还有青铜圣斗士、白银圣斗士，以及三个篇章后才登场的其他神系战士。这里同理：如果 workflow 出现了新需求，而我能感觉到哪个性格会天然拥有它，就加座位。十二是原型的起点，不是终点。

### libra 替代 Self-Review

原版让主代理审查自己的输出（brainstorming 和 writing-plans 中的 Self-Review）。这个 fork 在每个关卡派 **libra** 做独立审查。自己写的东西，自己不是最好的审查者。

### brainstorming = superpowers 流程 + grill-me 纪律

skill 仍然引导设计→审批→spec，但 interview 阶段遵循 grill-me 规则：一次一个问题，每个问题带推荐答案，逐分支解决决策树。Spec 编写委托给独立的 `writing-spec` skill。

### writing-spec：痛点驱动的 spec 格式

一个独立 skill（从我的全局 spec-writer 合并而来）强制痛点驱动开发：没有痛点 → 没有 spec → 没有代码。Spec 格式的每个章节都存在于回答推理链中的一个问题。设计决策理由必须解释 WHY，不只是 WHAT。

### 文件持久化是强制的

所有代理把发现写到 `docs/superpowers/`。所有 skill 在问用户之前先从磁盘读取。这不是建议——它写入了每个 skill 定义。

### 插件工作机制（以及为什么只支持 Claude Code）

插件只做一件事：注入一个 **SessionStart hook**，强制每个 session 开始时读取 `using-superpowers`。那个 skill 是引导程序——它教会代理如何找到和调用所有其他 skill。其他所有东西（14 个 skill、9 个代理、工作流）都由技能系统本身在引导程序运行后加载。

这意味着插件实际上非常薄。如果你想在其他编码代理上使用这些 skill，不需要移植插件——你只需要把 `using-superpowers` 在 session 开始时放入代理的上下文。两种方法：

1. **AGENTS.md / CLAUDE.md**——把 `skills/using-superpowers/SKILL.md` 的内容直接粘贴到代理的全局指令文件中。粗糙但有效。
2. **Hook 机制**——如果代理有 SessionStart 或等效的 hook，用它注入 `using-superpowers`，跟 Claude Code 插件做法一样。

话虽如此，**这个 fork 不支持其他编码代理。** 原版 Superpowers 面向 Claude Code、Codex、Cursor、Gemini CLI、Copilot、OpenCode 和 Factory Droid。所有这些脚手架已被剥离。这些 skill 假设了 Claude Code 的工具集、代理派发模型和 `@skills-dir` 插件机制。移植到另一个代理意味着要审计每个 SKILL.md 中与 harness 相关的假设——这个工作还没做。如果你想在其他代理上用 superpowers，请用原版。

### Skill 编写：skill-creator-plus

原版捆绑了 `writing-skills`。我用的是自己的 **`skill-creator-plus`**（一个全局用户级 skill）来创建和测试 skill。这个模块不在这里。

## 安装

首先，禁用官方 Superpowers（两个都启用 = 双 hook 注入，冲突指令）：

```json
// 在 ~/.claude/settings.json 中
"enabledPlugins": {
  "superpowers@claude-plugins-official": false
}
```

然后：

```bash
git clone git@github.com:Joe-zhouman/athena-guard-superpowers.git ~/athena-guard-superpowers
cd ~/athena-guard-superpowers
bash install.sh        # linux
# .\install.ps1        # windows
```

`install.sh` 做两件事：
1. 把仓库 symlink 到 `~/.claude/skills/athena-superpowers/`——hooks 和 skills 通过 `@skills-dir` 自动加载
2. 把 9 个代理复制到 `~/.claude/agents/` 作为用户级全局代理——插件级代理会丢失 `permissionMode`/`mcpServers`（安全限制），而 athena 的代理需要这些能力

启动新 session。验证步骤见 `docs/athena/INSTALL.md`。

卸载：

```bash
bash uninstall.sh      # linux
# .\uninstall.ps1      # windows
```

## 工作流

1. **brainstorming**——任何创造性工作前激活。从磁盘读取之前的研究结果，可选派 virgo/sagittarius 获取上下文，然后盘问你（一次一个问题、推荐答案、苏格拉底式 interview）。呈现设计供审批。委托给 writing-spec。
2. **writing-spec**——将设计形式化为痛点驱动的 spec。问题 → 设计决策理由 → 实现说明 → 验收条件。派 libra 审查。用户审批。交给 writing-plans。
3. **writing-plans**——把 spec 拆成小块任务（每个 2-5 分钟），带精确文件路径和验证步骤。libra 审查。交给执行。
4. **subagent-driven-development**——每个任务一个全新的 `capricorn` 子代理，后面跟着 `scorpio`（规格符合性）然后 `taurus`（代码质量）。快速迭代，每个任务隔离上下文。
5. **test-driven-development**——RED-GREEN-REFACTOR 在实现层面强制执行。写失败测试、看到它失败、写最小代码、看到它通过、提交。
6. **verification-before-completion**——先有证据再断言。跑测试，看到它们通过，然后声称完成。

编排者（GLM-5.2）处理步骤 1-3（设计、spec、计划）。便宜模型上的子代理处理步骤 4-6（实现、测试、审查）。

## 代理模型配置

分层架构需要配置子代理模型。在 `~/.claude/settings.json` 中：

```json
{
  "subagentModels": {
    "haiku": "deepseek-v4-flash",
    "sonnet": "deepseek-v4-pro",
    "opus": "glm-5.2",
    "fable": "glm-5.2"
  }
}
```

编排 skill 使用 `opus`/`fable` 做设计和审查。实现代理用 `haiku` 做机械工作，用 `sonnet` 做需要更多智能的任务。根据你自己的模型情况调整。

## 内容一览

### Skills

**设计与规划**
- **brainstorming**——盘问驱动的设计精炼（合并 superpowers 流程 + grill-me interview 风格）
- **writing-spec**——痛点驱动的 spec，强制 libra 审查
- **writing-plans**——为子代理执行准备的微型实现计划

**实现**
- **subagent-driven-development**——每个任务新子代理 + 两阶段审查（scorpio → taurus）
- **executing-plans**——带检查点的批量执行
- **dispatching-parallel-agents**——独立任务的并发子代理工作流
- **test-driven-development**——RED-GREEN-REFACTOR + 测试反模式参考

**质量**
- **requesting-code-review**——预审查清单，派 taurus
- **receiving-code-review**——以技术严谨性回应反馈

**调试**
- **systematic-debugging**——4 阶段根因分析流程
- **verification-before-completion**——先证据后断言，永远

**基础设施**
- **using-git-worktrees**——特性开发隔离工作区
- **finishing-a-development-branch**——合并/PR/清理决策

**元**
- **using-superpowers**——session 启动时引导技能系统

### Agents

所有 9 个代理在 `user-agents/` 中，安装到 `~/.claude/agents/` 作为用户级全局代理。完整目录：`docs/athena/OVERVIEW.md`。

## 痛点驱动开发

这是 `writing-spec` skill 以及整个 fork 的设计理念：

1. **每一行代码必须解决一个真实的痛点。** 如果说不出来痛点是什么，你就不需要代码。每个 spec 的"问题"章节是道关卡——如果它是空的，停下。
2. **设计决策理由必须解释 WHY。** 没有理由的 spec 是没有推理过程的食谱。未来的维护者需要知道哪些约束是故意的，哪些是偶然的。
3. **每个关卡必须由独立代理审查。** 你不能审查自己的输出。libra、scorpio 和 taurus 之所以存在，就是因为自审是盲区。
4. **不写下来就会丢。** 上下文是临时的，文件是永久的。每个发现、每个决策、每个审查结论都要写到磁盘。

## For Agents

<!-- 机器可读。人类读者请跳过，直接看 Credits。 -->

### 这是什么

基于 [obra/superpowers](https://github.com/obra/superpowers) 的个人 fork，重建为多模型编排工作流。将 `general-purpose` 子代理替换为 9 个星座人格化的专用守卫。GLM-5.2 负责编排设计和规划，DeepSeek 模型负责执行实现和审查。仅支持 Claude Code。

### 文件结构

- `skills/`——14 个可组合技能，通过 `@skills-dir` 自动加载。引导入口：`skills/using-superpowers/SKILL.md`
- `user-agents/`——9 个代理 `.md` 定义文件 + `refs/`（渐进式披露参考）。安装时复制到 `~/.claude/agents/`，不是 symlink。命名为 `user-agents/` 而非 `agents/`，防止被 @skills-dir 自动发现导致重复注册
- `hooks/`——SessionStart hook，每个 session 开始时注入 `using-superpowers` 引导程序
- `docs/athena/`——面向人类的文档（OVERVIEW.md、INSTALL.md）
- `docs/superpowers/`——代理发现持久化目录（spec、plan、findings、review、diagnosis）
- `install.sh` / `install.ps1`——安装（symlink skills 到 `~/.claude/skills/`，复制 agents 到 `~/.claude/agents/`）
- `uninstall.sh` / `uninstall.ps1`——卸载（删除 symlink、agents、refs）

### 代理调度速查

| 守卫 | 何时调度 | 建议 model 层级 |
|------|---------|----------------|
| **capricorn** | 实现任务：TDD、vertical slice、commit | fable |
| **scorpio** | capricorn 完成后——审查规格符合性 | fable |
| **taurus** | scorpio 通过后——审查代码质量，按文件:行号说话 | sonnet |
| **libra** | brainstorming/writing-plans 阶段——审查 plan 或 spec | sonnet |
| **cancer** | Bug 报告：诊断、修复、添加 regression test | sonnet |
| **virgo** | 需要代码地图——探索代码库并持久化到磁盘 | haiku |
| **sagittarius** | 需要外部调研——库文档、API 行为 | haiku |
| **aries** | 声称"完成"后——对抗测试；改 skills/agents/hooks/MCP 时强制调度 | sonnet |
| **pisces** | 文本需要润色——去 AI 味、更像人话 | sonnet |

### 关键规则

- **文件持久化是强制的。** 每个发现必须写入 `docs/superpowers/`。技能在向用户提问前必须先读盘。已写入每个技能定义。
- **每个关卡必须由独立代理审查。** 永远不要自我审查。libra/scorpio/taurus 的存在就是因为自审是盲区。
- **永远不要调用 `general-purpose`。** 所有技能通过名字调度。如果 `skills/` 下任何文件里有 `general-purpose`、`implementer-prompt` 或 `spec-reviewer-prompt`，那是 bug——删掉。
- **每个任务一个子代理，每个子代理新开进程。** 每个实现任务隔离上下文。
- **安装前必须先禁用官方 superpowers**——两者都注入 SessionStart hook，必然冲突。
- **修改代理后必须重跑 `install.sh`**——代理是复制过去的，不是 symlink，改动不会自动同步。
- **Model 层级配置**（在 `~/.claude/settings.json` 中）：`haiku` → deepseek-v4-flash，`sonnet` → deepseek-v4-pro，`opus`/`fable` → glm-5.2。不可用的模型静默继承。
- **痛点关卡：** 没有痛点 → 没有 spec → 没有代码。

## 性能与 Token 消耗

**这个插件很重。** 它优先保证正确性和流程，而非 token 效率。每一项设计决策——专用子代理、强制独立审查、文件持久化、"为什么"的解释——都在消耗 token。我接受这个代价。安装前，请搞清楚你签的是什么单。

### 每个环节的消耗

**每个 session 的启动开销（~4K tokens）：**

SessionStart hook 强制在每次 session 开始时读取 `using-superpowers`（11,624 字节，约 2,900 tokens），好让主代理知道如何查找和调用 skill。hook 本身还有约 1,200 tokens 的前导文本。这个开销无法避免——它是让技能系统运转的入场费。

**一次完整工作流的开销（~40–50K tokens）：**

一个典型的三任务 feature 从 brainstorm 到 merge：

| 阶段 | 加载内容 | Token 开销 |
|------|---------|-----------|
| Session 启动 | using-superpowers + hook 前导 | ~4,100 |
| Brainstorming | brainstorming SKILL.md（4,300 tokens）、virgo/sagittarius 代理定义（如派发约 4,400 tokens） | ~4,300–8,700 |
| 写 spec | writing-spec SKILL.md（3,300 tokens）、libra 代理定义（1,700 tokens） | ~5,000 |
| 写 plan | writing-plans SKILL.md（2,100 tokens）、libra 再次（1,700 tokens） | ~3,800 |
| 每个任务 ×3 | capricorn（2,400）+ scorpio（1,700）+ taurus（1,600）+ skill overhead | 每个约 5,700 |
| 文件读写 | 读取 findings、glossary、已有 spec；写入 review 和 progress | ~3,000–5,000 |
| **近似合计** | | **~42,000–50,000 tokens** |

这还只是插件的开销。实际代码上下文（源文件、测试输出、git diff）叠加在上面。

### 常驻成本

| 资源 | 体积 | 等值 token |
|------|------|-----------|
| 14 个 skill SKILL.md | 160 KB | ~40,000 tokens |
| 9 个子代理定义 | 77 KB | ~19,000 tokens |
| 9 个渐进式披露 ref | 22 KB | ~5,500 tokens |
| **盘上指令总质量** | **~260 KB** | **~65,000 tokens** |

不是所有内容同时加载——skill 按需触发，代理只在派发时才载入。但在一次完整工作流中，大部分确实会被用到。

### 消耗换来了什么

这些 token 不是交智商税。每项开销都有它要防止的具体失败模式：

| 开销 | 防止的问题 |
|------|-----------|
| 每个代理定义中的"为什么"解释 | 便宜模型上的子代理跑偏，纠错消耗远大于解释本身的成本 |
| 强制 libra/scorpio/taurus 三级审查 | 错需求的实现或 bug 上线，修复成本按数量级计算 |
| 文件持久化（findings、spec、glossary） | 每次 session 被截断后重新推导上下文 |
| 专用代理替代 general-purpose | `general-purpose` 子代理载入后先花 token 摸索方向，再开始真正干活；专用代理载入即开工 |

一个跑偏的便宜模型子代理，浪费的 token 远超整场 session 所有"为什么"段落的合计。一个因跳过审查而上线的 bug，调试时间比所有 libra 派发加在一起都多。开销是真实的，但它买的是对更大损失的保险。

### 底线

如果你直接用 Claude Opus（像上游 superpowers 假设的那样），性价比等式不同——Claude 足够聪明，不需要这么多手把手指导，指令消耗可能大于节省。如果你像我一样用分层模型配置（GLM-5.2 编排 + DeepSeek 工人），这套开销是**净正收益**：编排者的昂贵 token 被节省，工人的便宜 token 被用于防止昂贵错误的指导。我每天都在用，token 预算是能跑通的。

**如果你是成本敏感型用户，三思。** 这不是轻量插件。如果你的上下文窗口经常塞满，或者 token 预算吃紧，这可能不适合你。上游 superpowers 也不轻量——想要轻量的，去拿 [Matt Pocock 的 skills](https://github.com/mattpocock/skills) 自由组合。实际上，本 repo 设计上就是和他的 skills 一起用的——你可以在工作流的任意节点插入他的 skill，互不打架。两个 repo 都信仰文件持久化——只是落地路径不同。Matt 的 skills 写到 ADR、PRD 和 GitHub Issues；athena 的代理写到 `docs/superpowers/`。不同路径，不同格式，同一哲学，零碰撞。除此之外，随便混搭。

## 鸣谢

这是一个个人 fork，由 [Joe-zhouman](https://github.com/Joe-zhouman) 基于 [Jesse Vincent](https://blog.fsck.com) 的 [Superpowers](https://github.com/obra/superpowers)（~5.0.x）改造。原版是一个非凡的项目——这个 fork 的存在是因为我的约束条件（国产模型、频率限制、配额成本）需要不同的架构，而不是因为原版有问题。

- 原版：[github.com/obra/superpowers](https://github.com/obra/superpowers)
- 原版文档：[blog.fsck.com/2025/10/09/superpowers](https://blog.fsck.com/2025/10/09/superpowers/)
- 我的 fork：[github.com/Joe-zhouman/athena-guard-superpowers](https://github.com/Joe-zhouman/athena-guard-superpowers)

## 许可证

MIT——见 LICENSE 文件。