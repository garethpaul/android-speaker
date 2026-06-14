# Android Speaker Device Verification Checklist

Status: Completed

## Problem

Portable contracts cover speech input bounds, engine readiness, listener
registration, synchronized utterance ownership, stale callbacks, pause cleanup,
and destroy-time shutdown, but no checklist defines repeatable emulator or
physical-device evidence for the exact implementation commit.

## Requirements

1. Add an exact-commit matrix for initialization, valid and invalid input,
   queue ownership, completion, interruption, pause/resume, engine changes,
   audio routes, and destroy/relaunch behavior.
2. Require synthetic text and sanitized toolchain, device, engine, route,
   result, and evidence fields.
3. Keep repository checks separate from unexecuted Android, speech-engine,
   audio, and hardware scenarios.
4. Add mutation-sensitive contracts for the checklist and completion evidence.

## Scope Boundaries

- Do not change speech behavior, Android SDK, Gradle plugin, dependencies, or
  platform engine selection.
- Do not add real user text, device identifiers, account data, voice recordings,
  screenshots, logs, APKs, engine data, or local configuration.
- Do not claim emulator, speech-engine, audio-route, or physical-device
  execution from portable checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- `sh -n scripts/check-baseline.sh` and the focused baseline checker passed.
- `make check` passed from the repository and from an external working
  directory for all portable contracts available in this Linux environment.
- Twelve hostile mutations were rejected by the checklist's static contracts.
- No Android SDK, emulator, configured speech engine, controlled audio route, physical device, or live playback scenario was executed;
  every hardware-dependent matrix row remains `not run`.
