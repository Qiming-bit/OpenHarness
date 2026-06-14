# OpenHarness 学习计划

> OpenHarness 是 HKUDS 开源的 Agent Harness 框架，定位为 Claude Code 的开源替代/扩展。
> 它是一个轻量、可扩展、可检查的 AI Agent 基础设施，支持多模型、多渠道、多 Agent 协同。

---

## 阶段一：搭建环境 & 整体认知（1-2 天）

### 目标
跑通项目，理解 Agent Loop 的基本概念。

### 学习内容
| # | 任务 | 关键文件 |
|---|------|----------|
| 1 | 安装依赖、启动 `oh` 交互模式 | `pyproject.toml`, `scripts/install.sh` |
| 2 | 尝试对话、工具调用、权限审批 | 体验 TUI |
| 3 | 阅读 CLI 入口，理解命令解析流程 | `src/openharness/cli.py` |
| 4 | 理解 Provider 认证与配置系统 | `src/openharness/config/settings.py`, `src/openharness/auth/` |
| 5 | 尝试 Dry-run 模式，预览配置 | CLI `--dry-run` |

### 提炼
- **架构亮点**：CLI → 配置加载 → QueryEngine → Agent Loop → Tool 执行 → 输出，链路清晰，适合学习"AI Agent 系统"的完整生命周期
- **面试考点**：Agent Loop 的概念、流式 tool-call cycle 的工作机制、指数退避重试策略

---

## 阶段二：核心引擎 — Agent Loop（2-3 天）

### 目标
深入理解 Agent Loop 的运作机制，这是整个框架的心脏。

### 学习内容
| # | 任务 | 关键文件 |
|---|------|----------|
| 1 | 阅读 QueryEngine，理解对话引擎主循环 | `src/openharness/engine/query_engine.py` |
| 2 | 理解流式响应 + tool call 的解析逻辑 | `src/openharness/api/` 下各 provider 客户端 |
| 3 | 理解 token 计数、成本控制、上下文压缩 | `src/openharness/engine/` 相关代码 |
| 4 | 理解 auto-compact（自动压缩）机制 | 记忆中提到的 auto-compact |
| 5 | 画一张 Agent Loop 的时序图 | — |

### 提炼
- **核心亮点**：
  - 支持 5 种 Provider Workflow（Anthropic / OpenAI / Claude Sub / Codex Sub / Copilot），一套框架适配多模型
  - 流式 tool-call cycle 中同时处理 streaming text 和 tool call block
  - token 计数与成本跟踪，适合企业场景
- **难点/面试考点**：
  - 不同 Provider 的 API 格式差异如何统一抽象？（适配器模式）
  - 流式响应中如何正确解析 tool call 的 JSON 结构？（状态机/缓冲）
  - auto-compact 的触发时机和策略（token 阈值？滑动窗口？）

---

## 阶段三：工具系统 — 43+ Tools（2-3 天）

### 目标
理解工具注册、执行、权限校验的完整流程。

### 学习内容
| # | 任务 | 关键文件 |
|---|------|----------|
| 1 | 阅读 ToolRegistry，理解工具注册机制 | `src/openharness/tools/` |
| 2 | 选 3-5 个典型工具深入阅读（bash/grep/file_edit/web_search/mcp） | `src/openharness/tools/` 各子目录 |
| 3 | 理解权限校验流程（permission mode、path rules） | `src/openharness/permissions/` |
| 4 | 理解工具的执行结果如何回传给 Agent Loop | QueryEngine 中的 tool execution 部分 |
| 5 | 尝试自己写一个自定义 Tool | 参照现有工具结构 |

### 提炼
- **核心亮点**：
  - 43+ 内置工具覆盖代码操作、文件搜索、网络搜索、图片生成、MCP 工具等
  - 多级权限模式（安全审批 / 路径规则 / 命令黑名单）
  - MCP（Model Context Protocol）集成，可扩展外部数据源
- **难点/面试考点**：
  - 工具调用的权限决策链：何时自动放行？何时需要用户审批？
  - 沙箱执行环境的设计（Docker sandbox）
  - MCP 协议如何与 ToolRegistry 对接？

