# Test Authoring Playbook

Use this reference when this skill stays on the execution path and manually authors tests.

## Quality Bar

Write tests that explain behavior, not just implementation details.

Aim for:
- clear scenario names
- deterministic setup
- one behavioral concern per test when practical
- assertions that prove the behavior, not just that code ran

## Coverage Priorities

Cover these in roughly this order:

1. Main success paths
2. Guard clauses and invalid inputs
3. Branching behavior
4. Error propagation and failure handling
5. Boundary values and empty states
6. Regression cases for discovered defects

## Arrange, Act, Assert

Keep tests easy to scan:
- Arrange: build the system under test, inputs, and doubles
- Act: perform one meaningful operation
- Assert: verify outputs, state changes, and interactions that matter

Avoid scattering assertions across setup or mixing several Acts in one test unless the local framework idiom strongly favors it.

## Isolation Guidelines

Prefer real collaborators when they are:
- pure value objects
- deterministic helpers
- cheap and side-effect free

Use doubles when collaborators are:
- slow
- nondeterministic
- network or filesystem backed
- time or randomness dependent
- responsible for expensive setup

## What Not To Mock

Avoid mocking:
- trivial data containers
- language primitives
- code you own that is cheap and deterministic unless the seam is the point of the test

Over-mocking creates fragile tests and hides behavior gaps.

## Defect Exposure Rule

If the code appears wrong:
- do not "fix" the production code unless the user explicitly asks for that
- prefer a focused failing test when it can demonstrate the defect cleanly
- otherwise document the issue with file path, behavior, and impact

## High-Value Assertions

Prefer assertions that verify:
- returned values or emitted objects
- state transitions
- visible side effects
- meaningful collaborator interactions
- error types and messages when they are part of the contract

Avoid weak tests that only assert a method was called when the output contract can be asserted directly.

## Common Failure Modes

### Hard-coded time, UUIDs, randomness, or environment access

Inject or wrap them if the seam already exists. Otherwise, document why the code is hard to unit test.

### Static singletons or global state

Reset state carefully if the framework supports it. If not, isolate the limitation in the report.

### Large methods with many branches

Write the highest-value cases first instead of chasing raw line coverage.

### Missing mocking libraries

Use native doubles or lightweight local helpers before adding dependencies.
