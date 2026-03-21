# Release Checklist

Use this checklist before publishing a new version of `stack-aware-unit-testing-skill`.

## Versioning

- Update [VERSION](VERSION)
- Add a release entry to [CHANGELOG.md](CHANGELOG.md)
- Confirm the README metadata block matches the current version

## Skill Consistency

- Confirm [SKILL.md](SKILL.md) frontmatter still uses `stack-aware-unit-testing-skill`
- Confirm [agents/openai.yaml](agents/openai.yaml) still references the current skill name and prompt
- Confirm examples in [README.md](README.md) use the current skill invocation

## Validation

- Run `./scripts/validate-skill.ps1`
- If `skills-ref` is installed, confirm external validation passes
- Smoke-check any newly added fixture folders with `scripts/detect-test-context.ps1`

## Documentation

- Verify README install instructions still match the intended distribution path
- Verify optional features are clearly labeled as optional
- Verify architecture boundaries and non-goals are still accurate

## Packaging

- Confirm [LICENSE](LICENSE) is present and correct
- Confirm [CONTRIBUTING.md](CONTRIBUTING.md) reflects the current workflow
- Confirm `.gitignore` excludes only local or generated artifacts
