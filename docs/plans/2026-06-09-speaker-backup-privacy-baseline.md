---
title: Speaker Backup Privacy Baseline
type: security
status: completed
date: 2026-06-09
---

# Speaker Backup Privacy Baseline

## Problem Frame

Android Speaker accepts user-entered text and sends it to a remote text-to-speech
endpoint. The app does not define or document any local data restore behavior,
but the manifest still allowed Android Auto Backup by default.

## Scope Boundaries

- Preserve the existing typed-text playback behavior, permissions, endpoint, and
  media lifecycle handling.
- Do not introduce a backup rules file or persistence layer in this pass.
- Keep verification SDK-free so privacy drift can be caught without Android
  tooling.

## Implementation Units

### U1: Disable App Backup

Files:

- Modify `app/src/main/AndroidManifest.xml`

Approach:

- Set `android:allowBackup="false"` on the application.
- Keep the existing `INTERNET` permission unchanged because playback still uses
  the remote TTS endpoint.

### U2: Guard The Privacy Contract

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Fail the baseline if Auto Backup is no longer explicitly disabled.
- Fail the baseline if the README stops documenting the backup setting.

### U3: Document The Decision

Files:

- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Record that Auto Backup is disabled because the sample has no documented
  restore behavior for speech text or playback state.
- Keep future restore support as an explicit design decision rather than a
  default manifest behavior.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
