# Project 01：Baseline vs Minimal Harness

比较弱 harness（只靠 prompt）和显式 harness（规则文件 + 验证机制）对 AI 编码代理任务完成率的影响。

## 目录说明

| 目录 | 含义 |
|------|------|
| `starter/` | **起点**：只有一个模糊的 `task-prompt.md`，没有 `AGENTS.md`，也没有 `feature_list.json`。这是给 agent 的「弱 harness」版本。 |
| `solution/` | **参考实现**：相同的应用代码，但配备完整的 harness 文件（`AGENTS.md`、`feature_list.json`、`init.sh`、`claude-progress.md`）。这是「显式 harness」版本。 |

## 使用方法

```sh
# 1. 用 starter（弱 harness）跑一次 agent 任务
cd starter
npm install
# 把 task-prompt.md 的内容作为 prompt 给 Claude Code / Codex
# 让 agent 尝试完成：窗口启动、文档列表、问答面板、数据目录
# 本轮不要把 solution 文件提供给 agent。

# 2. 用 solution（显式 harness）跑同一个任务
cd ../solution
npm install
# 让 agent 在改代码前先阅读 AGENTS.md、init.sh、feature_list.json 和 claude-progress.md
# 产品代码本身应该已经满足相同的四个功能。

# 3. 对比两次结果
# - 任务是否完成？
# - 需要重试几次？
# - agent 是否过早声称「完成」？
```

## 明确任务契约

`starter` 的 prompt 是刻意模糊的：`starter/task-prompt.md` 只包含一句话：

```text
Build an Electron app that can show documents and answer questions.
```

使用 `solution` 中的 harness，把这个模糊请求具体化：

| 功能 | 在 starter 中检查的证据 | 在 solution 中对比的证据 |
|------|------|------|
| 窗口启动 | `src/main/main.ts`、`src/preload/preload.ts` | `feature_list.json` 中的 `window-launch` |
| 文档列表面板 | `src/renderer/components/DocumentList.tsx` | `feature_list.json` 中的 `document-list` |
| 问答面板 | `src/renderer/components/QuestionPanel.tsx` | `feature_list.json` 中的 `question-panel` |
| 数据目录 | `src/services/persistence-service.ts` | `feature_list.json` 中的 `data-directory` |

这个项目是一个实验，不是普通的「把 starter 补到和 solution 一样」的作业。学习目标是测量只靠 prompt 的运行方式，与从明确仓库规则和验证产物开始的运行方式之间的差异。

## 覆盖功能

- Electron 窗口成功启动
- UI 显示文档列表区域
- UI 显示问答面板
- 应用创建并使用本地数据目录

## 相关讲义

- [Lecture 01: Why Capable Agents Still Fail](../../docs/en/lectures/lecture-01-why-capable-agents-still-fail/index.md)
- [Lecture 02: What a Harness Actually Is](../../docs/en/lectures/lecture-02-what-a-harness-actually-is/index.md)
