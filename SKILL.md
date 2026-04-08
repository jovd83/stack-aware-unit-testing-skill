---
name: stack-aware-unit-testing-skill
description: Stack-aware unit and component test planning, authoring, and review for existing repositories. Use when Codex needs to inspect a codebase, detect the current test framework, decide whether to reuse or introduce a unit-test stack, design coverage for functions, classes, or modules, write isolated tests without silently changing production code, or report unit-test gaps, defects, and testability risks.
metadata:
  author: jovd83
  version: "1.0.0"
  dispatcher-category: testing
  dispatcher-capabilities: unit-testing, component-testing, test-stack-detection, unit-test-review
  dispatcher-accepted-intents: plan_unit_test_work, implement_unit_tests, review_unit_test_coverage
  dispatcher-input-artifacts: repo_context, target_code, requirements, existing_test_suite, defect_report
  dispatcher-output-artifacts: unit_test_plan, unit_tests, coverage_findings, testability_report, routing_request
  dispatcher-stack-tags: unit-testing, component-testing, framework-detection
  dispatcher-risk: medium
  dispatcher-writes-files: true
---

# Stack-Aware Unit Testing Skill

Use this skill as the default entrypoint for unit and component testing work when no more specific test skill has already been selected.

## Responsibilities

- Inspect the repository before proposing a test approach.
- Reuse existing test frameworks, directory layout, naming, and helper patterns when they already exist.
- Choose a minimal, idiomatic default only when the repository is greenfield for tests and no specialized skill is available.
- Author isolated, behavior-focused tests with clear setup, action, and assertions.
- Surface defects, testability risks, and coverage gaps without silently rewriting production code.

## Boundaries

- Do not replace an established test framework just because another one is newer or preferred.
- Do not silently refactor production code to make tests easier unless the user explicitly asks for code changes beyond tests.
- Do not broaden unit-test work into integration, browser, or end-to-end automation unless the user asks for that scope.
- Do not add new dependencies casually. If a new test dependency is required, keep it minimal and state the reason.
- Do not claim coverage quality from line coverage alone. Prefer behavior, branches, edge cases, and failure modes.

## Dispatcher Integration

Use `skill-dispatcher` as the primary integration layer when this skill needs to hand off to a stack-specific testing skill.

- Inspect the repository first, then dispatch by intent and detected stack instead of hardcoding sibling skill names.
- Prefer the repository's existing unit-test framework over introducing a new one.
- Treat named framework skills as examples and compatibility fallbacks, not as the primary routing contract.
- Keep shared memory limited to stable cross-project policy supplied externally, never task-local test notes.

## Fast Start

1. Run `scripts/detect-test-context.ps1 -Root . -Format json`.
2. Read the target code, nearby tests, and the repository's existing conventions.
3. Decide which path applies:
   - Existing framework and conventions found: follow them.
   - No framework found, but a specialized skill exists for the stack: route to that skill.
   - No framework skill available: continue with this skill using the fallback references.
4. Make the execution plan explicit before writing tests when the task is substantial.
5. Deliver both the test changes and a concise report of findings, commands, and residual risks.

## Routing Rules

### 1. Reuse before introducing

If the repository already has unit or component tests, you must stay within that test stack unless the user explicitly asks for migration.

### 2. Prefer specialized skills when they fit exactly

If the detected stack maps cleanly to a dedicated skill that is available in the environment, use `skill-dispatcher` to pivot to it after inspection.

Examples:
- Java plus JUnit 5: prefer `junit5-skill`
- Playwright, Cypress, or REST/API suites: route to their dedicated skills instead of stretching this one

### 3. Keep the fallback path disciplined

If no dedicated skill is available, use this skill's references for framework selection, authoring, and reporting:
- [references/analysis-workflow.md](references/analysis-workflow.md)
- [references/framework-selection.md](references/framework-selection.md)
- [references/test-authoring-playbook.md](references/test-authoring-playbook.md)
- [references/reporting-contract.md](references/reporting-contract.md)

## Required Output Contract

For substantive testing tasks, structure the response around these sections in this order:

1. `Context`
   - ecosystem, framework decision, and why
   - whether existing tests or conventions were reused
2. `Test Plan`
   - target behavior
   - key happy paths, edge cases, and failure modes
   - important seams or mocks
3. `Implementation`
   - files changed
   - noteworthy test design choices
4. `Verification`
   - commands run
   - whether tests passed, failed, or were not run
5. `Findings`
   - defects, testability issues, or meaningful residual risks

For smaller tasks, compress the same information into a shorter prose response, but do not skip the framework decision or verification status.

