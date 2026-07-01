---
name: handoff
description: 把当前对话压缩成一份交接文档给下一个 agent。输入 /handoff 手动触发。
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

把当前对话压缩成一份交接文档，让下一个 agent 能接着干活。存到系统临时目录，别放工作区。

包含一个"建议调用的 skill"段落，列出下一个 agent 可能需要执行的 skill。

已有的产出物（PRD、plan、ADR、issue、commit、diff）不要重复写，用路径或 URL 引用。

敏感信息（API key、密码、个人身份信息）脱敏处理。

如果用户传了参数，把它当作下一个 session 要聚焦的任务描述，据此定制文档。
