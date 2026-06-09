# Changes

## 2026-06-09

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
