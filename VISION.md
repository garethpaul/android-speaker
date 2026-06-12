## Android Speaker Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Android Speaker is a legacy Android sample that turns typed text into spoken
audio using Android's platform text-to-speech engine.

The repository is useful as a small example of Android input handling,
platform speech playback, and Android lifecycle management.

The goal is to keep the sample readable while moving future work toward safer
text-to-speech, storage, and network behavior.

The current focus is:

Priority:

- Preserve the typed-text-to-audio playback flow
- Keep speech engine behavior easy to inspect in `MainActivity`
- Avoid expanding external-storage use without a clear reason
- Keep Android Auto Backup disabled unless restore behavior is explicitly designed
- Maintain a buildable Android Studio/Gradle baseline
- Keep root lint, test, and build gates wired to the Gradle project
- Disable playback until platform speech initialization succeeds
- Stop active speech when the activity pauses and shut down on destroy
- Ignore stale utterance callbacks after a newer speech request replaces them
- Keep utterance ownership atomic across UI and speech-engine callback threads
- Keep GitHub Actions running the root `make check` baseline before review
- Keep the legacy Gradle runtime behind a checksum-verified generated wrapper
- Keep user-entered speech text bounded before platform engine dispatch
- Keep startup guarded when required speech controls are missing

Next priorities:

- Keep hard-coded remote speech endpoints and unnecessary network permission out
  of the app
- Remove obsolete storage assumptions
- Add tests or manual verification notes for playback behavior
- Evaluate Gradle runtime, SDK, permissions, and dependency modernization
  together in a dedicated compatibility pass; wrapper hardening is separate

Contribution rules:

- One PR = one focused media, network, or build change.
- Keep user-entered text handling explicit and documented.
- Verify playback behavior on a device or emulator for media changes.
- Keep `.github/workflows/check.yml` aligned with the documented `make check`
  wrapper.
- Avoid new dependencies unless they simplify or secure the sample.

## Security And Privacy

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Typed text may be personal. Changes should avoid logging user text or sending it
to hard-coded or undocumented services.

Platform speech behavior should handle unavailable engines and lifecycle stops.
Generated audio files and local paths should not be committed.
Auto Backup should remain disabled unless the app gains documented local data
that is safe to restore across devices.

## What We Will Not Merge (For Now)

- New remote TTS providers without privacy and setup notes
- Broad rewrites that obscure the simple playback sample
- Storage permission expansion without scoped behavior
- Generated audio files, local paths, or signing material

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
