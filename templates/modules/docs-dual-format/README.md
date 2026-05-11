# Docs Dual Format

为项目建立双格式文档体系：`docs/md/`（Markdown 源码，命令行友好）和 `docs/html/`（HTML 多页展示，浏览器友好），两者信息内容完全对等，共享 CSS + 统一导航。

## 适用场景

- 项目需要同时支持命令行快速查阅（md）和浏览器展示（html）
- 需要多页 HTML 文档，带统一导航和暗色主题样式
- 远程服务器上开发，需要通过 SSH 隧道在本地浏览器查看文档

## 目录结构

```
docs/
├── md/                    # Markdown 源码（命令行友好、版本控制 diff 友好）
│   ├── OVERVIEW.md        # 项目总览（核心，必须）
│   ├── ARCHITECTURE.md    # 架构与模块分工（核心，必须）
│   ├── USAGE.md           # 使用指南（核心，必须）
│   ├── DESIGN_DECISIONS.md # 设计决策（核心，必须）
│   └── ...                # 按需追加的专题页面
└── html/                  # HTML 多页展示（浏览器友好）
    ├── style.css          # 共享样式表（暗色主题、响应式）
    ├── index.html         # 总览页
    ├── architecture.html  # 架构页
    ├── usage.html         # 使用指南
    ├── design-decisions.html # 设计决策页
    └── ...                # 与 md/ 一一对应
```

架构页 (`architecture.html`) 支持**交互式数据流图**：点击 Phase 按钮查看各阶段模块间数据流动的逐步动画，每步配有颜色编码（蓝/紫/金）和进度面板。适用于多仓库/多语言项目的分阶段数据管线展示。实现细节见 `skill.md` 的 "Interactive Architecture Diagram" 节。

## 页面数量

4 个核心页面（OVERVIEW / ARCHITECTURE / USAGE / DESIGN_DECISIONS）是**最低基线**，任何项目都必须有。Agent 分析仓库后，根据实际复杂度自主决定是否追加页面：

- 多个独立子系统或服务 → 各自成页
- 非平凡的 API 契约或数据 schema → 独立成页
- 多套部署环境或复杂配置 → 独立成页
- 贡献指南、测试策略等专项内容 → 独立成页

不设上限，但也禁止无意义拆分或巨型页面。粒度标准：一个页面对应一个可独立向他人解释的主题。

## 工作流程

### 阶段一：Agent 分析仓库 → 填充 `docs/md/`

Agent 在写任何文档之前，必须先从仓库中提取信息：

1. 读取既有信息源（README、CLAUDE.md、AGENTS.md 等）
2. 读取构建清单（package.json、Cargo.toml、Makefile 等）
3. 映射目录树，识别模块职责
4. 从脚本、CI 配置中提取构建/测试/运行命令
5. 从 git log、ADR 文件中提取关键设计决策

产出 `docs/md/` 内容，每份文件必须包含从仓库实际分析得出的具体信息，不允许残留模板占位符。

### 阶段二：MD → HTML 转换

为每个 `docs/md/*.md` 生成对应的 `docs/html/*.html`：
- 复用共享 `<nav>` + `style.css`
- 导航覆盖所有页面，当前页高亮
- `index.html` 的 TOC 与实际页面列表一致

## 约束

1. **内容对等**：md/ 和 html/ 下的文件描述的信息必须一致
2. **导航一致性**：所有 HTML 页面共享同一个 `<nav>`，当前页高亮
3. **共享 CSS**：所有 HTML 页面引用同一个 `style.css`
4. **README 包含服务启动说明**：项目根目录 README 必须包含启动 HTTP 服务的命令和 SSH 隧道说明
5. **禁止占位符**：完成后 `docs/md/` 中不得残留模板占位文本（如"补充…"、"待定义"、"模块 A"）

## 启动文档服务

```bash
cd <project-dir>
python3 -m http.server 8080 -d docs/html/
```

然后在本地机器建立 SSH 隧道：

```bash
ssh -L 8080:127.0.0.1:8080 -N user@<服务器地址>
```

浏览器打开 `http://localhost:8080` 即可。
