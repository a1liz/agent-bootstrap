# Runtime Layout

Keep source code, runtime state, and exported experiment outputs separate from the start.

## Rules

- Reserve the repository root for source, configuration, tests, docs, and versioned assets only.
- Put live run outputs under a dedicated runtime workspace such as `artifacts/runs/<run-name>/`.
- Keep generated code, logs, saved state, and evaluation results inside that runtime workspace.
- Treat runtime workspaces as disposable by default unless explicitly exported.

## Recommended Layout

```text
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
      generated_policies/
```

## Repository-Level Layout

Reserve the repository root for source code, tests, docs, configuration, scripts, and versioned assets. Runtime directories should exist to support execution, but the repository root should not become the default landing zone for logs, generated files, or temporary evaluation state.

## Runtime Workspace Layout

The runtime workspace should be the default location for:

- logs
- saved state
- generated modules or prompts
- temporary build outputs
- evaluation results

Each run should have a predictable home such as `artifacts/runs/<run-name>/`.

## Exported vs Disposable Outputs

Treat most runtime outputs as disposable unless they are intentionally promoted into a durable exported artifact set. This keeps cleanup and review boundaries clear.

## Why

- Agents need a predictable place to look for current state.
- Runtime outputs should not pollute the source tree.
- Cleaning, archiving, and comparing runs becomes straightforward.
- Multiple runs can coexist without trampling one another.
