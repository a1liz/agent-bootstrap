# Tool Integration Contracts

## Supported Tool Shapes

This bootstrap assumes projects may integrate with tools exposed through CLI commands, MCP servers, browser automation, evaluators, compilers, or sandboxed subprocesses.

## Required Operator Visibility

Operators should be able to tell:

- what tool is being invoked
- what run or candidate triggered it
- where stdout and stderr are written
- what output path or artifact the tool produced

## Timeout And Retry Policy

Projects should define tool-level timeout and retry behavior explicitly. Silent indefinite waits and implicit retries make debugging and resume behavior harder to trust.

## Output Location Rules

Tool outputs should land in run-local paths unless they are intentionally exported artifacts. Mutable tool state should not leak into versioned source directories by default.

## Failure Surface Requirements

Tool failures should surface the failing command or operation class, the log location, and the output path involved. Operators should not have to infer where to look next.
