# Delivery Rhythm And Evals

## Phases

Projects should separate early prototyping, stabilized iteration, and release-oriented hardening. The bootstrap does not enforce one exact process, but it should make those phases visible.

## Minimum Eval Expectations

Every project should define at least one repeatable evaluation path before claiming a behavior improvement. The expected eval depth can grow with maturity, but there should always be a baseline check that is cheap enough to run repeatedly.

## Regression Checks

When a project changes runtime structure, state handling, or tool orchestration, it should include checks that cover the affected path. Resume behavior and failure visibility are especially important to keep under regression watch.

## Milestone Criteria

A milestone should be based on demonstrated behavior, not only implemented code. The project should be able to show what was evaluated, what artifacts were produced, and what operator workflow remains supported.
