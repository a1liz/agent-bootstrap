# Core 规则

五条基线规则，每个 bootstrap 项目都应该遵循。

## 1. Runtime Layout

从第一天起就将源代码、运行时状态和导出的实验输出分开。

- 仓库根目录仅保留源代码、配置、测试、文档和版本化资产
- 将实时运行输出放在专用运行时工作空间下，如 `artifacts/runs/<run-name>/`
- 将生成的代码、日志、保存的状态和评估结果保留在运行时工作空间内
- 默认将运行时工作空间视为可丢弃的，除非显式导出

### 推荐布局

```
artifacts/
  runs/
    default/
      phase_state.json
      convergence_state.json
      traces_config.json
      events.jsonl
      generations/
      analysis/
      guidance/
      trace_logs/
      build_logs/
```

## 2. Observability

默认日志应针对在终端观察长时间运行进程的操作员进行优化。

- 优先使用高信号单行日志，而非冗长文本
- 对一级事件使用稳定前缀（RUN, RESUME, PHASE, CHUNK, CONVERGENCE, EVAL, TRACE, BUILD, SIGNAL, CLEANUP）
- 始终打印重要制品的路径
- 同时将关键事件持久化到结构化日志文件 `events.jsonl`

## 3. State And Resume

可恢复的 pipeline 只有在状态文件与实际进度匹配时才可信。

- 在每个完成的 chunk 或等效持久里程碑后保存状态
- 不在恢复路径上重新初始化状态
- 将收敛状态与阶段状态分开保存
- 将保存状态与保存输出之间的不匹配视为 bug

### 最低状态文件

`phase_state.json`, `convergence_state.json`, `traces_config.json`

## 4. Repo Hygiene

Agent-heavy 项目如果不将生成内容和本地内容与版本化内容明确分离，会很快失控。

- 将 `.env.local` 等密钥加入 ignore
- 忽略运行时工作空间、生成的策略、缓存和测试临时目录
- 仅版本化手工维护的源策略和有意的导出制品
- 保持提交边界主题明确且足够小以便审查

### 推荐 Ignore 模式

```
.env.local
.pytest_cache/
__pycache__/
artifacts/runs/
repl/eval_*/
```

## 5. Minimal Isolation

运行时执行不应修改版本化源代码，也不应模糊持久源文件和可丢弃运行输出之间的界限。

- 不将日志、生成的代码、状态文件或评估输出写回版本化源目录
- 将可变运行时路径保留在运行时工作空间内，与具体运行绑定
- 如果工具在执行过程中会修改文件，将其指向运行本地副本
- 仅在可安全重用且无修改的情况下使用共享只读输入
