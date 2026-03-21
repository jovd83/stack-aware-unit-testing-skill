# Stack-Aware Unit Testing Skill

`stack-aware-unit-testing-skill` is a stack-aware Agent Skill for inspecting repositories, choosing the right unit-test path, writing isolated tests, and reporting quality risks without silently rewriting production code.

![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)
![Version](https://img.shields.io/badge/version-2.2.0-blue.svg)

## Metadata

```yaml
name: stack-aware-unit-testing-skill
author: jovd
version: 2.2.0
license: MIT
```

It is designed as a high-signal fallback for unit and component testing work:
- Reuse existing frameworks and conventions when they already exist.
- Hand off to a specialized skill when the stack is a strong exact match.
- Stay productive on mixed or underspecified repositories when no dedicated skill is available.

## What This Skill Owns

This repository is responsible for:
- repository inspection for unit-test context
- framework and convention selection for unit/component tests
- fallback cross-language test authoring guidance
- reporting contracts for findings, gaps, and verification

This repository is not responsible for:
- browser automation or end-to-end testing
- API contract testing
- CI pipeline ownership beyond lightweight run guidance
- cross-agent shared memory infrastructure

## Why This Exists

Many testing requests start before the stack is clear:
- "Add unit tests for this service"
- "Figure out how this repo is tested"
- "Write tests without changing production code"
- "Review our unit-test gaps"

This skill gives agents a disciplined default for those requests. It avoids two common failure modes:
- guessing a test framework before inspecting the repo
- overreaching into production refactors when the user asked for tests

## Repository Layout

```text
stack-aware-unit-testing-skill/
|- SKILL.md
|- CHANGELOG.md
|- CONTRIBUTING.md
|- LICENSE
|- README.md
|- RELEASE_CHECKLIST.md
|- VERSION
|- assets/
|  `- policies/
|     `- testing-policy-template.md
|- agents/
|  `- openai.yaml
|- evals/
|  |- evals.json
|  `- fixtures/
|     |- dotnet-mstest/
|     |- dotnet-nunit/
|     |- dotnet-xunit/
|     |- go-greenfield/
|     |- java-junit/
|     |- node-jest/
|     |- ruby-rspec/
|     |- rust-cargo/
|     `- python-greenfield/
|- references/
|  |- analysis-workflow.md
|  |- evaluation.md
|  |- framework-selection.md
|  |- org-policy-integration.md
|  |- reporting-contract.md
|  `- test-authoring-playbook.md
`- scripts/
   |- detect-framework.ps1
   |- detect-test-context.ps1
   |- import-testing-policy.ps1
   `- validate-skill.ps1
```

## Install

Place the folder where your agent can discover skills, typically under `~/.codex/skills/` or your tool's configured skills directory.

Example:

```powershell
Copy-Item -Recurse . $HOME\.codex\skills\stack-aware-unit-testing-skill
```

## Use

Example prompts:
- `Use $stack-aware-unit-testing-skill to inspect this repository and recommend the right unit-test approach for src/orders/service.ts.`
- `Use $stack-aware-unit-testing-skill to add isolated tests for this Python module without changing production code.`
- `Use $stack-aware-unit-testing-skill to review our existing unit-test gaps and call out defects the tests expose.`

## Operating Model

1. Inspect the repository first with `scripts/detect-test-context.ps1`.
2. Reuse existing framework and local conventions whenever possible.
3. Hand off to a dedicated skill when the stack has a better exact-match skill.
4. Otherwise, use the fallback references to plan, author, and report the work.

## Memory Boundaries

This skill intentionally keeps memory simple:
- Runtime memory: the current repository inspection, test plan, and task notes.
- Project-local persistence: repository files such as tests, reports, or docs when the task calls for them.
- Shared memory: out of scope for this skill. If durable cross-agent reuse is needed, integrate an external shared-memory skill instead of embedding that behavior here.

## Tooling

### `scripts/detect-test-context.ps1`

This script upgrades the original repository scan into an agent-friendly utility:
- accepts a target root path
- detects common ecosystems and test frameworks
- looks for existing test files and test directories
- emits either human-readable text or structured JSON
- returns a stable recommendation that the skill can reason over

Compatibility note:
- `scripts/detect-framework.ps1` is kept as a wrapper so older prompts and docs do not break.

## Evaluation

Evaluation assets live under `evals/`:
- `evals/evals.json` contains lightweight prompt-based smoke evaluations
- `evals/fixtures/` contains tiny repository fixtures for routing and inspection checks across JavaScript, Python, Java, Go, .NET, Rust, and Ruby
- `references/evaluation.md` defines the review rubric and forward-testing expectations
- `scripts/validate-skill.ps1` provides a no-surprises local validation entrypoint

These evals are intentionally small. They are meant to catch regressions in routing, framework choice, and reporting discipline without turning the skill into a large framework of its own.

## Organization Policy Overrides

If your team has a house testing standard, import it without forking the skill:

```powershell
./scripts/import-testing-policy.ps1 -Source C:\path\to\testing-policy.md
```

That creates `references/local-testing-policy.md`, which the skill treats as a scoped local override on top of repository facts and the default guidance.

## Extending The Skill

Additional capabilities included in this revision:
- broader fixture coverage for Go, .NET, Rust, and Ruby
- a validation wrapper for required files, JSON assets, optional `skills-ref`, and fixture smoke scans
- an importer workflow for organization-specific testing policies

Intentionally out of scope today:
- autonomous self-modification
- embedded shared-memory infrastructure
- large framework-specific playbooks that belong in dedicated skills
