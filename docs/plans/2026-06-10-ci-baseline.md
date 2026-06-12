# Android Speaker CI Baseline

## Status: Completed

## Context

`android-speaker` has an SDK-free source baseline plus guarded Gradle lint,
test, and build gates behind `make check`. The repository needs the same
wrapper to run in GitHub Actions so media playback, text handling, and privacy
contracts are checked before review.

## Objectives

- Run the existing `make check` wrapper in GitHub Actions.
- Keep the CI job useful even when a legacy Android SDK is unavailable.
- Make the workflow presence part of the SDK-free baseline contract.

## Work Completed

- Added `.github/workflows/check.yml` to run `make check` on pushes, pull
  requests, and manual dispatches.
- Pinned checkout to an immutable revision, limited permissions to repository
  reads, disabled persisted checkout credentials, and bounded the job to five
  minutes.
- Reused the guarded Makefile targets, which run SDK-free checks and skip Gradle
  work when the Android SDK is absent.
- Removed the maintainer-specific default SDK path and cleared ambient hosted
  SDK variables so CI cannot accidentally invoke the unsupported Gradle path.
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

- Add Android SDK-backed CI after migrating the legacy Gradle, Android plugin,
  repository, API-level, and media playback test baseline.
