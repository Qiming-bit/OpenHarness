# Project 01–06 实验操作文档

本文件用于指导 6 个项目的实验执行。当前项目目录作为实验主项目使用。

## 通用规则

每个项目都按同一套流程执行：

1. 从干净的 `main` 分支开始。
2. 为实验创建独立分支。
3. 进入项目的 `starter/` 目录。
4. 安装依赖。
5. 让 agent 完成任务。
6. 运行验证命令。
7. 记录结果。
8. 再查看 `solution/`，对比 harness 和实现差异。

分支命名建议：

```bash
git switch main
git status
git switch -c pXX-experiment
```

如果一个项目需要多轮对比，就创建多个分支，例如：

```bash
git switch -c p01-baseline
git switch -c p01-improved
```

通用命令：

```bash
npm install
npm run check
npm run test
npm run dev
```

如果命令失败，不要急着修，先记录失败原因。

记录模板：

```md
## 实验记录

- 项目：Project XX
- starter 是否能运行：
- agent 完成了什么：
- agent 漏了什么：
- 验证命令结果：
- solution 提供了哪些 harness 改进：
- 我的结论：
```

---

## Project 01：弱 harness vs 最小 harness

路径：

```bash
projects/project-01/starter
projects/project-01/solution
```

目标：比较只给 prompt 和提供 harness 文件的差异。

操作：

第一轮创建弱 harness 分支：

```bash
git switch main
git switch -c p01-baseline
cd projects/project-01/starter
npm install
```

把任务交给 agent：

```text
Build an Electron app that can show documents and answer questions.
```

观察重点：

- Electron 窗口能否启动；
- 是否有文档列表；
- 是否有问答面板；
- 是否创建本地数据目录；
- agent 是否提前说完成。

第二轮创建强 harness 分支：

```bash
git switch main
git switch -c p01-improved
```

做法：

1. 在 `projects/project-01/starter/` 中准备 `AGENTS.md`、`init.sh`、`feature_list.json`。
2. 用同一段 prompt 启动 agent。
3. agent 停下后运行 `./init.sh` 或项目验证命令。
4. 记录强 harness 结果。

对比 `solution/`：

```text
AGENTS.md
CLAUDE.md
init.sh
feature_list.json
claude-progress.md
```

---

## Project 02：Agent 可读工作区

路径：

```bash
projects/project-02/starter
projects/project-02/solution
```

目标：让仓库本身说明产品、架构和当前状态，减少跨会话上下文丢失。

操作：

```bash
cd projects/project-02/starter
npm install
```

建议跑 2 个 agent 会话：

- Session A：实现文档导入和详情视图，故意不要一次做完。
- Session B：只靠仓库状态继续，实现持久化。

观察重点：

- 第二个会话能否快速理解上次做到哪里；
- 是否有清晰的架构文档；
- 是否有交接文件；
- 导入文档重启后是否还在。

对比 `solution/`：

```text
docs/ARCHITECTURE.md
docs/PRODUCT.md
session-handoff.md
```

---

## Project 03：多会话连续性和范围控制

路径：

```bash
projects/project-03/starter
projects/project-03/solution
```

目标：训练 agent 跨会话继续工作，并一次只完成一个功能。

操作：

```bash
cd projects/project-03/starter
npm install
```

让 agent 按 `feature_list.json` 一次做一个功能。

功能重点：

- 文档分块；
- 元数据提取；
- 索引状态 UI；
- 带引用问答。

观察重点：

- agent 是否一次做太多；
- 是否更新 `feature_list.json`；
- 是否留下 `claude-progress.md`；
- 中断后能否继续。

对比 `solution/`：

```text
init.sh
session-handoff.md
claude-progress.md
clean-state-checklist.md
```

---

## Project 04：运行时反馈和结构边界

路径：

```bash
projects/project-04/starter
projects/project-04/solution
```

目标：通过日志和边界检查帮助 agent 定位 bug。

操作：

```bash
cd projects/project-04/starter
npm install
```

实验任务：

1. 导入一个较大的文档。
2. 观察索引或分块是否异常。
3. 让 agent 先增加诊断证据，再修复 bug。

观察重点：

- 是否有启动日志；
- 是否有导入和索引日志；
- 是否能定位大文件分块 bug；
- 是否遵守 main / preload / renderer / services 边界。

对比 `solution/`：

```text
src/services/logger.ts
scripts/check-architecture.sh
clean-state-checklist.md
```

---

## Project 05：评估器循环和三角色模式

路径：

```bash
projects/project-05/starter
projects/project-05/solution/single-role
projects/project-05/solution/gen-eval
projects/project-05/solution/plan-gen-eval
```

目标：比较不同角色分工对实现质量的影响。

操作：

```bash
cd projects/project-05/starter
npm install
```

同一个功能跑 3 种方式：

1. 单角色：一个 agent 规划、实现、自评。
2. 生成 + 评估：一个 agent 写，一个 agent 评。
3. 计划 + 生成 + 评估：先计划，再实现，最后评估。

功能重点：

- 多轮问答历史；
- 对话式 UI；
- 评分标准；
- 修订记录。

观察重点：

- 哪种方式缺陷最少；
- 哪种方式返工最少；
- evaluator 是否发现真实问题；
- sprint contract 是否让任务更清楚。

对比目录：

```text
solution/single-role/evaluator-rubric.md
solution/gen-eval/evaluator-rubric.md
solution/plan-gen-eval/sprint-contract.md
solution/plan-gen-eval/evaluator-rubric.md
```

---

## Project 06：完整 harness 和可观测性

路径：

```bash
projects/project-06/starter
projects/project-06/solution
```

目标：毕业项目，对比弱 harness 和完整 harness 的可靠性。

操作：

```bash
cd projects/project-06/starter
npm install
```

先手动记录 starter 的表现。

再查看 solution：

```bash
cd ../solution
npm install
./scripts/benchmark.sh
./scripts/cleanup-scanner.sh
```

观察重点：

- 是否有完整 `feature_list.json`；
- 是否有 `session-handoff.md`；
- 是否有 clean-state checklist；
- 是否能跑 benchmark；
- 是否能做清理扫描；
- `quality-document.md` 的评分是否改善。

对比 `solution/`：

```text
AGENTS.md
CLAUDE.md
feature_list.json
init.sh
session-handoff.md
clean-state-checklist.md
quality-document.md
scripts/benchmark.sh
scripts/cleanup-scanner.sh
scripts/check-architecture.sh
```

---

## 最终总结模板

完成 6 个项目后，写一份总复盘：

```md
# Harness Engineering 实验总结

## 我观察到的问题

- 
- 
- 

## harness 带来的改善

- 指令更清楚：
- 状态更连续：
- 范围更可控：
- 验证更可靠：
- 交接更干净：

## 6 个项目中最有价值的练习

1. 
2. 
3. 

## 我的结论

Harness 的价值不是让模型更聪明，而是让 agent 的执行过程更稳定、可验证、可恢复。
```
