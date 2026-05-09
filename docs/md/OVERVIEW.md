# Agent Project Bootstrap — 项目总览

## 一句话总结

Agent Project Bootstrap 帮助团队快速启动新 Agent 项目并保持结构一致性。它让运行时状态、可观测性、状态持久化、评估隔离和仓库卫生从第一天起就可预测。

通过 scaffold + selective modules + reference docs 模式，只复制项目真正需要拥有的文件，其余保持为引用。

## 核心指标

| 指标 | 值 |
|------|-----|
| Core 规则 | 5 条基线规则 |
| 主要模块 | eval-harness, multi-run, tmux |
| 专用模块 | browser-adapter, docs-dual-format |
| Scripts | bootstrap_new_project.sh, update_existing_project.sh, validate_template_integrity.sh |

## 目标项目类型

此 bootstrap 针对具有以下一个或多个特征的项目：

- 长时间运行或可恢复的执行
- 运行时制品、日志和状态应保持在源目录之外
- 迭代评估循环
- 子进程编排
- 面向运维的可观测性或 tmux 驱动工作流

## 快速导航

1. [架构与采纳模型](ARCHITECTURE.md) — bootstrap 层次、什么被复制、什么保持为引用
2. [Core 规则](CORE.md) — 五条基线规则
3. [Modules](MODULES.md) — 可选模块详情
4. [使用指南](USAGE.md) — 构建、运行、测试命令
