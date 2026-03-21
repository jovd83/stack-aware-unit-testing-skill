# Evaluation Strategy

Use this reference when validating changes to the skill itself.

## Objectives

Protect these behaviors from regression:
- correct routing based on repository context
- disciplined framework reuse
- sensible fallback framework selection when greenfield
- clear reporting of verification status and findings
- restraint around production-code changes

## Evaluation Layers

### 1. Static review

Check that:
- `SKILL.md` frontmatter only contains `name` and `description`
- the main skill body stays concise and points to focused references
- file references are shallow and intentional
- documentation does not promise behavior that the repository does not implement

### 2. Script smoke tests

Run:

```powershell
./scripts/validate-skill.ps1
./scripts/detect-test-context.ps1 -Root ./evals/fixtures/node-jest -Format json
./scripts/detect-test-context.ps1 -Root ./evals/fixtures/python-greenfield -Format json
./scripts/detect-test-context.ps1 -Root ./evals/fixtures/java-junit -Format text
```

Verify that the script identifies the ecosystem, existing test footprint, and specialized-skill hint correctly. The validation wrapper also smoke-checks all bundled fixtures, including Go, .NET, Rust, and Ruby.

### 3. Prompt-based skill evals

Use `evals/evals.json` to smoke-test routing, authoring guidance, and reporting discipline.

### 4. Forward-testing

When practical, ask a fresh agent to use the skill on one of the fixtures or on a small real repository task.

Do not leak the expected diagnosis. Judge whether the skill still drives the agent toward:
- inspect first
- reuse before replacing
- expose defects instead of silently rewriting production code

## Exit Criteria

Treat the skill revision as healthy when:
- the script returns stable, parseable output on the fixtures
- the prompt evals still reflect the intended routing behavior
- the skill stays concise enough to load efficiently
