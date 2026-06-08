## Android Speaker Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Android Speaker is a legacy Android sample that turns typed text into spoken
audio using a remote text-to-speech endpoint.

The repository is useful as a small example of Android input handling,
network-backed audio playback, and older media APIs.

The goal is to keep the sample readable while moving future work toward safer
text-to-speech, storage, and network behavior.

The current focus is:

Priority:

- Preserve the typed-text-to-audio playback flow
- Keep network and media behavior easy to inspect in `MainActivity`
- Avoid expanding external-storage use without a clear reason
- Maintain a buildable Android Studio/Gradle baseline

Next priorities:

- Prefer platform `TextToSpeech` or documented HTTPS APIs over ad hoc remote TTS
- Remove obsolete HTTP and storage assumptions
- Add tests or manual verification notes for playback behavior
- Modernize Gradle, SDK levels, permissions, and dependencies in a dedicated pass

Contribution rules:

- One PR = one focused media, network, or build change.
- Keep user-entered text handling explicit and documented.
- Verify playback behavior on a device or emulator for media changes.
- Avoid new dependencies unless they simplify or secure the sample.

## Security And Privacy

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Typed text may be personal. Changes should avoid logging user text or sending it
to undocumented services.

Remote TTS behavior should use HTTPS, clear endpoints, and failure handling.
Generated audio files and local paths should not be committed.

## What We Will Not Merge (For Now)

- New remote TTS providers without privacy and setup notes
- Broad rewrites that obscure the simple playback sample
- Storage permission expansion without scoped behavior
- Generated audio files, local paths, or signing material

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
