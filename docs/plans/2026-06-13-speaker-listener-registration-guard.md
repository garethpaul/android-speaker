# Speaker Listener Registration Guard

Status: Completed

## Context

The activity depends on `UtteranceProgressListener` callbacks to clear atomic
utterance ownership and correlate playback failures. Android reports listener
registration failure through the return value of
`setOnUtteranceProgressListener`, but the current initialization path ignores
that value and marks the engine ready unconditionally.

## Goals

- Treat listener-registration failure as engine initialization failure.
- Reuse the existing stop, shutdown, reference clearing, disabled-control, and
  localized feedback path.
- Mark the engine ready only after language and listener setup both succeed.
- Preserve listener callback behavior, atomic ownership, speech input bounds,
  pause/destroy cleanup, and platform-only TextToSpeech privacy boundaries.
- Add SDK-free regression contracts and hostile mutations.

## Non-Goals

- Do not replace TextToSpeech, change language selection, or migrate the
  deprecated API stack.
- Do not add network access, remote speech, or MediaPlayer behavior.
- Do not change user-visible strings or utterance queue semantics.
- Do not claim emulator, device, engine, or audio-route verification.

## Implementation

- Capture the listener registration result in `MainActivity.java`.
- Call `handleEngineInitializationFailure()` and return on
  `TextToSpeech.ERROR` before setting readiness or enabling playback.
- Extend `scripts/check-baseline.sh` with exact ordering, cleanup, plan, and
  documentation contracts.
- Update README, SECURITY, CHANGES, and this plan.

## Verification

- Seven hostile mutations for ignored status, inverted condition, missing
  cleanup call/return, early readiness, stale documentation, and plan removal
  were rejected.
- Java 8/API 22 SDK-backed `make check` passed locally and from an external
  working directory, including zero-finding lint, six parser tests, both Gradle
  test variants, debug assembly, and merged-manifest privacy verification.
- Workflow YAML parsing, shell/Python syntax, `git diff --check`, and targeted
  secret scanning passed.

## Acceptance Criteria

- Listener registration failure cannot leave the engine marked ready.
- Failure cleanup stops and shuts down the allocated engine exactly through the
  existing initialization failure handler.
- Successful registration preserves the existing listener and readiness flow.
- Completed evidence is recorded only after all gates pass.
