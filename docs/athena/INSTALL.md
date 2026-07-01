# Install & Verify

athena-superpowers **替换**官方 superpowers,不共存(同时启用会双 hook 注入,主 agent 收到冲突指令)。

## 前置:关掉官方 superpowers

官方 superpowers 和本 fork 的 SessionStart hook 几乎一样,同时启用 = 每个 session 注入两份 `<EXTREMELY_IMPORTANT>`,内容互相冲突(官方派 general-purpose,athena 派 capricorn)。装 athena 前必须先关官方:

编辑 `~/.claude/settings.json`,把官方 superpowers 设为 false:

```json
"enabledPlugins": {
  "superpowers@claude-plugins-official": false
}
```

## 安装(linux)

```bash
git clone <athena-superpowers repo> ~/athena-superpowers   # 或任意位置
cd ~/athena-superpowers
bash install.sh
```

`install.sh` 做两件事(机制不同,各取所长):

| 组件 | 装到哪 | 机制 | 为什么这样 |
|------|--------|------|-----------|
| **hooks + skills** | `~/.claude/skills/athena-superpowers/`(symlink 指向仓库) | CC 的 `@skills-dir` 自动加载,下次 session 生效 | hooks/skills 无字段限制,symlink 让改仓库即时反映 |
| **agents(9 个)+ refs** | `~/.claude/agents/`(copy) | 用户级全局 agent | **关键**:plugin 级 agent 会被剥掉 `permissionMode`/`mcpServers`(安全限制),而 athena 的 capricorn 要 `acceptEdits`、sagittarius 要 `mcp__doc`——必须用户级才保留这些能力 |

## 验证

新开一个 Claude Code session,然后:

1. **plugin 加载了** — `/plugin` 列表应含 `athena-superpowers@skills-dir`
2. **session-start hook 注入** — session 开头应看到 `<EXTREMELY_IMPORTANT>You have superpowers...`(来自本 fork 的 hooks/session-start)
3. **agents 全局可用** — agent 列表(或 `@` typeahead)应有 capricorn/cancer/scorpio/taurus/libra/virgo/sagittarius/aries/pisces 共 9 个
4. **dispatch 对了** — 跑个最小任务:让主 agent 走 brainstorming 写 spec,看是否派 **libra** 审 spec(而不是主 agent 自己 Self-Review);用 subagent-driven-development 执行,看是否派 **capricorn** 实现、DONE 后派 **scorpio → taurus**

如果某步还是 general-purpose,说明该 SKILL.md 的 dispatch 段没改干净:

```bash
grep -rn "general-purpose\|implementer-prompt\|spec-reviewer-prompt\|code-quality-reviewer-prompt" \
  skills/
```
应无输出。

## 更新

```bash
cd ~/athena-superpowers
git pull
bash install.sh   # 重跑覆盖 agents(copy 的不会自动更新)
```

更新语义(分组件):

- **SKILL.md 改了** → 当前 session 立即生效(CC 有 live change detection,无需任何操作)
- **hooks 改了** → `/reload-plugins` 或新 session
- **agents 改了** → **必须重跑 `install.sh`**(copy 的副本不会自动更新),然后 `/reload-plugins` 或新 session

`claude plugin update` 对 `@skills-dir` 插件是 no-op(没有 marketplace 源),所以更新靠 `git pull` + 上面三条。

## 平台

- **linux** — `install.sh` / `uninstall.sh`(已支持)
- **Windows** — `install.ps1` / `uninstall.ps1`(已支持)
- **macOS** — 暂不支持

## 卸载

```bash
# linux
bash uninstall.sh

# windows
.\uninstall.ps1
```

卸载做三件事:删 plugin symlink/junction、删 agent 文件、删 ref 文件。不影响 `~/.claude/agents/` 下的其他 agent。你的仓库克隆本身不删,需要手动 `rm -rf`。

## 与官方 superpowers 的差异(给未来 merge 用)

官方发新版想合并时,这些是 athena 改过的地方,需手动 port:

| 文件 | 改动 |
|------|------|
| `.claude-plugin/plugin.json` | name → athena-superpowers,version → 5.1.0-athena |
| `user-agents/*.md` + `user-agents/refs/` | 新增 9 个全局 agent(官方无此目录)+ 渐进式披露 refs。命名为 `user-agents/` 而非 `agents/`,防止 @skills-dir 插件自动发现导致 agent 重复注册 |
| `install.sh` / `install.ps1` / `uninstall.sh` / `uninstall.ps1` / `tests/test-install.sh` | 新增:跨平台安装/卸载 + TDD 测试 |
| `skills/subagent-driven-development/SKILL.md` | implementer/spec-reviewer/code-quality-reviewer → capricorn/scorpio/taurus;加 Aries Gate;删 Prompt Templates |
| `skills/subagent-driven-development/*-prompt.md` | **已删** |
| `skills/requesting-code-review/SKILL.md` | 派 taurus;删 code-reviewer.md 引用 |
| `skills/requesting-code-review/code-reviewer.md` | **已删** |
| `skills/writing-plans/SKILL.md` | Self-Review → 派 libra |
| `skills/writing-plans/plan-document-reviewer-prompt.md` | **已删** |
| `skills/brainstorming/SKILL.md` | Self-Review → 派 libra;加 grill-me 风格 interview(一问一答 + 推荐答案);spec 阶段委托 `writing-spec`;删 cross-platform 段 |
| `skills/brainstorming/spec-document-reviewer-prompt.md` | **已删** |
| `skills/writing-spec/SKILL.md` | **新增**:pain-point-driven spec 格式(合并全局 spec-writer),libra 审 + user review gate,handoff 到 writing-plans |
| 各 SKILL.md | 加 why(禁令+解释风格)、删跨平台段 |
| `hooks/session-start` | 加 hash-pin(C1 防 SKILL.md 篡改);`hooks/update-skill-hash`、`hooks/.skill-hash` 新增 |

升级时:`git diff` 官方新版与本 fork,把官方改进 port 进来,**但保留上面这些 athena 改动**。

## For Agents

<!-- Machine-readable. 安装/卸载规则速查。主 agent 通过 grep 定位。 -->

### Install

```bash
git clone <this-repo> ~/athena-superpowers
cd ~/athena-superpowers && bash install.sh   # linux
# .\install.ps1                               # windows
```

`install.sh` 做两件事：
1. Symlink `skills/` + `hooks/` → `~/.claude/skills/athena-superpowers/`（下次 session 生效）
2. 复制 `user-agents/*.md` + `user-agents/refs/` → `~/.claude/agents/`（用户级全局 agent 保留 `permissionMode`/`mcpServers`）

### Uninstall

```bash
bash uninstall.sh   # linux
# .\uninstall.ps1   # windows
```

删除 symlink、agent 文件、ref 文件。不影响 repo 克隆本身。

### 关键规则

- **安装前必须先禁用官方 superpowers**（`~/.claude/settings.json` 中设 `"superpowers@claude-plugins-official": false`）。两套 SessionStart hook 同时注入会导致冲突指令。
- **修改 agent `.md` 文件后必须重跑 `install.sh`。** Agent 是复制过去的，不是 symlink，改动不会自动同步。
- **修改 hooks 后需执行 `/reload-plugins` 或启动新 session。**
- **`claude plugin update` 对 `@skills-dir` 插件是 no-op**（没有 marketplace 源）。更新靠 `git pull` + `install.sh`。
- **不支持 macOS。** 仅 Linux 和 Windows。
- **跨平台脚手架（Codex/Cursor/Gemini/Copilot/OpenCode）已全部移除。** 仅支持 Claude Code。
