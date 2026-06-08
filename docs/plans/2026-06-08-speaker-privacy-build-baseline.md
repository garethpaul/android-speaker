---
title: Android Speaker Privacy and Build Baseline
type: fix
status: completed
date: 2026-06-08
---

# Android Speaker Privacy and Build Baseline

## Summary

Raise the baseline for the legacy Android Speaker sample by making the app
buildable on the local SDK, reducing privacy-sensitive text handling, removing
unused storage/dependency surface, removing generated IDE metadata, and adding a
source check for future drift.

---

## Problem Frame

The project uses build-tools 22.0.1, whose bundled 32-bit `aapt` fails on this
host while merging resources. The app also logs user-entered text, sends TTS
requests over an inline HTTP URL, requests external storage permission for an
unused download path, keeps an unused Commons Lang dependency alive through dead
code/imports, and tracks generated Android Studio project metadata.

---

## Requirements

- R1. The app must assemble with the local Android SDK while preserving compile SDK 22 and target SDK 22.
- R2. User-entered text must be URL-encoded and must not be logged.
- R3. The TTS request URL must use HTTPS and keep the existing `tl=en&q=` request shape.
- R4. Unused external-storage download code, permission, and dependency surface must be removed.
- R5. Build repositories must use explicit HTTPS Maven Central instead of JCenter.
- R6. Generated `.idea` and `.iml` metadata must not be tracked.
- R7. The repository must include an SDK-free baseline check and README verification commands.

---

## Key Technical Decisions

- **Pin build-tools 24.0.3:** The installed 24.0.3 tools provide a 64-bit `aapt`
  that works on this host while keeping the legacy Gradle plugin and SDK levels.
- **Extract URL construction:** A `buildTextToSpeechUrl` helper makes encoding
  and endpoint behavior explicit enough to guard with a source check.
- **Remove dead storage path:** The unused download task and path were the only
  reason for `WRITE_EXTERNAL_STORAGE`; removing them narrows permission scope.
- **Use Maven Central directly:** The Android Gradle Plugin is available from
  Maven Central, so JCenter is unnecessary for this baseline.
- **Keep playback flow stable:** Button click still prepares and starts a
  `MediaPlayer` from the remote TTS URL.
- **Ignore generated IDE files:** Android Studio workspace/module files are
  local development output and should not be part of the source baseline.

---

## Scope Boundaries

- This pass does not replace remote TTS with Android platform `TextToSpeech`.
- This pass does not modernize Gradle, Android Gradle Plugin, compile SDK, target SDK, or repository dependencies beyond removing unused Commons Lang.
- This pass does not add emulator, device, or audio playback assertions.
- This pass does not redesign the UI or change app package names/resources.

---

## Implementation Units

### U1. Stabilize Legacy Build

- **Goal:** Make debug assembly work on the local SDK.
- **Files:** `app/build.gradle`, `README.md`
- **Patterns:** Preserve Gradle wrapper 2.2.1, Android Gradle Plugin 1.1.0, compile SDK 22, target SDK 22, use HTTPS Maven Central, and pin build-tools 24.0.3.
- **Test Scenarios:**
  - `./gradlew tasks --no-daemon` succeeds with `ANDROID_HOME=/home/gjones/android-sdk`.
  - `./gradlew assembleDebug --no-daemon` succeeds with `ANDROID_HOME=/home/gjones/android-sdk`.
  - `build.gradle` no longer contains `jcenter()`.
- **Verification:** Gradle commands and `scripts/check-baseline.sh`

### U2. Reduce Text and Storage Risk

- **Goal:** Keep the text-to-speech flow while avoiding avoidable privacy and permission surface.
- **Files:** `app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java`, `app/src/main/AndroidManifest.xml`, `app/build.gradle`
- **Patterns:** Use HTTPS endpoint constant, URL-encode user text, remove user-text logging, release `MediaPlayer`, remove unused download/storage code.
- **Test Scenarios:**
  - Source check fails if raw user text logging returns.
  - Source check fails if `WRITE_EXTERNAL_STORAGE` returns.
  - Compile fails if removed dependencies/imports are still needed.
- **Verification:** `scripts/check-baseline.sh`, `./gradlew assembleDebug --no-daemon`, `./gradlew test --no-daemon`

### U3. Document and Guard Baseline

- **Goal:** Give maintainers a repeatable, low-friction maintenance gate.
- **Files:** `README.md`, `scripts/check-baseline.sh`, `.gitignore`
- **Patterns:** Short toolchain, verification, and modernization notes; POSIX shell checks for source/build drift.
- **Test Scenarios:**
  - README documents build-tools 24.0.3 and verification commands.
  - Script checks endpoint, URL encoding, dependency, permission, generated metadata, and build-tools expectations.
- **Verification:** `scripts/check-baseline.sh`

---

## Risks & Dependencies

- Runtime playback still depends on a remote Google Translate TTS URL and is not verified here on an emulator or device.
- The app still performs network media preparation on the UI thread; changing that should be a separate behavior-aware pass.
- Gradle and Android plugin versions remain obsolete to avoid combining build migration with app behavior changes.

---

## Sources / Research

- `app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java` contains the typed-text playback flow.
- `app/src/main/AndroidManifest.xml` requests app permissions.
- `app/build.gradle` pins compile SDK 22, target SDK 22, and build-tools 22.0.1.
- `gradle/wrapper/gradle-wrapper.properties` pins Gradle 2.2.1.
- Local `assembleDebug` failed because build-tools 22.0.1 `aapt` cannot load `libz.so.1` on this host.
