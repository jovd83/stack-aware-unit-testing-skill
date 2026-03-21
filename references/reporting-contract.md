# Reporting Contract

Use this reference when summarizing a testing task, especially when you found defects, architectural friction, or incomplete coverage.

## Delivery Summary Template

```text
Context
- Ecosystem and framework:
- Why this path was chosen:
- Existing conventions reused:

Implementation
- Files changed:
- Behavior covered:
- Notable test design choices:

Verification
- Commands run:
- Result:

Findings
- Defects exposed:
- Testability risks:
- Remaining gaps:
```

## Defect Entry Format

Use this format for each meaningful issue:

```text
Defect
- File:
- Location:
- Behavior:
- Impact:
- Evidence:
- Status: exposed by failing test / documented only
```

## Review Mode

If the user asks for a review, findings come first.

Order findings by severity and include:
- file reference
- concrete behavior risk
- why it matters
- whether a missing or weak test contributed to the risk

Keep the change summary secondary.

## Verification Language

Be explicit:
- `Tests passed`
- `Tests failed as expected to expose a defect`
- `Tests were not run`
- `Could not run tests because ...`

Do not leave verification implied.
