# 中文参考

这一部分解释这些模板该怎么配合使用，而不是把它们当成一堆孤立文件。

## 内部参考材料

- [`method-map.md`](./method-map.md)：把常见长时任务翻车点映射到对应方法和工件
- [`initializer-agent-playbook.md`](./initializer-agent-playbook.md)：初始化代理在第一轮应该产出什么
- [`coding-agent-startup-flow.md`](./coding-agent-startup-flow.md)：后续编码代理每次开工的固定流程
- [`prompt-calibration.md`](./prompt-calibration.md)：根指令应该写到什么程度才合适

## 重点参考文章

这里的筛选标准很窄：只保留能直接解释 harness 机制的文章。Harness 在这里指模型外部的运行系统，包括 agent loop、工具执行、沙箱、状态、上下文、验证、终止条件、控制平面和观测反馈；不是泛泛的 prompt engineering 或 agent 框架介绍。

保留原始三篇作为课程主轴：

- [OpenAI: Harness engineering: leveraging Codex in an agent-first world](https://openai.com/index/harness-engineering/)（2026-02-11）：agent-first 仓库、repo-local context、custom lint、结构性 guardrail。
- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)（2025-11-26）：initializer agent、coding agent、feature list、progress log、跨上下文窗口交接。
- [Anthropic: Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps)（2026-03-24）：planner / generator / evaluator 三角色、context reset、harness 简化和组件过期问题。

额外只加入几篇高相关、高含金量的 2026 文章：

- [OpenAI: Unrolling the Codex agent loop](https://openai.com/index/unrolling-the-codex-agent-loop/)（2026-01-23）：解释 Codex runtime harness 的核心循环、工具调用、上下文增长和终止状态。
- [OpenAI: Unlocking the Codex harness: how we built the App Server](https://openai.com/index/unlocking-the-codex-harness/)（2026-02-04）：把 harness 抽象成 App Server 协议，覆盖 thread lifecycle、resume、fork、diff 和客户端集成。
- [Anthropic: Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)（2026-01-09）：明确评估 agent 时评的是 model + harness，并区分 evaluation harness 与 agent harness。
- [Anthropic: Building a C compiler with a team of parallel Claudes](https://www.anthropic.com/engineering/building-c-compiler)（2026-02-05）：并行 agent 团队、任务锁、git 同步、容器隔离和自主循环。
- [Anthropic: Scaling Managed Agents: Decoupling the brain from the hands](https://www.anthropic.com/engineering/managed-agents)（2026-04-08）：meta-harness 视角，把 session、harness、sandbox 拆成可替换接口。
- [OpenAI: An open-source spec for Codex orchestration: Symphony](https://openai.com/index/open-source-codex-orchestration-symphony/)（2026-04-27）：把 issue tracker / Linear 变成多 agent 控制平面。

## 2026 扩展参考

这些文章不作为课程主轴，但在设计特定模块时很有借鉴价值：

- [OpenAI Developers: Run long horizon tasks with Codex](https://developers.openai.com/blog/run-long-horizon-tasks-with-codex)（2026-02-23）：长时任务中的 durable project memory、milestone validation 和 done-when 例子。
- [OpenAI: The next evolution of the Agents SDK](https://openai.com/index/the-next-evolution-of-the-agents-sdk/)（2026-04-15）：model-native harness、sandbox execution、文件与命令执行能力。
- [Anthropic: An update on recent Claude Code quality reports](https://www.anthropic.com/engineering/april-23-postmortem)（2026-04-23）：reasoning effort、context pruning、system prompt 都属于 harness 变更，且需要回归治理。
- [Microsoft: Agent Harness in Agent Framework](https://devblogs.microsoft.com/agent-framework/agent-harness-in-agent-framework/)（2026-03-12）：shell/filesystem harness、approval flow、hosted shell、context compaction。
- [Google: Announcing ADK for Java 1.0.0](https://developers.googleblog.com/announcing-adk-for-java-100-building-the-future-of-ai-agents-in-java/)（2026-03-30）：plugins、event compaction、HITL、session/memory service、A2A。
- [GitHub: Automate repository tasks with GitHub Agentic Workflows](https://github.blog/ai-and-ml/automate-repository-tasks-with-github-agentic-workflows/)（2026-02-13）：GitHub Actions 里的 agentic workflow、safe outputs、sandboxing、permissions、review。
- [AWS: AI agents in enterprises: Best practices with Amazon Bedrock AgentCore](https://aws.amazon.com/blogs/machine-learning/ai-agents-in-enterprises-best-practices-with-amazon-bedrock-agentcore/)（2026-02-03）：Runtime、Memory、Gateway、Policy、Observability、Evaluations 的企业级 harness 分层。

严格按时间筛选时，2025-only 的泛参考不进入主列表。原始三篇中的 Anthropic 2025 文章保留，是因为它是本课程方法的基础来源。

## 推荐阅读顺序

1. `method-map.md`
2. `initializer-agent-playbook.md`
3. `coding-agent-startup-flow.md`
4. `prompt-calibration.md`
5. OpenAI Harness engineering
6. Anthropic Effective harnesses
7. Anthropic Harness design for long-running application development
8. OpenAI Codex agent loop
9. Anthropic agent evals
