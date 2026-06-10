# Atomic Utterance Ownership

Status: Completed

## Context

Speech requests originate on the UI thread, while `UtteranceProgressListener`
callbacks can clear request ownership from a speech-engine callback thread. A
volatile request ID made individual reads visible but did not make the existing
check-then-clear transition atomic. An old completion could therefore erase a
newer request. Error callbacks also cleared ownership before posting to the UI
thread, allowing a stale failure message to appear after replacement speech
started.

## Changes

- Serialize utterance creation, conditional clearing, and lifecycle
  abandonment through synchronized ownership helpers.
- Recheck error callback ownership inside the UI-thread runnable before showing
  playback failure feedback.
- Extend the SDK-free baseline with atomic ownership and UI-thread error
  correlation contracts.
- Document the concurrency guarantee in the README, vision, and changelog.

## Verification

- `make check`
- Static mutations for unsynchronized clearing and pre-queued error clearing
- `git diff --check`

The Android SDK is unavailable on this host, so runtime callback scheduling
still requires verification on a device or emulator with a configured speech
engine.
