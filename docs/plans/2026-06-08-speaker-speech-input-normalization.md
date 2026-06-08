# Speaker Speech Input Normalization

## Goal

Normalize user-entered speech text before validation and URL construction, and
keep playback-facing Toast messages in Android string resources.

## Red

- Extended `scripts/check-baseline.sh` to require a `normalizeSpeechText`
  helper, to require the normalized value in `buildTextToSpeechUrl`, and to
  reject hard-coded Toast text in `MainActivity`.
- Confirmed the baseline failed with `Normalized typed text must be URL-encoded
  with UTF-8.`

## Green

- Added `normalizeSpeechText` to handle null and trim whitespace.
- Validated and played the normalized text value.
- Added `speech_input_required` and `speech_playback_failed` string resources
  for Toast messages.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
- `git diff --check`
