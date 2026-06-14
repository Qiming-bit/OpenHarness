# OpenHarness 学习笔记

> 配合 `LEARNING_PLAN.md` 按阶段记录阅读笔记和发现。

---

## 阶段一：搭建环境 & 整体认知

### 环境搭建
- Python 3.12 + venv（`py -3.12`），不用 conda
- 安装：`pip install -e . --index-url https://pypi.org/simple/`（清华源缺 hatchling）
- API 对接阿里云百炼（DashScope），配置文件：`~/.openharness/settings.json`
- 启动：项目目录下 `.venv\Scripts\oh.exe`

### CLI 入口流程（cli.py 2551 行）

**架构：** 基于 `typer` 构建，`__main__.py → app()`

```
__main__.py → app()  [typer.Typer, invoke_without_command=True]
                    │
     ┌──────────────┼───────────────────────
     │              │                       │
  子命令       主入口 main()             其他
(mcp/plugin/   @app.callback()          setup/config
 auth/provider/                          /cron/autopilot
 cron/autopilot)
```

**主入口分支（按优先级）：**

| 条件 | 行为 | 函数 |
|------|------|------|
| `--dry-run` | 构建预览，不实际调模型 | `_build_dry_run_preview()` |
| `--continue/-c` | 恢复当前目录上次会话 | `load_session_snapshot()` → `run_repl()` |
| `--resume/-r` | 按 ID 恢复会话 | `load_session_by_id()` → `run_repl()` |
| `-p/--print` | 单次问答，输出后退出 | `run_print_mode()` |
| `--task-worker` | 后台任务执行 | `run_task_worker()` |
| 默认（无参数） | 进入交互 REPL | `run_repl()` |

**7 个子命令：**
- `mcp` — 管理 MCP 服务器
- `plugin` — 管理插件
- `auth` — 认证管理
- `provider` — 管理 Provider 配置
- `config` — 查看/更新设置
- `cron` — 定时任务调度
- `autopilot` — 仓库自动化管理

**关键文件链：**
- `cli.py` — 参数解析 + 路由分发
- `config/settings.py` — 配置加载（settings.json → env → defaults）
- `ui/app.py` — `run_repl` / `run_print_mode` 实际运行会话
- `__main__.py` — `python -m openharness` 入口

### 配置系统（settings.py）

**优先级（高→低）：**
1. CLI 参数
2. 环境变量（`ANTHROPIC_API_KEY` 等）
3. 配置文件 `~/.openharness/settings.json`
4. 默认值

**注意：** `--settings` 参数已定义但**未实现**（cli.py 第 2298 行定义了参数但从未消费），实际应放全局 `~/.openharness/settings.json`。

**Settings 模型关键字段：**
- `api_key`, `model`, `base_url`, `api_format` — API 连接
- `profiles: dict[str, ProviderProfile]` — 多 Provider 配置
- `active_profile` — 当前生效的 profile 名
- `max_turns`, `permission`, `hooks`, `mcp_servers` — 运行控制

**ProviderProfile 结构：** 每个 profile 包含 `provider`、`api_format`、`auth_source`、`default_model`、`base_url` 等，支持多模型源切换。

**入口参数合并：** `Settings.merge_cli_overrides()` 处理 CLI 参数覆盖，profile 相关字段（model/base_url/api_key 等）会触发 `materialize_active_profile()` 重新解析。

### 认证与 Provider 系统（auth/ 目录）

**核心组件（4 个文件）：**

| 文件 | 职责 |
|------|------|
| `manager.py` | `AuthManager` 认证状态中心，管理 Profile 切换、凭据存取 |
| `storage.py` | 凭据持久化（文件 / keyring 双后端） |
| `flows.py` | 认证流程（API Key / Browser OAuth / Device Code） |
| `external.py` | 外部 CLI 绑定（Claude Desktop 等第三方凭据管理） |

**支持的 11 个 Provider：**
```
anthropic, anthropic_claude, openai, openai_codex, copilot,
dashscope, bedrock, vertex, moonshot, gemini, minimax, modelscope
```

**认证方式优先级（env → file → keyring → missing）：**
1. **环境变量** — 如 `ANTHROPIC_API_KEY`、`OPENAI_API_KEY`
2. **文件存储** — `~/.openharness/credentials.json`（权限 0600）
3. **系统 keyring** — 可选后端（容器/WSL 通常不可用）
4. **外部绑定** — 如 `anthropic_claude` 读取 Claude Desktop 的配置文件
5. **Copilot OAuth** — 独立的 GitHub Copilot token 文件

