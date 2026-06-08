---
title: Issue 1 HTTPS Translate TTS Endpoint
type: fix
status: active
date: 2026-06-08
origin: https://github.com/garethpaul/android-speaker/issues/1
execution: code
---

# Issue 1 HTTPS Translate TTS Endpoint

## Summary

Move the Android speaker app's Google Translate TTS requests off plain HTTP so text-to-speech audio is fetched over HTTPS.

## Problem Frame

Issue #1 was filed from the public repository review because `MainActivity.java` uses `http://translate.google.com/translate_tts` in two runtime request paths. One path casts the opened connection to `HttpsURLConnection`, so the current HTTP URL can also fail at runtime with a bad cast.

## Requirements

- R1. `app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java` must not contain runtime `http://translate.google.com/translate_tts` URLs.
- R2. Both the `MediaPlayer` source path and the download task path must use the same HTTPS Translate TTS endpoint.
- R3. The existing `tl=en` and `q` query behavior in the `MediaPlayer` path must be preserved.
- R4. The change must avoid Gradle, Android plugin, SDK, dependency, or UI migrations.
- R5. The PR must reference `https://github.com/garethpaul/android-speaker/issues/1`.

## Implementation Unit

### U1. HTTPS TTS Endpoint Constant

- **Goal:** Introduce one HTTPS endpoint constant and use it in both Translate TTS call sites.
- **Files:** `app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java`
- **Test Scenarios:** Verify no runtime HTTP Translate TTS URLs remain, both call sites reference the shared constant, and the direct playback URL still appends `?tl=en&q=<encoded text>`.
- **Verification:** `rg -n "http://translate\\.google\\.com/translate_tts|https://translate\\.google\\.com/translate_tts|TRANSLATE_TTS_URL|setDataSource|new URL" app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java` and `git diff --check`.

## Risks

- The repository uses an old Android Gradle plugin and Gradle wrapper. Local build verification may be unavailable if modern JDKs cannot run Gradle 2.2.1.
- This change intentionally leaves the legacy networking structure intact and only fixes the transport scheme and duplicated endpoint literal.
