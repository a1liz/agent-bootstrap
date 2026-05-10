# Agent Project Bootstrap

这个仓库的作用，是帮你快速起一个“适合 agent 持续开发”的项目骨架，不用每次都从头设计目录结构、运行时落盘位置、操作文档和评估约束。

如果你现在最想知道的是“这仓库到底怎么用”，最短路径其实只有三步：

1. 用 `scripts/bootstrap_new_project.sh` 生成一个新项目。
2. 只按需启用可选模块。
3. 生成后的文件由新项目自己维护，不要默认把这里当成长期联动的子模块。

## 什么时候该用这个仓库

当你的项目有下面这些特征时，这个 bootstrap 会比较合适：

- agent 运行时间长，或者需要断点恢复
- 会产生运行日志、状态文件、评估产物等运行时数据
- 有迭代式 eval 流程
- 需要编排子进程
- 需要让操作者方便地观察运行状态，尤其是 tmux 场景

如果你要的是业务代码、应用框架脚手架，或者某个具体技术栈的 feature starter，这个仓库并不负责。它只提供工程结构。

## 仓库里主要有什么

- `templates/core/`：每个新项目都会复制进去的基线模板
- `templates/modules/`：按需叠加的可选模块
- `scripts/bootstrap_new_project.sh`：生成新项目的主脚本
- `scripts/validate_template_integrity.sh`：校验模板和文档覆盖面是否还一致
- `docs/`：采用方式和参考资料
- `examples/minimal-agent-project/`：一个最小生成结果的形态示例

## 快速开始

生成一个最小项目：

```bash
scripts/bootstrap_new_project.sh /path/to/my-agent-project
```

生成一个带常用模块的项目：

```bash
scripts/bootstrap_new_project.sh /path/to/my-agent-project \
  --with-eval-harness \
  --with-multi-run \
  --with-tmux
```

这个脚本会做下面几件事：

- 把 `templates/core/` 复制到目标目录
- 按顺序叠加你选择的模块模板
- 创建 `src/` 和 `tests/`
- 把 `README.md.tpl` 实化成 `README.md`
- 在 `docs/BOOTSTRAP_ADOPTION.md` 里记录 bootstrap 来源和版本

注意：目标目录必须事先不存在。

## 模块该怎么选

建议先从 `core` 开始，只有在项目真的需要时再加模块：

- `--with-eval-harness`：需要明确 eval 结构和可重复评估流程时启用
- `--with-multi-run`：需要同时管理多次运行或多组运行时启用
- `--with-tmux`：需要长期运行、方便操作者观察和接管时启用
- `--with-browser-adapter`：更专门的浏览器或工具接入场景

如果你现在拿不准，推荐顺序是：

1. `core`
2. `eval-harness`
3. `multi-run`
4. `tmux`
5. `browser-adapter` 只在确实有需求时再加

## 一个典型的使用流程

1. 先看 [docs/overview.md](/data/home/liz/agent-bootstrap/docs/overview.md)，理解这个 bootstrap 想统一什么。
2. 运行 `scripts/bootstrap_new_project.sh` 生成项目。
3. 打开生成后的 `README.md`、`docs/BOOTSTRAP_ADOPTION.md`、`docs/OPERATIONS.md`。
4. 对照 [checklists/new-project-checklist.md](/data/home/liz/agent-bootstrap/checklists/new-project-checklist.md) 检查基线是否完整。
5. 后续就在新项目里继续演进这些复制过去的文件，而不是反向依赖这个仓库。

## 接下来该看什么

- [docs/overview.md](/data/home/liz/agent-bootstrap/docs/overview.md)：整体目标和适用范围
- [docs/adoption-model.md](/data/home/liz/agent-bootstrap/docs/adoption-model.md)：推荐采用方式
- [examples/minimal-agent-project/README.md](/data/home/liz/agent-bootstrap/examples/minimal-agent-project/README.md)：最小生成项目的外形
- [checklists/new-project-checklist.md](/data/home/liz/agent-bootstrap/checklists/new-project-checklist.md)：生成后自检清单

## 查看项目文档

使用内置的 docserver 可以在单端口上 serve 多个项目的文档，并提供 Web 管理界面：

```bash
# 将当前仓库注册为项目
python3 tools/docserver/docserver.py add --name agent-bootstrap --dir docs/html/

# 或者自动发现当前目录
python3 tools/docserver/docserver.py serve

# 其他命令
python3 tools/docserver/docserver.py list
python3 tools/docserver/docserver.py add --dir <path> --name <name>
python3 tools/docserver/docserver.py remove --name <name>
```

然后从本地机器建立 SSH 隧道：

```bash
ssh -L 8080:127.0.0.1:8080 -N user@<服务器地址>
```

在浏览器中打开 `http://localhost:8080` 即可进入项目管理界面。Markdown 源码（内容等价）在 `docs/md/` 下。

## 对维护这个仓库的人

如果你修改了模板、模块覆盖范围，或者文档里提到的文件面，记得运行：

```bash
scripts/validate_template_integrity.sh
```