## Guardrails For Common Situations

### Existing tests are present

- Match naming, folder structure, fixtures, assertion style, and helper usage.
- Avoid introducing a second assertion library or test runner unless the user asks for migration.

### No tests are present

- Use [references/framework-selection.md](references/framework-selection.md).
- Favor the ecosystem default with the fewest new moving parts.
- State the assumption when introducing a new framework or dependency.

### The code is hard to test

- Try seams that preserve production behavior first: constructor injection already present, local stubs, test doubles, or deterministic clocks and IDs.
- If the architecture is still too coupled, document the limitation precisely instead of hiding it.
- Prefer a failing test or explicit report over speculative refactors.

### A defect is discovered while writing tests

- Expose it with a focused failing test when practical.
- Leave production code untouched unless the user explicitly expands the scope.
- Report the impact and exact location using [references/reporting-contract.md](references/reporting-contract.md).

## Gotchas

- **Environment & Shell**: The provided scripts (e.g., `detect-test-context.ps1`) are **PowerShell**. You must use `pwsh` on Linux or macOS environments.
- **Implicit Production Changes**: Changing a method from `private` to `public` or adding a new `export` just to enable testing **is a production code change**. Always call this out as a "testability tradeoff" rather than doing it silently.
- **`devDependencies` vs `dependencies`**: When a task requires adding a new framework, ensure it is strictly added as a development dependency (e.g., `npm install --save-dev` or `pip install --dev`) to avoid bloating the production artifact.
- **Leaky Mocks**: Mocking global objects (like `console`, `Date`, or `process.env`) can cause test flakiness if the mocks aren't reset. Always prefer framework-native mocking utilities that handle cleanup automatically.
- **CI/Local Divergence**: Tests may pass locally but fail in CI due to missing environment variables or filesystem permissions. Before declaring "Verification" successful, check for any `setup.sh`, `.env.example`, or CI YAML files that define the test environment.
- **Detection Ambiguity**: In monorepos with mixed languages (e.g., a Python backend and Node frontend), `detect-test-context.ps1` might return multiple frameworks. Always verify you are looking at the manifest (`package.json`, `pyproject.toml`) closest to the target file.
- **The Reality Trap (Rubber-Stamping)**: When generating tests for existing code, do not assume the current output is correct. Always cross-reference the logic with the problem description or requirements. A test that "passes" against a bug is itself a defect.
- **Hallucinated Infrastructure**: AI might invent test helpers, assertions (e.g., `expect(f).toExist()`), or runner flags that don't exist in your specific version of Jest/Pytest/Mocha. Always verify the API against the actual installed version or official documentation.
- **Integration Drift**: Without strict mocking of I/O, unit tests can accidentally become slow integration tests. If a test hits a database, network, or filesystem, it violates the isolation principle and should be flagged as a "testability risk" or moved to a separate suite.

## Memory Model

This skill does not maintain its own persistent memory layer.

- Treat repository inspection notes and test plans as runtime memory for the current task.
- Store durable, project-specific conventions in repository files, not hidden memory.
- If cross-agent memory is needed for broader reuse, integrate an external shared-memory skill instead of embedding that responsibility here.

## Resource Map

- `scripts/detect-test-context.ps1`: structured repository inspection for ecosystems, frameworks, and test footprints
- `scripts/detect-framework.ps1`: compatibility wrapper for older references
- `scripts/import-testing-policy.ps1`: import a repository- or organization-specific testing policy into this skill's local reference layer
- `scripts/validate-skill.ps1`: run smoke validation for required files, eval assets, and fixture detection
- `references/analysis-workflow.md`: inspection checklist, routing logic, and escalation points
- `references/framework-selection.md`: greenfield defaults and specialized skill handoff guidance
- `references/org-policy-integration.md`: optional organization-specific policy layering guidance
- `references/test-authoring-playbook.md`: authoring heuristics, coverage expectations, and anti-patterns
- `references/reporting-contract.md`: reporting templates for implementation summaries and defect callouts
- `references/evaluation.md`: forward-testing strategy and quality gates for maintaining the skill

## When To Read Extra References

- Read `references/analysis-workflow.md` when the repository layout or stack is unclear.
- Read `references/framework-selection.md` before adding a new test framework or dependency.
- Read `references/org-policy-integration.md` when an organization-specific testing policy, checklist, or standard should override the default heuristics.
- Read `references/test-authoring-playbook.md` when manually authoring tests without a specialized skill.
- Read `references/reporting-contract.md` when the task includes a review, defect report, or testability critique.
- Read `references/evaluation.md` when extending or validating this skill itself.
