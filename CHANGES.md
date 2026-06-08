# Changes

## 2026-06-08

- Added a repository changelog and expanded the documented Android verification
  gate to include lint, tests, and debug assembly.
- Cleaned Android lint findings by moving visible UI text into resources,
  adding a hint and input type for the speech text field, and moving the screen
  background into the app theme.
- Moved the speaker bitmap asset to `drawable-nodpi`, removed unused starter
  strings and menu resources, and documented the narrow legacy lint baseline.
