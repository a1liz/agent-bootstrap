# 架构与采纳模型

## 推荐方法

**scaffold + selective modules + reference docs**

- 从此仓库生成本地基线
- 只复制新项目必须拥有和演进的文件
- 仅在运营成本合理时引入可选模块
- 将更广泛的理念和组织指导保留在此仓库中

## 为什么不默认使用 Submodule

- 大多数采纳的文件需要本地编辑
- 项目会以不同速度分叉
- 同一规则在本地和上游同时存在时所有权变得模糊
- 许多文档作为参考有价值，但不应该在每个项目中维护

Submodule 对只读标准镜像仍然合理，但不应该是默认采纳路径。

## Bootstrap 层次

```
agent-bootstrap/
├── templates/core/          ← 基线，每个项目都要
│   ├── README.md.tpl
│   ├── .gitignore
│   ├── docs/BOOTSTRAP_ADOPTION.md
│   ├── docs/OPERATIONS.md
│   ├── schemas/
│   ├── scripts/validate_repo_structure.sh
│   └── artifacts/runs/
├── templates/modules/       ← 可选附加模块
│   ├── tmux/
│   ├── eval-harness/
│   ├── multi-run/
│   ├── browser-adapter/
│   └── docs-dual-format/
└── docs/                    ← 参考材料，通常不复制
    ├── core/
    ├── modules/
    ├── adoption-model.md
    └── overview.md
```

## 什么会被复制

- 最小仓库布局
- 运行时工作空间基线
- .gitignore 基线
- 运维与采纳文档
- 状态与事件 Schema 样例
- 最小验证脚本
- 选定的模块模板

## 什么保持为引用

- 理念与权衡解释
- 反模式与迁移说明
- 项目未采纳的可选模块
- 组织级指导

## 项目级所有权

模板一旦复制，项目就拥有它们。Bootstrap 仓库是新起点的来源，而不是每个项目必须持续跟踪的运行时依赖。
