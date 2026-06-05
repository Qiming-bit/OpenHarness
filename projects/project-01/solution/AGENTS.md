# AGENTS.md -- Project 01：Baseline vs Minimal Harness

## 启动规则

写任何代码前，按顺序完成以下步骤：

1. **完整阅读本文件。** 它定义了本项目的边界和约定。
2. **阅读 `docs/ARCHITECTURE.md`**，理解 Electron 分层结构。
3. **阅读 `docs/PRODUCT.md`**，理解功能需求。
4. **运行 `bash init.sh`**，验证项目可以干净构建。如果失败，先修复构建错误。
5. **阅读 `feature_list.json`**，查看所有功能的当前状态。

## Electron 层边界

本项目有四个严格分层，代码必须遵守这些边界。

### 主进程（`src/main/`）

- 负责 `BrowserWindow` 生命周期和 IPC 注册。
- 可以导入 services，但绝不能导入 renderer 代码。
- 所有文件系统访问都通过 services 在这里发生。

### Preload（`src/preload/`）

- 是 main 和 renderer 之间唯一的桥梁。
- 使用 `contextBridge.exposeInMainWorld` 暴露类型化 API。
- 绝不导入 React 或 renderer 代码。

### Renderer（`src/renderer/`）

- React + TypeScript UI 层。
- 只能通过 `window.knowledgeBase` API 与主进程通信。
- 绝不导入 Node.js 模块（`fs`、`path`、`electron`）。
- 使用 `types.d.ts` 中的类型声明。

### Services（`src/services/`）

- 在主进程中运行的纯 TypeScript 业务逻辑。
- services 可以导入 `src/shared/`，但绝不导入 `src/renderer/`。
- 每个 service 通过构造函数注入 `PersistenceService`。

## 约定

- 启用 TypeScript strict mode。除非用注释解释原因，否则不要使用 `any`。
- 使用 named exports，不使用 default exports。
- IPC channel 名称只在 `src/shared/types.ts` 的 `IPC_CHANNELS` 中定义一次。
- 所有异步操作返回 Promise；renderer 中绝不使用同步 I/O。

## 完成定义

一个功能只有同时满足以下条件，才算「完成」：

1. TypeScript 无错误编译（`npm run check`）。
2. 应用可以启动并显示窗口（`npm run dev`）。
3. 该功能在 `feature_list.json` 中状态为 `"pass"`，并带有证据。
4. 代码遵守上面定义的 Electron 层边界。
5. 正常操作时没有 console error。

## 使用功能列表

`feature_list.json` 是项目进度的唯一真实来源：

- 每个功能都有一个 `status`：`"pass"`、`"fail"`、`"not-started"`。
- 实现功能后，将状态更新为 `"pass"` 并写入证据。
- 如果功能被阻塞，将状态设为 `"fail"` 并写明原因。
- 绝不要从列表中删除功能。
