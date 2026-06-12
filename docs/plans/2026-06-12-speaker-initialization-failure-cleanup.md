# Speaker Initialization Failure Cleanup

Status: Completed

## Context

Engine or language initialization failure disables playback and informs the
user, but retains the `TextToSpeech` instance until activity destruction. An
activity that remains open after failure therefore holds native speech-engine
resources it can no longer use.

## Changes

- Stop and shut down an allocated engine during initialization failure.
- Clear the activity engine reference after shutdown.
- Keep playback disabled and preserve the localized unavailable-engine warning.
- Keep destroy-time cleanup idempotent when failure cleanup already ran.
- Extend the SDK-free baseline and README with the failure cleanup contract.

## Verification

- `make check`
- Static mutation that removes failure-path engine shutdown
- `git diff --check`

The Android SDK and a configured speech engine are unavailable on this host,
so runtime initialization failure still requires device or emulator testing.
