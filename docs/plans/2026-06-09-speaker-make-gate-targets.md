---
title: Speaker Make Gate Targets
type: tooling
status: completed
date: 2026-06-09
---

# Speaker Make Gate Targets

## Problem Frame

The README documented Gradle lint, test, and debug build commands, but the root
Makefile only exposed `make check`. The repository needed the standard gate
names so pre-push verification can run consistently from the project root.

## Scope Boundaries

- Preserve the existing SDK-free baseline script.
- Preserve the checked-in Gradle project and Android build-tools baseline.
- Do not change speech playback, network, or media behavior in this tooling
  pass.
- Skip Gradle-backed gates clearly when the Android SDK is not configured.

## Implementation Units

### U1: Add Root Gate Targets

Files:

- Modify `Makefile`

Approach:

- Add `make lint` to run the SDK-free baseline and Gradle lint when available.
- Add `make test` to run Gradle tests when the Android SDK is configured.
- Add `make build` to run the debug assembly when the Android SDK is
  configured.
- Keep `make check` as the aggregate wrapper through `make verify`.

### U2: Protect The Contract

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Require `lint`, `test`, and `build` targets in the root Makefile.
- Require `verify` to aggregate the gate targets.

### U3: Document The Gate

Files:

- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Record the root gate names next to the existing Gradle verification notes.

## Verification

- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- `git diff --check`
