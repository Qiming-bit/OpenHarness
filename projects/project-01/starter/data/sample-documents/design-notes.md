# 软件设计笔记

## 架构概览

知识库应用采用分层架构，明确分离各层职责。系统分为四个主要层：主进程、preload 脚本、renderer 层和 services 层。

## 主进程

主进程负责窗口管理、IPC handler 注册和应用生命周期管理。它是 Electron 应用的入口，负责协调操作系统和 renderer 进程。

主要职责：

- 创建和配置 `BrowserWindow`
- 注册 IPC channel
- 初始化 service 并注入依赖
- 处理应用生命周期事件（`ready`、`window-all-closed`、`activate`）

## Preload 层

preload 脚本是主进程和 renderer 进程之间的安全桥梁。它使用 Electron 的 `contextBridge` 向 renderer 暴露类型化 API，同时避免授予完整的 Node.js 访问权限。

暴露的 API 分为三个命名空间：

- `documents`：文档管理的 CRUD 操作
- `indexing`：文档分块和索引管理
- `qa`：带引用的问答

## Renderer 层

renderer 使用 React 和 TypeScript 构建用户界面。组件只能通过 preload bridge API 通信，不能直接访问 Node.js API 或文件系统。

## Services 层

业务逻辑放在主进程中运行的 service class 里：

- `PersistenceService`：文件系统读写操作
- `DocumentService`：文档导入、存储和检索
- `IndexingService`：文本分块和索引构建
- `QaService`：带引用支持的模拟问答

## 数据流

1. 用户在 renderer 中触发操作，并通过 preload bridge 发起 IPC 调用。
2. 主进程中的 IPC handler 将请求转发给对应 service。
3. service 通过 persistence 层执行业务逻辑。
4. 结果通过 IPC 返回 renderer 并展示。
