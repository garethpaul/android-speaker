# Speaker Stale Player Callback Guard

## Status: Completed

## Context

The speaker sample prepares remote TTS audio asynchronously. A user can start a
new playback request while the previous `MediaPlayer` still has pending
prepared, completion, or error callbacks. Those stale callbacks should not start
old audio, clear the newer active player, or show playback failure UI.

## Objectives

- Preserve asynchronous remote audio preparation and playback.
- Mark the new `MediaPlayer` as active before data-source preparation.
- Ignore prepared callbacks from inactive players.
- Ignore completion and failure callbacks from inactive players.
- Keep active player cleanup and resource release behavior for the current
  request.

## Work Completed

- Added an active-player guard before `onPrepared` starts playback.
- Assigned `player = nextPlayer` before `setDataSource(...)`.
- Updated completion and failure handlers to return for stale players.
- Extended `scripts/check-baseline.sh`.
- Updated README, VISION, and CHANGES.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

## Follow-Up Candidates

- Add media lifecycle tests after the legacy Android stack is modernized.
- Replace the remote TTS stream with Android platform `TextToSpeech` in a
  dedicated behavior change.