---

## 阶段四：记忆与会话系统（1-2 天）

### 目标
理解 CLAUDE.md / MEMORY.md 自动发现和会话恢复机制。

### 学习内容
| # | 任务 | 关键文件 |
|---|------|----------|
| 1 | 阅读 MemoryManager，理解 .md 文件自动发现 | `src/openharness/memory/` |
| 2 | 理解会话恢复（session resume）机制 | `src/openharness/engine/` 会话相关代码 |
| 3 | 理解 auto-compact 与记忆的关系 | 结合阶段二的 auto-compact |
| 4 | 阅读 CLAUDE.md / MEMORY.md 的解析逻辑 | `src/openharness/memory/` |

### 提炼
- **核心亮点**：
  - 文件系统驱动的持久记忆（MEMORY.md），跨会话保持
  - CLAUDE.md 自动发现（工作目录向上搜索），上下文自动注入
  - 语义化的记忆分类（user / feedback / project / reference）
- **难点/面试考点**：
  - 如何在 token 有限的情况下选择性地注入记忆？（相关性排序）
  - 会话恢复时如何重建 agent loop 的状态？

---

## 阶段五：Skills & Plugins 系统（1-2 天）

### 目标
理解技能按需加载和插件扩展机制。

### 学习内容
| # | 任务 | 关键文件 |
|---|------|----------|
| 1 | 阅读 Skills 系统，理解 Markdown skill 格式 | `src/openharness/skills/` |
| 2 | 阅读 Plugins 系统 | `src/openharness/plugins/` |
| 3 | 兼容 anthropics/skills 和 Claude-style plugins 的设计 | `src/openharness/skills/` |
| 4 | 尝试写一个自定义 skill/plugin | — |

### 提炼
- **核心亮点**：
  - Markdown 格式的 skill 定义，非代码开发者也能编写
  - 兼容多种 skill 格式（anthropics/skills + Claude-style）
  - 插件系统支持命令扩展、工具扩展、钩子注入
- **难点/面试考点**：
  - Skill 的按需加载策略：如何判断哪些 skill 应该被激活？（语义匹配？关键词？）
  - 插件与工具的边界是什么？

---

## 阶段六：多 Agent 协同 — Swarm（2-3 天）

### 目标
理解 subagent 的生成、执行、生命周期管理。

### 学习内容
| # | 任务 | 关键文件 |
|---|------|----------|
| 1 | 阅读 Swarm 系统，理解 subagent 架构 | `src/openharness/swarm/` |
| 2 | 理解 subagent 的生成、任务分配、结果回传 | `src/openharness/swarm/` |
| 3 | 阅读多 Agent 协调器 | `src/openharness/coordinator/` |
| 4 | 理解任务管理（create/list/stop/update） | `src/openharness/tasks/` |
| 5 | 理解 Autopilot 自动化调度 | `src/openharness/autopilot/` |

### 提炼
- **核心亮点**：
  - 父子 Agent 架构，父 Agent 决定任务拆分和 subagent 生成
  - subagent 后台执行 + 前台监控，支持并发
  - Autopilot 自动化调度（Cron 定时任务 + 事件触发）
- **难点/面试考点**：
  - 父 Agent 如何决定任务拆分策略？（LLM 决策 vs 规则）
  - subagent 的上下文隔离：如何避免多个 subagent 的文件操作冲突？
  - subagent 结果如何 merge 回主对话？

---

## 阶段七：IM 渠道适配（1-2 天）

### 目标
理解多渠道接入的设计模式。

### 学习内容
| # | 任务 | 关键文件 |
|---|------|----------|
| 1 | 阅读 Channels 架构，理解适配器模式 | `src/openharness/channels/` |
| 2 | 深入 2-3 个渠道实现（Telegram / 飞书 / Discord） | `src/openharness/channels/` |
| 3 | 理解 Bridge 会话管理 | `src/openharness/bridge/` |

### 提炼
- **核心亮点**：
  - 支持 9+ IM 渠道（Telegram / Slack / Discord / 飞书 / 钉钉 / QQ / WhatsApp / Email / Matrix）
  - 统一的消息抽象层，渠道适配只负责格式转换