**Profile ↔ Provider 映射关系：**
```
claude-api        → anthropic (Anthropic-Compatible API)
claude-subscription → anthropic_claude (Claude Desktop 订阅)
openai-compatible → openai
codex             → openai_codex
copilot           → copilot (GitHub Copilot)
dashscope         → dashscope (阿里云)
moonshot / gemini / minimax / modelscope → 各自 API Key
```

**AuthManager 核心能力：**
- `get_auth_status()` — 获取所有 Provider 认证状态
- `use_profile(name)` — 切换 active profile
- `update_profile()` — 修改 profile 配置（provider/base_url/model 等）
- `store_credential()` / `load_credential()` — 凭据存取
- `switch_provider()` — 兼容向后兼容的切换入口（接受 profile 名、provider 名或 auth source 名）

**安全模型（storage.py）：**
- 无 keyring 时：纯文本 JSON + 文件权限 0600
- `_obfuscate` / `_deobfuscate` 是 **XOR 混淆，不是加密**，仅用于非敏感数据（如会话 token）
- API Key 等敏感凭据**不应使用** obfuscate

---

## 阶段二：核心引擎 — Agent Loop

### 整体架构

**文件结构（engine/ 目录，共 1779 行）：**

| 文件 | 行数 | 职责 |
|------|------|------|
| `query_engine.py` | 306 | `QueryEngine` 类，管理会话历史 + 调用 run_query |
| `query.py` | 1057 | `run_query()` 核心 Agent Loop + `_execute_tool_call()` |
| `messages.py` | 222 | `ConversationMessage` 消息模型（TextBlock/ToolResultBlock 等） |
| `cost_tracker.py` | 24 | Token 成本追踪 |
| `stream_events.py` | 90 | 流式事件类型定义 |

### Agent Loop 核心流程（query.py run_query, 633-884 行）

```
while turn_count < max_turns:
    │
    ├─ 1. Auto-compact 检查（token 超阈值则压缩）
    │     ├─ 轻量 microcompact（清空旧 tool result 内容）
    │     └─ 重度 full compact（LLM 摘要旧消息）
    │
    ├─ 2. 图片预处理（非视觉模型转 ImageBlock → 文本）
    │
    ├─ 3. 流式调用模型 api_client.stream_message()
    │     ├─ ApiTextDeltaEvent  → 逐字流式输出
    │     ├─ ApiRetryEvent      → 指数退避重试
    │     └─ ApiMessageCompleteEvent → 收到完整回复
    │     └─ 异常处理：token 超限降配 / 上下文过长 reactive compact / 网络错误
    │
    ├─ 4. 追加 assistant 消息到 history
    │
    ├─ 5. 判断是否有 tool_uses
    │     │
    │     ├─ 无 → STOP，退出循环
    │     │
    │     └─ 有 → 执行工具
    │         ├─ 单个 tool：顺序执行，实时 emit 事件
    │         └─ 多个 tool：asyncio.gather 并发执行
    │
    └─ 6. 将 tool_results 包装为 user 消息追加到 history，继续下一轮
```

**关键设计点：**
- **单次/多次工具调用的不同策略**：单个顺序（实时反馈），多个并发（性能优先）
- **容错**：`asyncio.gather(return_exceptions=True)` 保证一个工具失败不影响其他兄弟工具
- **Anthropic API 约束**：每个 tool_use 必须有对应 tool_result，否则下一轮请求被拒绝
- **max_turns**：默认 8 轮（每轮 = 一次模型调用 + 工具执行），防止无限循环
- **reactive compact**：API 报 prompt 过长时，强制压缩后重试

### 5 种 Provider Workflow

通过 `api/registry.py` 注册，`api_format` 字段决定协议格式：

| backend_type | 含义 | 代表 Provider |
|-------------|------|--------------|
| `anthropic` | Anthropic SDK 协议 | Anthropic, Claude Subscription |
| `openai_compat` | OpenAI 兼容 REST API | OpenAI, DashScope, OpenRouter, Moonshot 等 |
| `copilot` | GitHub Copilot OAuth | GitHub Copilot |
| `openai_codex` | OpenAI Codex 订阅 | Codex CLI |
| `openai` | 原生 OpenAI SDK | OpenAI (gpt-4o 等) |

**自动检测逻辑**：根据 `model` 名称关键词 + `api_key` 前缀 + `base_url` 关键词自动推断 Provider（registry.py 中按优先级匹配）。

### 成本追踪（cost_tracker.py）
- `CostTracker` 累加每次调用的 `UsageSnapshot`（input_tokens / output_tokens / total）
- 通过 `QueryEngine.total_usage` 属性暴露给 UI

---

## 阶段三：工具系统 — 43+ Tools
