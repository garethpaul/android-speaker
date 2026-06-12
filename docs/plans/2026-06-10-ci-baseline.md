# Android Speaker CI Baseline

## Status: Completed

## Context

`android-speaker` has source contracts plus guarded Gradle and merged-manifest
gates behind `make check`. The canonical workflow now installs the compatible
legacy Android toolchain so speech lifecycle, text handling, built privacy,
lint, tests, and assembly are checked before review.

## Objectives

- Run the complete `make check` wrapper in GitHub Actions.
- Install Android API 22 and build-tools 24.0.3 under Java 8.
- Verify the merged debug manifest through a structured parser.
- Make the workflow and complete hosted gate part of the source baseline.

## Work Completed

- Added `.github/workflows/check.yml` to run `make check` on pushes, pull
  requests, and manual dispatches.
- Pinned checkout and Java setup to immutable revisions, limited permissions to
  repository reads, disabled persisted checkout credentials, and bounded the
  job to 15 minutes.
- Installed the exact API 22 and build-tools 24.0.3 packages before running the
  guarded Makefile targets.
- Made lint warnings fatal while retaining only documented legacy suppressions.
- Selected deterministic non-queued PNG crunching without skipping aapt
  validation.
- Added unit-tested structured validation of package, SDK, backup, launcher,
  and no-INTERNET contracts in the merged debug manifest.
- Extended `scripts/check-baseline.sh` to require one exact canonical workflow
  instead of bypassable substring checks.
- Added CODEOWNERS coverage for the workflow, verification entry points, and
  the complete Android app tree, including alternate source sets.
- Extended privacy checks across every app source-set manifest and Java or
  Kotlin source file so debug or flavor additions cannot bypass the baseline.
- Rejected numeric-entity permission obfuscation, direct network client APIs,
  unaudited dependency declarations, and local JAR or AAR additions.
- Locked the fixed legacy Gradle configuration and module inventory so source
  sets, dependencies, or external build scripts cannot redirect around scans.
- Updated README, VISION, SECURITY, and CHANGES with the CI baseline.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`

## Follow-Up Candidates

- Exercise platform speech behavior on devices with multiple installed engines.
- Modernize the legacy Gradle, Android plugin, and target SDK in a separate
  behavior-aware follow-up.
