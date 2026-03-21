# Changelog

All notable changes to `stack-aware-unit-testing-skill` are documented in this file.

## [2.2.0] - 2026-03-21

### Added
- `.gitignore` for local policy overrides, editor noise, and validation artifacts.
- `RELEASE_CHECKLIST.md` for publish-time consistency checks.
- Additional .NET fixture repositories for MSTest and NUnit.
- A policy-override evaluation fixture and prompt coverage.
- README badges for license and current version.

### Changed
- Expanded validation to require the new maintenance files.
- Increased fixture smoke coverage from 7 to 10 repositories.

## [2.1.0] - 2026-03-21

### Added
- MIT license and contributor-facing repository documentation.
- Explicit repository metadata with `author: jovd` and `version: 2.1.0`.
- Validation wrapper `scripts/validate-skill.ps1`.
- Optional policy import workflow via `scripts/import-testing-policy.ps1`.
- Additional fixture repositories for Go, .NET, Rust, and Ruby.
- Organization-policy integration guidance in `references/org-policy-integration.md`.

### Changed
- Renamed the skill and repository identity from `unit-testing-skill` to `stack-aware-unit-testing-skill`.
- Updated prompts, install instructions, agent metadata, and evals to use the new skill name.
- Expanded the README into a fuller GitHub-ready open-source package guide.

## [2.0.0] - 2026-03-21

### Added
- Rebuilt the main skill contract around inspection-first routing, explicit guardrails, and a structured output contract.
- Added focused references for analysis, framework selection, authoring, reporting, and evaluation.
- Replaced the brittle detector with a structured repository inspection script and compatibility wrapper.
- Added lightweight eval prompts and repository fixtures.
- Added `agents/openai.yaml` metadata for installability.

## [1.0.0] - Initial prototype

### Notes
- Original Gemini-generated skill pack with thin analysis, core, and reporting subskills.
