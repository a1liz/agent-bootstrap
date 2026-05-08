# Tmux Operations

## When To Use Tmux

Use tmux when the project runs long enough that operators need to detach and reattach while preserving terminal visibility.

## Session Naming

Use stable, descriptive session names that include the project or run name. Operators should be able to identify the active session without opening it first.

## Logging Expectations

Tmux should remain an observation layer. Persist the canonical logs under the runtime workspace even when a run is launched inside tmux.

## Operational Notes

Projects that adopt tmux should document:

- how sessions are named
- how to attach and detach
- where logs are written
- how to correlate a tmux session with a specific run directory
