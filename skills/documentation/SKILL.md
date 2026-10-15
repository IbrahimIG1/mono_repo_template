---
name: documentation
description: Practical documentation workflow for this Flutter platform. Use when adding or changing a package, public contract, architecture decision, feature flow, platform capability, migration step, setup requirement, or known limitation so documentation stays aligned with verified behavior.
---

# Documentation Workflow

## Choose the owner

- Root README: purpose, bootstrap and navigation to detailed docs.
- Package README: public purpose, API entry points, dependencies, setup and limitations.
- ADR: consequential ownership, dependency, contract, migration, or tooling decision.
- Feature documentation: meaningful UI/business/API flow that another developer cannot infer quickly.
- Migration log: baseline, parity, disposition, commands and rollback evidence.

## Content rules

- Document real behavior, not planned behavior presented as complete.
- Mark unverified claims `VERIFY`.
- Use the capability statuses defined in `AGENTS.md`.
- Record commands actually run and exact failures.
- Explain responsibilities and data flow instead of mirroring files.
- Include platform setup and limitations near the capability they affect.
- Update documentation in the same change as a meaningful behavior/public-contract change.
- Do not rewrite documentation for trivial internal edits.

## Verification

- Check links and referenced paths.
- Compare public API/setup text with current code and manifests.
- Confirm examples do not include secrets or obsolete commands.
- State any platform or credential validation that was not performed.
