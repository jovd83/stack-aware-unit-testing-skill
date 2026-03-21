# Framework Selection

Use this reference only when the repository does not already signal an established unit-test stack.

## Core Rule

Prefer the smallest, idiomatic, low-friction default for the detected ecosystem. Do not introduce a framework just because it is popular.

## Default Fallbacks

| Ecosystem | Preferred default | Notes |
| --- | --- | --- |
| JavaScript / TypeScript | Vitest for Vite-native repos, Jest otherwise | Match existing tooling and module format before choosing. |
| Java / JVM | JUnit 5 | Prefer `junit5-skill` when available. |
| Python | Pytest | Keep fixtures simple and explicit. |
| Go | Standard `testing` package | Avoid extra layers unless the repo already uses them. |
| .NET | xUnit | Respect MSTest or NUnit if the repo already hints at them. |
| Ruby | RSpec | Prefer established project conventions if present. |
| PHP | PHPUnit | Keep framework-specific helpers local to the repo. |
| Rust | Built-in `cargo test` patterns | Add helper crates only when justified. |

## Dependency Discipline

Before adding any new package:
- confirm that no equivalent test stack already exists
- keep additions minimal and directly tied to the requested work
- mention the dependency explicitly in the final response
- if `references/local-testing-policy.md` exists, make sure the choice does not violate that policy

## Handoff Map

Route away from this skill when a more exact skill exists and matches the work better:
- `junit5-skill` for JUnit 5 authoring, debugging, architecture, CI, and reporting
- `playwright-skill` or `cypress-skill` for browser automation
- API-specific testing skills for contract or service testing

## Anti-Patterns

- Do not introduce both Jest and Vitest in the same greenfield repo.
- Do not add a heavy mocking library when local stubs are enough.
- Do not pick a framework based on personal preference over repository fit.
- Do not infer that E2E tooling is also the right unit-test stack.
