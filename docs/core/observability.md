# Observability

Default logs should be optimized for an operator watching a long-running process in a terminal.

## Rules

- Prefer high-signal single-line logs over chatty prose.
- Use stable prefixes for first-class events.
- Always print the path to important artifacts instead of forcing the operator to guess.
- Persist the same critical events to a structured log file such as `events.jsonl`.
- Keep third-party library noise suppressed unless verbose mode is enabled.

## Recommended Line Format

```text
PREFIX | key=value key=value ...
```

## Recommended Event Classes

- `RUN` for run context and lifecycle
- `RESUME` for resume state
- `PHASE` for phase boundaries
- `CHUNK` for chunk start and completion
- `CONVERGENCE` for plateau or convergence checks
- `WORKSPACE` for run-local workspace paths
- `EVAL` for policy- or candidate-level evaluation context
- `TRACE` for per-input execution results
- `GEN` for saved result files
- `BUILD` for compile or build failures
- `SIGNAL` for interrupts and shutdown triggers
- `CLEANUP` for teardown actions

## What Must Be Visible

- active runtime workspace path
- current phase or step
- candidate or policy name under evaluation
- raw stdout or stderr log path for failures
- result file path for saved generations
- tmux or external session name when interactive observation is enabled

## Structured Log Guidance

- Append JSON objects to `events.jsonl`
- include a timestamp
- include the same event prefix used in terminal logs
- normalize path values to strings

This combination gives you both terminal scanability and machine-readable history.

## Minimum Terminal Signals

Operators should be able to identify the active run, current phase, current candidate or unit of work, and the location of any important logs or saved outputs without searching the tree manually.

## Minimum Structured Event Fields

At minimum, structured events should carry:

- timestamp
- event prefix
- short message
- run name
- relevant path when an artifact or log file is involved

## Failure Triage Entry Points

When execution fails, the first log line should help the operator jump to the relevant run directory and any associated stdout, stderr, or saved result files.
