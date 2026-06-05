# CLAUDE.md -- Claude Code 快速参考

## 项目概览

这是一个 Electron + TypeScript + React 知识库应用。代码分为四层：主进程、preload、renderer 和 services。

## 构建和运行

```bash
npm install        # 安装依赖
npm run check      # 只做类型检查，不生成文件
npm run build      # 编译 main/preload，并打包 renderer
npm run dev        # 构建并启动 Electron
```

## 关键文件

| 文件 | 用途 |
|------|------|
| `src/main/main.ts` | Electron 入口、窗口创建、service 接线 |
| `src/main/ipc-handlers.ts` | IPC channel 注册 |
| `src/preload/preload.ts` | contextBridge API 暴露 |
| `src/renderer/App.tsx` | React 根组件 |
| `src/services/*.ts` | 业务逻辑（document、indexing、QA、persistence） |
| `src/shared/types.ts` | 共享类型和 IPC channel 常量 |
| `feature_list.json` | 功能跟踪和 pass/fail 状态 |

## 架构规则

- Renderer 绝不导入 Node.js 模块。
- main 和 renderer 之间的所有通信都通过 IPC。
- Services 通过构造函数注入 `PersistenceService`。
- IPC channel 名称放在 `src/shared/types.ts` 中。

## 如何添加功能

1. 在 `src/shared/types.ts` 中定义 IPC channel。
2. 在 `src/main/ipc-handlers.ts` 中添加 handler。
3. 在 `src/preload/preload.ts` 中暴露 API。
4. 在 `src/renderer/types.d.ts` 中添加类型声明。
5. 在 `src/renderer/components/` 中构建 UI。
6. 用结果更新 `feature_list.json`。

## 测试

```bash
npm test           # 运行 vitest 测试套件
npm run test:watch # 以 watch mode 运行测试
```
