# Contributing

Thanks for improving `stack-aware-unit-testing-skill`.

## Principles

- Keep the main [SKILL.md](SKILL.md) concise and high signal.
- Prefer progressive disclosure: move detailed guidance into focused files under `references/`.
- Add scripts only when deterministic behavior or repeated logic justifies them.
- Preserve the skill boundary: this repo is for repository inspection, unit-test routing, fallback authoring guidance, and reporting discipline.

## Local Workflow

1. Make the change.
2. Update docs, evals, and fixtures if behavior changed.
3. Run:

```powershell
./scripts/validate-skill.ps1
```

4. If you add or change fixture behavior, run `scripts/detect-test-context.ps1` directly against the affected fixtures and inspect the output.
5. Update [CHANGELOG.md](CHANGELOG.md) and [VERSION](VERSION) for user-visible releases.

## Contribution Guidelines

- Do not add framework-specific deep playbooks that belong in dedicated skills.
- Do not expand the skill into E2E, browser, or API contract testing.
- Keep examples and fixtures minimal but realistic.
- Prefer explicit guardrails over vague advice.
- If you introduce new repository metadata, make sure it stays consistent across `README.md`, `agents/openai.yaml`, `VERSION`, and `CHANGELOG.md`.
