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
│   ├── OVERVIEW.md
│   ├── ARCHITECTURE.md
│   ├── USAGE.md
│   └── DESIGN_DECISIONS.md
└── html/                  # HTML 多页展示（浏览器友好）
    ├── style.css          # 共享样式表（暗色主题、响应式）
    ├── index.html         # 总览页
    ├── architecture.html  # 架构页
    ├── usage.html         # 使用指南
    └── design-decisions.html # 设计决策页
```

## 约束

1. **内容对等**：md/ 和 html/ 下的文件描述的信息必须一致
2. **导航一致性**：所有 HTML 页面共享同一个 `<nav>`，当前页高亮
3. **共享 CSS**：所有 HTML 页面引用同一个 `style.css`
4. **README 包含服务启动说明**：项目根目录 README 必须包含启动 HTTP 服务的命令和 SSH 隧道说明

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
