# Operations

## Start A Run

Document the standard command or entrypoint used to start a run.

## Runtime Outputs

Runtime outputs should go under `artifacts/runs/<run-name>/`.

## Logs

Document where terminal logs, structured events, and tool logs are written.

## State

Document where phase state, convergence state, and configuration snapshots are stored.

## Failure Triage

On failure, first inspect the active run directory, then check saved state, terminal or structured logs, and any tool-specific stdout or stderr files.
