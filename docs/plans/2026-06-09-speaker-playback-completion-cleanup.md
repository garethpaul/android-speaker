---
title: Speaker Playback Completion Cleanup
type: reliability
status: completed
date: 2026-06-09
---

# Speaker Playback Completion Cleanup

## Problem Frame

The speaker sample releases `MediaPlayer` instances on failure, before a new
playback starts, and when the activity is destroyed. A successful remote
playback can still leave the active player allocated after audio completion
until a later user action or lifecycle event.

## Scope Boundaries

- Preserve the remote TTS endpoint, input normalization, URL encoding, and
  asynchronous preparation behavior.
- Do not migrate to platform `TextToSpeech` or change UI behavior in this pass.
- Keep verification SDK-free.

## Implementation Units

### U1: Release Completed Playback

Files:

- Modify `app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java`

Approach:

- Add an `OnCompletionListener` to the prepared `MediaPlayer`.
- Release the completed player and clear the active `player` reference only
  when the completed player is still the active instance.

### U2: Extend Static Baseline Checks

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Assert that async media playback uses an `OnCompletionListener`.
- Assert that completion handling clears the active player reference.

### U3: Document The Contract

Files:

- Modify `README.md`
- Modify `CHANGES.md`
- Modify `VISION.md`

Approach:

- Record that playback completion cleanup is part of the current media
  lifecycle baseline.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
