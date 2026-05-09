# 可选模块

按需启用的附加模块。从 Core 开始，根据实际工作流需求添加模块。

## 推荐启用顺序

1. eval-harness — 显式评估结构和可重复评估循环
2. multi-run — 多运行管理和比较
3. tmux — 运维友好的长时间运行和监控
4. browser-adapter — 浏览器/工具集成支持
5. docs-dual-format — 双格式文档体系（md + HTML）

## 主要模块

### eval-harness

为项目提供显式的评估目录结构和可重复的回归路径。

包含：`docs/EVALS.md`, `evals/`

何时启用：项目需要专用评估目录和可重复回归路径时。

### multi-run

支持项目比较多次运行、跟踪运行组或导出跨命名运行的比较摘要。

包含：`docs/MULTI_RUN.md`, `reports/`

何时启用：项目需要比较多轮运行或维护命名运行组时。

### tmux

为需要分离/重连同时保持终端可见性的长时间运行操作员提供 tmux 支持。

包含：`docs/TMUX_OPERATIONS.md`, `scripts/launch_in_tmux.sh`

何时启用：项目需要分离式长时间终端观察时。

## 专用模块

### browser-adapter

集成浏览器自动化或浏览器支持工具。浏览器制品应落在活动运行时工作空间下。

包含：`docs/BROWSER_ADAPTER.md`, `artifacts/browser/`

仅当项目明确需要时启用。

### docs-dual-format

为项目建立双格式文档体系：`docs/md/`（Markdown 源码）+ `docs/html/`（HTML 多页展示），内容完全对等，共享暗色主题 CSS + 统一导航。

包含：`docs/md/`（OVERVIEW, ARCHITECTURE, CORE, MODULES, USAGE），`docs/html/`（index, architecture, core, modules, usage + style.css）

## 参考模块（仅文档）

以下模块有参考文档但尚未有独立模板，其指导已融入 Core：

- **advanced-eval-isolation** — 更严格的隔离：每运行工作空间副本、锁范围、子进程清理
- **context-and-working-agreements** — 持久项目上下文、运行时会话上下文、交接笔记、决策记录
- **tool-integration-contracts** — 工具形状、操作员可见性、超时与重试策略、故障暴露要求
- **delivery-rhythm-and-evals** — 阶段分离、最低评估期望、回归检查、里程碑标准
