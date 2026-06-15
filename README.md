# android-speaker

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/android-speaker` is an Android application or sample. A speaking Android App

This legacy Android sample turns typed text into spoken audio using Android's
platform `TextToSpeech` engine.

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `master` branch. The project language mix found during review was: Java (2), shell (1).

## Repository Contents

- `README.md` - project overview and local usage notes
- `build.gradle` - Android or Gradle build configuration
- `app` - source or example code
- `docs` - source or example code
- `gradle` - source or example code
- `gradlew` - Android or Gradle build configuration
- `scripts` - source or example code
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: app, docs, gradle, scripts
- Dependency and build manifests: build.gradle, gradlew
- Entry points or build surfaces: Gradle build files
- Test-looking files: app/src/androidTest/java/garethpaul/com/androidspeaker/ApplicationTest.java

## Getting Started

### Prerequisites

- Git
- Android Studio or a compatible Android SDK
- Java 8 and the checked-in Gradle wrapper

### Setup

The generated wrapper still executes Gradle 2.2.1 for compatibility. It uses
`distributionSha256Sum` to authenticate the downloaded distribution, while the
SDK-free baseline verifies the checked-in wrapper JAR and launchers. This does
not make an uncached build offline-reproducible; the first build still needs
Gradle's HTTPS distribution service.

```bash
git clone https://github.com/garethpaul/android-speaker.git
cd android-speaker
make check
scripts/check-baseline.sh
./gradlew lint --no-daemon
./gradlew test --no-daemon
./gradlew assembleDebug --no-daemon
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

- Use Android Studio to open the project or run `./gradlew assembleDebug` when the Android SDK is configured.

## Testing and Verification

- `make lint` - runs the SDK-free baseline and Gradle lint when the Android SDK is configured.
- `make test` - runs Gradle tests when the Android SDK is configured.
- `make build` - runs debug assembly when the Android SDK is configured.
- `make manifest` - assembles and validates the merged debug manifest when the Android SDK is configured.
- `make check` - runs the aggregate lint, test, build, and merged-manifest gates.
- `scripts/check-baseline.sh` - runs SDK-free source baseline checks.
- GitHub Actions installs Android API 22 and build-tools 24.0.3 under Java 8,
  then runs the complete `make check` gate on pushes, pull requests, and manual
  dispatches. The workflow uses Ubuntu 24.04 and cancels superseded runs.
- Local Gradle checks accept `ANDROID_HOME` or `ANDROID_SDK_ROOT`.
- The SDK-free baseline protects input normalization, platform engine
  initialization, utterance failure handling, lifecycle cleanup, privacy, and
  resource hygiene.
- `./gradlew lint --no-daemon`, `./gradlew test --no-daemon`, and `./gradlew assembleDebug --no-daemon` when the Android SDK is configured.

Use [`DEVICE_VERIFICATION.md`](DEVICE_VERIFICATION.md) for the exact-commit
Android speaker matrix. It covers engine readiness, input boundaries, utterance
ownership, completion, lifecycle cleanup, engine and audio-route changes,
privacy-safe evidence, and explicit unexecuted rows.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.
- This legacy Android baseline pins Android build-tools 24.0.3 and Android Gradle Plugin 1.1.0.
- Speech input is trimmed, must be non-empty, and is capped at 200 characters
  in both the layout and dispatch path.
- Startup checks that the required speech controls are available before wiring
  playback actions.

## Security and Privacy Notes

- Review changes touching network requests, sockets, or service endpoints; examples from the scan include app/src/androidTest/java/garethpaul/com/androidspeaker/ApplicationTest.java, app/src/main/AndroidManifest.xml, app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java, app/src/main/res/layout/activity_main.xml, and 3 more.
- Review changes touching mobile permissions or privacy-sensitive device data; examples from the scan include app/src/main/AndroidManifest.xml, docs/plans/2026-06-08-speaker-lint-resource-baseline.md, docs/plans/2026-06-08-speaker-privacy-build-baseline.md, gradlew, and 1 more.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include app/lint.xml, app/src/main/AndroidManifest.xml, app/src/main/res/values/colors.xml, app/src/main/res/values-v21/styles.xml, and 3 more.
- Review changes touching database, model, or persistence code; examples from the scan include docs/plans/2026-06-08-speaker-privacy-build-baseline.md.
- Auto Backup disabled is part of the privacy baseline because the app has no
  documented restore behavior for user-entered speech text or generated
  playback state.
- The app uses the device's configured platform `TextToSpeech` engine and does
  not request the `INTERNET` permission. Engine-specific privacy behavior is
  controlled by the device and selected engine rather than a hard-coded app
  endpoint.

## Maintenance Notes

- The legacy instrumentation bootstrap creates the application and verifies its
  package identity; TextToSpeech and device behavior remain outside that
  assertion.
- This looks like a legacy Android project or sample. Expect Android SDK, Gradle, and support-library versions to matter.
- The current baseline avoids logging user-entered text and delegates speech to
  the platform `TextToSpeech` engine instead of an undocumented remote URL.
- The play control remains disabled until the engine and US English voice are
  available. Stale utterance callbacks are ignored.
- The activity stops active speech when the activity pauses and shuts down the
  engine when the activity is destroyed.
- Failed speech-engine initialization releases the engine immediately while
  leaving playback disabled and the activity responsive.
- TextToSpeech listener registration failure uses the same immediate engine
  cleanup path before playback can be marked ready.
- Utterance ownership transitions are synchronized across UI and engine
  callback threads, and playback errors are revalidated on the UI thread before
  notifying the user.
- Pure JVM tests cover utterance replacement, stale callbacks, and lifecycle abandonment.
- See `docs/plans/2026-06-13-speaker-listener-registration-guard.md` for the
  listener setup ordering and completed verification evidence.
- It also uses HTTPS Maven Central for build resolution. `app/lint.xml`
  suppresses the obsolete lint API database error, the missing-density-folder
  warning for the bitmap asset intentionally kept in `drawable-nodpi`, and the
  deliberately deferred target-SDK modernization warning. All other lint
  warnings fail the build.
- The merged-manifest gate verifies package and SDK identity, backup opt-out,
  launcher wiring, and absence of the `INTERNET` permission in the built app.
- Future work should add platform speech tests, modernize SDK levels, and verify
  runtime behavior on an emulator or device with multiple installed engines.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `docs/plans/2026-06-09-speaker-playback-completion-cleanup.md` for the
  playback completion cleanup contract.
- See `docs/plans/2026-06-09-speaker-speech-length-bound.md` for the speech
  input length contract.
- See `docs/plans/2026-06-09-speaker-make-gate-targets.md` for the root lint,
  test, and build gate contract.
- See `docs/plans/2026-06-09-speaker-startup-control-guard.md` for the
  required control startup guard.
- See `docs/plans/2026-06-09-speaker-stale-player-callback-guard.md` for the
  stale MediaPlayer callback guard.
- See `docs/plans/2026-06-09-speaker-pause-release.md` for the pause-time
  playback release contract.
- See `docs/plans/2026-06-10-ci-baseline.md` for the GitHub Actions baseline.
- See `docs/plans/2026-06-10-platform-text-to-speech.md` for the supported
  platform speech migration.
- See `docs/plans/2026-06-14-android-speaker-device-verification-checklist.md`
  for the device evidence matrix and runtime non-claims.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
