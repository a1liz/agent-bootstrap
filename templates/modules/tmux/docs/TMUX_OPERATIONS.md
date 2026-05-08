# Tmux Operations

## When To Use Tmux

Use tmux when a run is long-lived enough that operators need to detach and reattach without losing terminal visibility.

## Session Naming

Use a stable session name that includes the project or run name, for example `project-run-name`.

## Logs

Tmux is an observation layer, not the canonical log surface. Persist logs to files under the runtime workspace even when tmux is enabled.
