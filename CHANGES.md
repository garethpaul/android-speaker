# Changes

## 2026-06-10

- Replaced the undocumented remote TTS URL and `MediaPlayer` flow with Android's
  platform `TextToSpeech` engine, then removed the unnecessary network
  permission.
- Disabled playback until engine initialization succeeds, ignored stale
  utterance callbacks, stopped speech on pause, and shut the engine down on
  destroy.
- Serialized utterance ownership across UI and speech-engine callback threads
  and suppressed stale queued playback-error messages.
- Enforced the 200-character limit in the layout, made root checks portable,
  accepted either Android SDK variable, and pinned CI to Ubuntu 24.04 with
  superseded-run cancellation.
- Added a pinned, read-only GitHub Actions check workflow that runs the existing
  `make check` baseline with a bounded timeout and explicit SDK-free execution.
- Added an SDK-free guard requiring the CI workflow and completed CI baseline
  plan to remain checked in.
- Removed the maintainer-specific Android SDK path from the Makefile.

## 2026-06-09

- Routed MediaPlayer security failures through the existing playback failure
  cleanup path.
- Released active speech playback when the activity pauses so remote audio does
  not continue after the UI leaves the foreground.
- Ignored stale `MediaPlayer` prepared, completion, and failure callbacks after
  newer playback requests replace the active player.
- Guarded startup against missing required speech input or play button controls.
- Added root `make lint`, `make test`, and `make build` gates around the
  existing SDK-free and Gradle verification commands.

## 2026-06-08

- Normalized speech input before validation and TTS URL construction so leading
  or trailing spaces are not sent to the remote endpoint.
- Bounded speech input to 200 characters before TTS URL construction and added
  a resource-backed user message for overlong text.
- Moved empty-input and playback-failure Toast messages into string resources.
- Switched remote audio playback to asynchronous `MediaPlayer` preparation and
  added prepared/error listeners.
- Added `make check` as the SDK-free verification wrapper.
- Added a repository changelog and expanded the documented Android verification
  gate to include lint, tests, and debug assembly.
- Cleaned Android lint findings by moving visible UI text into resources,
  adding a hint and input type for the speech text field, and moving the screen
  background into the app theme.
- Moved the speaker bitmap asset to `drawable-nodpi`, removed unused starter
  strings and menu resources, and documented the narrow legacy lint baseline.
- Released the active `MediaPlayer` when asynchronous playback completes.
- Disabled Android Auto Backup and added a source baseline check for the privacy
  setting.
