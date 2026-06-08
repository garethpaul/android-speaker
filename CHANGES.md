# Changes

## 2026-06-08

- Normalized speech input before validation and TTS URL construction so leading
  or trailing spaces are not sent to the remote endpoint.
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
