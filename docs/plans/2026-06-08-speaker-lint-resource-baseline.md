---
title: Speaker Lint Resource Baseline
type: chore
status: completed
date: 2026-06-08
---

# Speaker Lint Resource Baseline

## Summary

Clean the remaining Android lint findings in the legacy speaker sample while
preserving the existing TTS privacy and build baseline.

## Requirements

- R1. Preserve HTTPS TTS URL construction and UTF-8 text encoding.
- R2. Preserve removal of user-text logging, storage permission, and unused
  Commons Lang dependency.
- R3. Move visible UI text into string resources and give the text input a hint
  and input type.
- R4. Keep the bitmap asset in `drawable-nodpi` and document the narrow lint
  suppressions required by the old Android toolchain.
- R5. Verify with the SDK-free source check, Android lint, unit tests, and
  debug assembly.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
