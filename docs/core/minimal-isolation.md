# Minimal Isolation

## Goal

Agent projects need a baseline level of isolation so runtime execution does not mutate versioned source or blur the boundary between durable source files and disposable run outputs.

## Rules

- Do not write logs, generated code, state files, or evaluation outputs back into versioned source directories.
- Keep mutable runtime paths run-local under the runtime workspace.
- If a tool mutates files as part of execution, point it at a run-local copy or run-local output path.
- Prefer shared read-only inputs only when they are safe to reuse without mutation.

## Required Run-Local Paths

At minimum, these paths should be run-local:

- logs
- saved state
- generated modules or prompts
- evaluation outputs
- temporary build or scratch outputs created by the run

## When Shared Read-Only Inputs Are Acceptable

Shared inputs are acceptable when they remain read-only during execution and the project can rely on them without introducing hidden cross-run coupling. If a tool may rewrite a file, treat that file path as mutable and move it into the run-local workspace first.
