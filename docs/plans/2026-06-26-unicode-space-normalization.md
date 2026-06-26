# Unicode Space Normalization

Status: Completed

## Goal

Prevent visually blank Unicode separator input from reaching Android's
platform speech engine while preserving visible text and the existing 200-unit
input bound.

## Implementation

- Extend `SpeechInput.normalize` with `Character.isSpaceChar` alongside the
  existing Java whitespace and ISO-control checks.
- Cover embedded U+00A0, U+2007, and U+202F characters and separator-only input
  in the JUnit contract.
- Run a focused speech-input harness without Android or third-party
  dependencies.
- Run a hostile mutation that removes `Character.isSpaceChar(character)` and
  require the separator-only assertion to reject it.
- Document the boundary in repository guidance and the root `CHANGES.md`.

## Verification

- Red-first proof: the focused harness reported `expected <Hello world> but was
  <Hello   world>` before the implementation changed.
- The focused speech-input harness passed after implementation.
- The hostile mutation was rejected by the separator-only assertion.
- `make check` passed from the repository root and an external working
  directory.
- Shell syntax, whitespace, generated-artifact, and likely-secret audits
  passed.
- Hosted Android and CodeQL results are recorded on the pull request before
  merge.

## Runtime Boundary

No emulator, physical device, configured TextToSpeech engine, controlled audio
route, or live speech playback was exercised locally. The exact-commit device
matrix remains the authority for those platform behaviors.
