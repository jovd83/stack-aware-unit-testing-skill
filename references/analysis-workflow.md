# Analysis Workflow

Use this reference when the repository context is unclear or when the user asks for strategy before implementation.

## Goal

Produce a grounded answer to three questions before writing tests:
- What ecosystem and test framework does this repository already use?
- What is the smallest correct path for this request?
- What behaviors, seams, and risks matter most for the target code?

## Inspection Checklist

1. Run `scripts/detect-test-context.ps1 -Root . -Format json`.
2. Read the target production file and its nearest neighbors.
3. Read adjacent tests, fixtures, helpers, or test configuration if they exist.
4. Check the package or build manifest for the test stack and helper libraries.
5. Identify whether the request is truly unit/component scope or whether it is drifting into integration, browser, or contract testing.
6. If `references/local-testing-policy.md` exists, apply it as a scoped override after repository facts are known.

## Decision Tree

### Existing tests present

- Follow the existing runner, assertion style, and file placement.
- Reuse local factories, fixtures, and helper utilities before inventing new ones.
- Only add new helper patterns if they clearly reduce repetition and match the repo style.

### No tests present

- Confirm the ecosystem from manifests and code shape.
- Use [framework-selection.md](framework-selection.md) to choose a minimal default.
- Keep the assumption explicit when adding the first test dependency.

### Dedicated skill available

Route to the more specialized skill when it is a better exact match than this fallback skill.

Examples:
- JUnit 5 work: `junit5-skill`
- Playwright or Cypress work: their dedicated skills
- API test automation: dedicated API testing skills

### Scope mismatch detected

If the user asks for unit tests but the only reliable way to verify behavior is through an integration seam, say so clearly. Do not hide the mismatch by writing brittle pseudo-unit tests.

## What To Extract From Target Code

- public behavior and expected outputs
- branches and guard clauses
- error handling and exceptional states
- state transitions and side effects
- dependencies that should stay real versus mocked

## Escalation Triggers

Pause and make the tradeoff explicit when:
- introducing a new framework or dependency will modify build files
- the code is highly coupled and testability is poor
- the requested scope implies production refactors, not just tests
- the user asks for a review and the main value is findings rather than code changes

## Recommended Analysis Summary

Keep the analysis concise but structured:

```text
Context
- Ecosystem: ...
- Existing framework: ...
- Decision: reuse / hand off / fallback

Target
- Files under test: ...
- Behavior to cover: ...

Risks
- Tight coupling, missing seams, flaky time or IO dependencies, unclear expected behavior
```
