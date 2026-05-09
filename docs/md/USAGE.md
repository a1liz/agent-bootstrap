# 使用指南

## 1. Bootstrap 新项目

```bash
# 最小项目
scripts/bootstrap_new_project.sh /path/to/my-agent-project

# 带常用可选模块
scripts/bootstrap_new_project.sh /path/to/my-agent-project \
  --with-eval-harness \
  --with-multi-run \
  --with-tmux

# 全部可用模块
scripts/bootstrap_new_project.sh /path/to/my-agent-project \
  --with-eval-harness \
  --with-multi-run \
  --with-tmux \
  --with-browser-adapter \
  --with-docs-dual-format
```

## 2. 更新已有项目

```bash
# Bootstrap 项目 — 模块合并到根目录
scripts/update_existing_project.sh /path/to/existing-project --with-docs-dual-format

# 非 Bootstrap 项目 — 模块隔离在 .bootstrap/ 下
scripts/update_existing_project.sh /path/to/any-repo --with-docs-dual-format
```

已启用的模块自动跳过，支持 `--dry-run` 预览。

## 3. 验证完整性

```bash
scripts/validate_template_integrity.sh
```

## 4. 查看文档

### 启动文档服务

```bash
cd agent-bootstrap
python3 -m http.server 8080 -d docs/html/
```

### SSH 隧道（远程服务器）

在本地机器执行：

```bash
ssh -L 8080:127.0.0.1:8080 -N user@<服务器地址>
```

浏览器打开 `http://localhost:8080` 即可。
