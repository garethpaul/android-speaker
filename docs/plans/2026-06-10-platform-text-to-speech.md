# Platform Text-to-Speech Migration

Status: Completed

## Goal

Replace the undocumented remote speech endpoint with Android's supported
platform `TextToSpeech` API so typed text is not sent by the app to a hard-coded
third party.

## Requirements

- Remove the remote Google Translate TTS URL and `MediaPlayer` playback path.
- Remove the `INTERNET` permission because the app no longer performs network
  requests.
- Keep the play control disabled until engine and language initialization
  succeeds.
- Preserve trimmed, non-empty, 200-character-bounded speech input.
- Ignore callbacks from utterances replaced by a newer request.
- Stop active speech on pause and shut the engine down on destroy.
- Keep failures user-visible through string resources without logging speech
  text.
- Enforce the migration in the SDK-free baseline.

## Implementation

- Made `MainActivity` a `TextToSpeech.OnInitListener` and selected US English.
- Added an `UtteranceProgressListener` with monotonic active-utterance
  correlation.
- Used `QUEUE_FLUSH` so a new request replaces previous speech predictably.
- Added initialization and dispatch failure handling.
- Added the input limit to the layout as well as the Java validation path.
- Made `make check` location-independent, accepted either Android SDK variable,
  and hardened the hosted workflow runner and concurrency behavior.

## Verification

- `make check`
- `make -f /absolute/path/to/Makefile check` from outside the repository
- platform-engine, permission, lifecycle, input, Makefile, and CI mutation checks
- `ANDROID_HOME=/path/to/android-sdk make check` (verified with API 22 lint,
  test, and debug assembly)
- `sh -n scripts/check-baseline.sh`
- `git diff --check`

The API-22 build gate passes on this host. Runtime voice output still requires
an emulator or device with a configured speech engine; lint retains the known
legacy `targetSdkVersion 22` modernization warning.
