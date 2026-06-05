# 架构 -- 知识库 Electron 应用

## 系统概览

Knowledge Base 是一个使用 TypeScript 和 React 构建的 Electron 桌面应用。它提供文档导入、带分块的文本索引，以及带引用的有依据问答。

## 分层图

```text
+-----------------------------------------------------------+
|                     Renderer (React)                       |
|  App.tsx -> DocumentList, DocumentDetail, QuestionPanel,  |
|             StatusBar, ImportPanel                         |
+-----------------------------------------------------------+
         |  window.knowledgeBase.*（类型化 IPC bridge）
+-----------------------------------------------------------+
|                     Preload Script                         |
|  contextBridge.exposeInMainWorld -> documents, indexing, qa|
+-----------------------------------------------------------+
         |  ipcRenderer.invoke(IPC_CHANNELS.*)
+-----------------------------------------------------------+
|                     Main Process                           |
|  main.ts -> createWindow(), initializeServices()          |
|  ipc-handlers.ts -> registerIpcHandlers()                  |
+-----------------------------------------------------------+
         |  Service method calls
+-----------------------------------------------------------+
|                     Services Layer                         |
|  DocumentService | IndexingService | QaService             |
|  PersistenceService（文件系统 I/O）                         |
+-----------------------------------------------------------+
```

## Electron 分层

### 主进程（`src/main/`）

主进程是管理应用生命周期的 Node.js 进程。职责包括：

- **窗口管理**：创建 `BrowserWindow`，并使用安全的 web preferences（`contextIsolation: true`、`nodeIntegration: false`）。
- **IPC 注册**：通过 `registerIpcHandlers()` 将 IPC channel 名称映射到 service 方法。
- **Service 初始化**：通过依赖注入构造 `PersistenceService`、`DocumentService`、`IndexingService` 和 `QaService`。

**关键不变量**：主进程绝不导入 React 或 renderer 代码。

### Preload（`src/preload/`）

preload 脚本会在页面脚本加载前运行在 renderer 上下文中。它使用 Electron 的 `contextBridge` 暴露一个受限的、类型化的 API：

```typescript
window.knowledgeBase = {
  documents: { list, import, get, delete },
  indexing:   { start, status, chunks },
  qa:         { ask, history },
}
```

**关键不变量**：preload bridge 是 renderer 和 main 之间唯一的通信通道。renderer 不能访问任何 Node.js 模块。

### Renderer（`src/renderer/`）

renderer 是由 Vite 打包的 React 18 应用。组件包括：

- `App.tsx`：包含 header、sidebar、main panel 和 status bar 的根布局。
- `DocumentList`：展示已导入文档的 sidebar 列表。
- `DocumentDetail`：展示文档元数据、chunk 和索引控制。
- `ImportPanel`：用于导入 `.txt` 和 `.md` 文档的文件输入。
- `QuestionPanel`：用于提问的文本输入。
- `StatusBar`：显示索引状态和文档数量。

**关键不变量**：renderer 代码绝不导入 `fs`、`path`、`electron` 或任何 Node.js 模块。

### Services（`src/services/`）

在主进程中运行的业务逻辑 class：

- `PersistenceService`：底层 JSON / 文本文件 I/O，使用原子写入。
- `DocumentService`：文档 CRUD 操作（导入、列表、获取、更新、删除）。
- `IndexingService`：段落感知分块（每个 chunk 约 500 字符）和索引管理。
- `QaService`：基于关键词检索和引用生成的模拟问答。

**关键不变量**：services 可以导入共享类型，但绝不导入 renderer 代码。

## 数据流

1. 用户与 React 组件交互，例如点击「Ask」。
2. 组件调用 `window.knowledgeBase.qa.ask(question)`。
3. Preload bridge 调用 `ipcRenderer.invoke('qa:ask', question)`。
4. 主进程 IPC handler 转发给 `QaService.ask()`。
5. `QaService` 检索 chunk，按关键词重叠打分，并生成回答。
6. 响应通过 IPC 返回 renderer。
7. React 组件更新 state 并重新渲染。

## 构建流水线

1. `tsc -p tsconfig.node.json` 将 main、preload、shared 和 services 编译到 `dist/`。
2. `vite build` 将 renderer React 应用打包到 `dist/renderer/`。
3. Electron 加载 `dist/main/main.js` 作为入口。

## 数据存储

所有用户数据都存储在 `app.getPath('userData')/knowledge-base-data/` 下：

```text
knowledge-base-data/
  documents-meta.json     # 文档元数据数组
  content/
    <doc-id>.txt          # 每个文档提取出的文本内容
  chunks/
    <doc-id>.json         # 每个文档的 chunk 数组
  index/
    index-meta.json       # 文档 ID 到 chunk ID 的映射
  qa-history.json         # 问答交互日志
```
