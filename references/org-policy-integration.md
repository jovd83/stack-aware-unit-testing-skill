# Organization Policy Integration

Use this reference when a team or company has its own testing policy that should refine the default behavior of this skill.

## Goal

Allow local policy to tighten or specialize the skill without forking the core guidance unnecessarily.

## Recommended Layering

Apply policy in this order:

1. Repository facts from code and manifests
2. This skill's default guardrails and references
3. Local policy overrides from `references/local-testing-policy.md` if present

Local policy should refine decisions such as:
- mandatory assertion or naming conventions
- forbidden dependencies
- minimum defect-report fields
- approved mocking libraries
- required coverage gates or review checkpoints

## How To Import A Local Policy

Run:

```powershell
./scripts/import-testing-policy.ps1 -Source C:\path\to\testing-policy.md
```

This creates or updates `references/local-testing-policy.md`.

## Authoring Rules For Local Policy

Keep the local policy:
- explicit
- auditable
- scoped to unit and component testing concerns
- stable enough to justify persistence

Do not use local policy files as a dumping ground for temporary task notes or cross-agent memory.

## Conflict Resolution

If local policy conflicts with repository reality:
- prefer correctness over blind policy application
- call out the mismatch explicitly
- avoid silently forcing the repository into non-working conventions
