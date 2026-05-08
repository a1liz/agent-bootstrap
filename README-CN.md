# Agent Project Bootstrap

## 这个仓库是什么

这个仓库是一个面向新 agent 项目的 bootstrap 源仓库。它沉淀了可复用的工程规则、起步模板和最小自动化能力，适用于由长时间运行的 coding agent 持续开发、并且需要统一运行时结构、上下文管理方式、评估纪律、工具接入边界和交付节奏的项目。

## 它产出什么

这个仓库主要提供三类内容：

- 大多数 agent 项目都应该采用的 `core` 基线规则
- 面向更重或更专门工作流的可选 `modules`
- 用于生成新项目初始骨架的模板和脚本

## 采用方式

推荐的采用方式是 `scaffold + selective modules + reference docs`。

- 先把 `core` 模板复制到新项目里，并由该项目自己维护。
- 仅在项目确实需要时再启用可选模块。
- 更广义的原理说明、经验总结和参考材料保留在本仓库中，而不是整套复制到每个项目里。

默认不建议把这个仓库作为 `submodule` 直接挂到每个新项目中。

## 仓库结构

- `docs/`：规则、采用方式说明和参考文档
- `templates/`：会被复制进新项目的模板文件
- `scripts/`：bootstrap 脚本和校验脚本
- `checklists/`：项目采用和模块选择清单
- `examples/`：基于模板生成的示例项目形态

## Core / Modules / Reference 的区别

- `core`：大多数 agent 项目在初始化时都应采用的基线规则和文件
- `modules`：按需启用的可选能力，用于更重的工作流或特定场景
- `reference`：原理说明、反模式和迁移说明，保留在 bootstrap 仓库中，不必进入每个项目

## 如何开始

建议先阅读 [docs/overview.md](/data/home/liz/agent-bootstrap/docs/overview.md) 和 [docs/adoption-model.md](/data/home/liz/agent-bootstrap/docs/adoption-model.md)。

使用 `scripts/bootstrap_new_project.sh` 可以基于 `templates/core` 生成一个最小项目骨架；如果项目需要额外能力，优先考虑 `--with-eval-harness`、`--with-multi-run`、`--with-tmux` 这几个主模块。`browser-adapter` 仍然保留，但更适合作为特定场景下的 specialized module。

当你修改模板或模块覆盖范围时，可以运行 `scripts/validate_template_integrity.sh` 来检查 bootstrap 仓库自身是否仍然完整一致。
