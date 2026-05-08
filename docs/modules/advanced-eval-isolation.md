# Advanced Eval Isolation

## When To Use This

Use stricter isolation when the project has heavy evaluation loops, mutable build state, concurrent runs, interactive subprocesses, or external tools that are known to rewrite files as part of execution.

## Per-Run Workspaces

- materialize a per-run workspace copy for builds and generated files
- keep generated modules and mutable configs inside that run-local workspace
- share only read-only inputs when the underlying tools are safe

## Lock Scope

- use the smallest meaningful lock scope
- avoid repo-wide locks unless no narrower isolation boundary is possible
- document what resource is protected by each lock

## Child Process Cleanup

- ensure interrupts propagate to child processes
- clean descendant processes on `SIGINT` and `SIGTERM`
- treat leaked subprocesses as correctness bugs

## Build And Run Logs

- persist build stdout and stderr to files
- persist run stdout and stderr to files
- log the artifact path whenever a build or run failure occurs
- if interactive observation is enabled, keep file logs as the canonical debug surface
