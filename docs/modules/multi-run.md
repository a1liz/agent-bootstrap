# Multi-Run

## When To Use This

Use this module when the project routinely compares multiple runs, tracks cohorts, or exports comparison summaries across named runs.

## Run Naming

Each run should have a stable, descriptive name that encodes the scenario or comparison dimension the project cares about.

## Comparison Outputs

Do not mix comparison summaries into raw run logs. Keep exported reports or comparison artifacts in dedicated compare or report directories.

## Review Focus

Projects that adopt multi-run support should document:

- how run names are assigned
- where comparison outputs are written
- what artifacts are considered exported versus disposable
