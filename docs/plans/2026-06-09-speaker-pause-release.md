---
title: Speaker Pause Playback Release
type: reliability
status: completed
date: 2026-06-09
---

# Speaker Pause Playback Release

## Problem Frame

The speaker sample released its active `MediaPlayer` on failure, completion,
new playback, and activity destruction. If the activity paused without being
destroyed, remote speech playback could continue after the UI left the
foreground.

## Scope Boundaries

- Preserve the existing remote TTS endpoint and asynchronous playback flow.
- Keep release behavior centralized through `releasePlayer()`.
- Do not migrate to platform `TextToSpeech` or change the UI in this pass.
- Keep verification available through the SDK-free baseline script.

## Implementation Units

### U1: Release Playback On Pause

Files:

- Modify `app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java`

Approach:

- Add `onPause()`.
- Release the active player through the existing idempotent helper.
- Preserve the Android lifecycle callback by calling `super.onPause()`.

### U2: Cover And Document The Contract

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Add SDK-free checks for the pause lifecycle hook.
- Document pause-time playback release in project notes.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
