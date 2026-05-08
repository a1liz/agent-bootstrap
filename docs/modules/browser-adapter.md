# Browser Adapter

## When To Use This

Use this module when the project integrates browser automation or browser-backed tools that produce traces, screenshots, transcripts, or other session artifacts.

## Runtime Output Rules

Browser artifacts should land in run-local paths under the active runtime workspace. Avoid mixing browser debug output into versioned source directories.

## Operator Visibility

Operators should be able to tell:

- what browser task ran
- what run triggered it
- where browser outputs were written
- which persisted artifacts to inspect on failure

## Failure Handling

When browser-backed work fails, surface the output directory and any saved debug artifacts immediately so the next debugging step is obvious.
