---
title: Speaker Async Playback Baseline
type: fix
status: completed
date: 2026-06-08
---

# Speaker Async Playback Baseline

## Summary

Keep the existing remote TTS playback behavior while avoiding synchronous
`MediaPlayer.prepare()` on the UI thread.

## Requirements

- R1. Preserve the HTTPS TTS endpoint and UTF-8 text encoding.
- R2. Preserve normalized null and whitespace-only speech input handling.
- R3. Use asynchronous media preparation for remote audio streams.
- R4. Start playback only from `OnPreparedListener`.
- R5. Release failed players and clear the active player reference on errors.
- R6. Keep user-facing playback messages in string resources.
- R7. Expose `make check` as the root SDK-free verification command.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
- `git diff --check`