- **难点/面试考点**：
  - 不同 IM 的消息格式差异如何处理？（富文本 / 图片 / 文件）
  - Bridge 如何管理多渠道的会话状态映射？

---

## 阶段八：Hook 系统 & 安全治理（1-2 天）

### 目标
理解事件驱动钩子和安全治理机制。

### 学习内容
| # | 任务 | 关键文件 |
|---|------|----------|
| 1 | 阅读 HookExecutor，理解事件钩子 | `src/openharness/hooks/` |
| 2 | 理解多级权限模式 | `src/openharness/permissions/` |
| 3 | 理解路径规则（path rules） | `src/openharness/permissions/` |
| 4 | 理解沙箱环境 | `src/openharness/sandbox/` |

### 提炼
- **核心亮点**：
  - 事件驱动钩子系统（pre-tool / post-tool / on-error 等）
  - 多级权限：完全自动 / 审批模式 / 只读模式
  - 路径级别的细粒度控制（允许/禁止特定目录）
- **难点/面试考点**：
  - 权限检查的决策链路是如何构建的？
  - Hook 的执行顺序和错误处理策略

---

## 阶段九：ohmo Personal Agent（1-2 天）

### 目标
理解基于 OpenHarness 构建的个人助理应用。

### 学习内容
| # | 任务 | 关键文件 |
|---|------|----------|
| 1 | 阅读 ohmo 入口和架构 | `ohmo/cli.py`, `ohmo/runtime.py` |
| 2 | 理解个人记忆系统（soul.md / user.md） | `ohmo/memory.py` |
| 3 | 理解 Gateway 多渠道网关 | `ohmo/gateway/` |
| 4 | 理解工作空间管理 | `ohmo/workspace.py` |

### 提炼
- **核心亮点**：
  - 人格定义文件（soul.md）+ 用户画像文件（user.md），可定制化
  - 独立于 OpenHarness 核心，作为上层应用存在
- **面试考点**：
  - 框架 vs 应用的边界如何划分？（OpenHarness 是框架，ohmo 是基于框架的应用）
  - 个人记忆如何与通用记忆系统区分？

---

## 阶段十：前端 TUI & 总结（1-2 天）

### 目标
理解 React TUI 前端架构，总结全部学习成果。

### 学习内容
| # | 任务 | 关键文件 |
|---|------|----------|
| 1 | 阅读 React TUI 前端结构 | `frontend/terminal/` |
| 2 | 理解 Autopilot 可视化面板 | `autopilot-dashboard/` |
| 3 | 整理学习笔记，画整体架构图 | — |
| 4 | 总结面试亮点和难点 | — |

---

## 面试亮点总结

### 项目整体亮点
1. **完整的 Agent 基础设施**：从 Agent Loop、Tool 系统、Memory、Skills、Plugins 到多 Agent 协同、多渠道接入，覆盖了 AI Agent 系统的所有关键组件
2. **多 Provider 适配**：一套框架同时支持 Anthropic / OpenAI / Claude / Codex / Copilot 五种工作流
3. **生产级治理**：权限控制、路径规则、沙箱、Hook，适合企业级部署
4. **文件系统驱动的记忆**：MEMORY.md / CLAUDE.md 自动发现，简单有效

### 技术难点
1. **流式 tool-call 解析**：不同 Provider 的 stream 格式差异大，需要统一的状态机处理
2. **多 Agent 上下文隔离**：subagent 之间的文件操作、会话状态如何互不干扰
3. **Token 管理与 auto-compact**：在有限上下文窗口中决定保留/丢弃哪些信息
4. **多渠道消息格式统一**：9+ IM 渠道的消息格式差异（富文本、图片、文件、按钮）
5. **权限决策链**：多层规则（全局 / 路径 / 命令）的优先级和冲突处理

### 可展示的学习成果
1. Agent Loop 时序图 + 核心代码阅读笔记
2. 自定义 Tool 实现（展示对 ToolRegistry 的理解）
3. 自定义 Skill/Plugin 实现
4. 多渠道适配器分析对比
5. 多 Agent 协同流程图
