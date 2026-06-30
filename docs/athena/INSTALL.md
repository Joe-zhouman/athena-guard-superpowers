# Install & Verify

本插件是 superpowers 的 athena 改造版,**替换**而非共存于官方 superpowers。

## 安装

```bash
# 1. 卸载官方 superpowers(避免冲突)
claude plugin remove superpowers

# 2. 把本插件加为本地插件
claude plugin add /path/to/athena-superpowers

# 3. 确认启用
claude plugin list   # 应看到 athena-superpowers,且无 superpowers
```

8 个 agent 随插件自动生效,无需单独 symlink。

## 验证改造生效

跑一个最小任务,确认 superpowers 派的是 athena agent 而不是 general-purpose:

1. 让主 agent 走 brainstorming 写一个简单 spec(看是否用 spec-writer 格式:Problem / Design Rationale / Acceptance)
2. spec 写完,看是否派 **libra** 审 spec(而不是主 agent 自己 Self-Review)
3. plan 写完,看是否派 **libra** 审 plan
4. 用 subagent-driven-development 执行一个任务,看是否派 **capricorn** 实现
5. capricorn 报 DONE 后,看是否依次派 **scorpio** → **taurus**

如果某步还是 general-purpose,说明该 SKILL.md 的 dispatch 段没改干净。检查:

```bash
# 应无输出(只剩 references/ 下的文档引用无关紧要)
grep -rn "general-purpose\|implementer-prompt\|spec-reviewer-prompt\|code-quality-reviewer-prompt\|code-reviewer.md" \
  /path/to/athena-superpowers/skills/
```

## 与官方 superpowers 的差异(给未来 merge 用)

如果官方发了新版你想合并,这些是你改过的地方,需要手动 port:

| 文件 | 改动 |
|------|------|
| `.claude-plugin/plugin.json` `marketplace.json` `package.json` | name → athena-superpowers,version → 5.1.0-athena |
| `.claude/agents/*.md` | 新增 8 个 agent(官方无此目录) |
| `skills/subagent-driven-development/SKILL.md` | implementer/spec-reviewer/code-quality-reviewer → capricorn/scorpio/taurus;删 Prompt Templates 段;Model Selection 改写 |
| `skills/subagent-driven-development/*-prompt.md` | **已删** |
| `skills/requesting-code-review/SKILL.md` | 派 taurus;删 code-reviewer.md 引用 |
| `skills/requesting-code-review/code-reviewer.md` | **已删** |
| `skills/writing-plans/SKILL.md` | Self-Review → 派 libra |
| `skills/writing-plans/plan-document-reviewer-prompt.md` | **已删**(原本就是孤儿) |
| `skills/brainstorming/SKILL.md` | Spec Self-Review → 派 libra;加 spec-writer 格式段 |
| `skills/brainstorming/spec-document-reviewer-prompt.md` | **已删**(原本就是孤儿) |

升级时:`git diff` 官方新版与你的 fork,把官方的改进 port 进来,**但保留上面这些 athena 改动**。
