# Changes

## 2026-06-15

- Added pure JVM utterance ownership tests for replacement speech, stale and
  null callbacks, exact clearing, and lifecycle abandonment.
- Moved the synchronized ownership state machine out of the activity without
  changing TextToSpeech or UI behavior.

## 2026-06-14

- Added an instrumentation bootstrap assertion that creates the application and
  verifies the Android Speaker package identity.
- Added an exact-commit Android Speaker device verification matrix for engine
  readiness, input boundaries, utterance ownership, completion, lifecycle
  cleanup, engine and audio-route changes, and privacy-safe evidence, with every runtime row explicitly unexecuted.

## 2026-06-13

- Guarded TextToSpeech listener registration failure so playback is not marked
  ready without ownership callbacks and the unusable engine is released.

## 2026-06-12

- Regenerated the Gradle wrapper bootstrap with official Gradle 8.14.5 tooling
  while retaining the Gradle 2.2.1 Android runtime.
- Pinned the official distribution checksum and exact wrapper artifact contracts.
- Promoted CI to the complete API 22 lint, unit-test, assembly, and structured
  merged-manifest privacy gate with deterministic legacy resource processing.
- Released the platform text-to-speech engine immediately when engine or
  language initialization fails instead of retaining unusable native resources.

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
- Disabled persisted checkout credentials, added CODEOWNERS for CI and the
  complete Android app tree, and made the SDK-free guard require one exact
  canonical workflow instead of bypassable substring matches.
- Extended privacy checks across alternate Android source sets so debug or
  flavor code cannot restore network permission or remote speech unnoticed.
- Rejected encoded permission names, direct network clients, unaudited
  dependency declarations, and local Android binary dependencies.
- Locked the fixed legacy Gradle configuration and module inventory against
  source-set redirection or cross-project dependency injection.
- Removed an inaccurate generated device preview that did not represent the
  application UI.
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
