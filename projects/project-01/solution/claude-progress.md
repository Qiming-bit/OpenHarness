# claude-progress.md -- 会话日志

## Project 01：Baseline vs Minimal Harness

### Session 1 -- 2026-03-30

**耗时**：约 45 分钟  
**目标**：建立带有合适 harness 的 baseline Electron 应用

**已完成**：

- 验证 Electron 窗口以 1200x800 启动，并使用正确的 `webPreferences`
- 确认文档列表面板渲染空状态提示
- 确认问答面板可以接收输入，并通过 IPC 提交
- 验证 `PersistenceService` 会在 `userData` 下创建数据目录
- 将 `feature_list.json` 中 4 个功能全部更新为 `"pass"`
- 编写 `AGENTS.md`，说明启动规则和层边界
- 编写 `docs/ARCHITECTURE.md`，说明 Electron 分层结构
- 编写 `docs/PRODUCT.md`，说明知识库需求

**决策**：

- 使用构造函数注入 `PersistenceService`，保持 services 可测试
- 将所有 IPC channel 名称集中放在 `types.ts` 的一个常量对象中
- 窗口标题统一设为 `"Knowledge Base"`

**问题**：无

**下一次会话**：进入 Project 02，添加导入、详情视图和持久化功能。
