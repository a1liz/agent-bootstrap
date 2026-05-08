# Context And Working Agreements

## Persistent Project Context

Store durable project context in versioned docs that future agents and operators can find without relying on chat history. This includes architecture notes, operating assumptions, stable interfaces, and project-level conventions.

## Runtime Session Context

Store run-specific context in the runtime workspace. Session summaries, transient run notes, intermediate analysis outputs, and other execution-local artifacts should live with the run that produced them.

## Handoff Notes

Use a small, fixed-format handoff note when work spans sessions or agents. A good handoff records:

- the current objective
- the latest durable state
- the next concrete action
- known risks or mismatches

## Decision Records

Keep durable design decisions short and explicit. Record what changed, why it changed, and what constraint or tradeoff motivated the choice. Long free-form deliberation is less useful than a stable decision surface.

## What Should Not Be Committed

Do not commit transient reasoning fragments, debug scratch notes, or run-local investigation artifacts unless they are intentionally promoted into durable project context.
