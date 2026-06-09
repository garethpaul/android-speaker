# Speaker Media Security Exception Guard

Date: 2026-06-09
Status: Completed

## Problem

The speaker sample already routes `MediaPlayer` data-source, preparation, and
startup failures through a centralized playback failure handler, but
`MediaPlayer.setDataSource(...)` can also throw `SecurityException`. That path
could crash instead of releasing the active player and showing the existing
resource-backed playback failure message.

## Scope

- Preserve the existing remote TTS endpoint, input validation, and async
  playback flow.
- Reuse the existing playback failure cleanup behavior.
- Do not migrate to platform `TextToSpeech` or change UI copy.
- Keep verification available through the SDK-free baseline check.

## Work Completed

- Added a `SecurityException` catch around media startup.
- Routed security failures through `handlePlaybackFailure(...)`.
- Extended the SDK-free baseline to keep the guard in place.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
