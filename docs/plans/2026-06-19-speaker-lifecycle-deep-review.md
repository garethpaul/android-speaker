# Speaker Lifecycle Deep Review

Status: Completed

## Scope

Review the stacked pull requests from #4 through #10 at `8d9dd5582324` using
the evidence-first GitHub deep-review workflow. Follow TextToSpeech
construction, initialization, listener registration, language selection,
utterance ownership, queue replacement, input normalization, audio focus,
lifecycle cleanup, instrumentation bootstrap, manifest exports, and wrapper
provenance.

## Findings

- Android 5.1 documents that constructor failure may invoke `OnInitListener`
  before the `TextToSpeech` instance is fully constructed. The activity stored
  the instance only after constructor return, so its failure cleanup observed a
  null field and could not release the failed engine.
- Input normalization only trimmed its ends. Embedded ISO control characters
  and control-only input could be dispatched to an engine.
- Playback did not request or release audio focus. On API 22, platform guidance
  leaves focus cooperation to applications, so speech could mix with or
  continue across competing playback.

These behaviors were introduced or carried forward by
`2e347d0fc663b71303e9b58aee025d1c95eb283f` on 2026-06-10 when the app moved
to platform TextToSpeech. Provenance confidence is clear from bounded history
and blame.

## Fix

- Keep initialization state in a synchronized Android-free owner so immediate
  failure survives constructor return and late success after destruction cannot
  mark playback ready.
- Normalize ISO control characters and whitespace before empty and length
  validation.
- Request transient audio focus before speech. Reuse held focus for
  `QUEUE_FLUSH` replacement and release it exactly once for the current
  utterance, focus loss, immediate failure, pause, or destroy.

The platform API calls remain visible in `MainActivity`; no unverified wrapper
or broad TextToSpeech abstraction was added.

## Proof

- The Gradle 8.14.5 wrapper JAR and Gradle 2.2.1 distribution checksums matched
  Gradle's official published values before any wrapper execution.
- Thirteen pure JVM tests passed under Java 8: six utterance ownership, two
  speech input, three initialization lifecycle, and two audio-focus ownership.
- Main Android sources compiled directly against the official API 22
  `android.jar` under Java 8.
- Repository and external static contracts passed through `make check`; nine
  Python manifest tests passed.
- Six isolated hostile mutations were rejected for control filtering,
  destroyed initialization, constructor cleanup, focus loss, completion
  release, and exact-once focus release.

## Runtime Boundary

No emulator, physical device, configured TextToSpeech engine, controlled audio
route, or live playback was available. Engine installation, US English voice
availability, engine-specific network/privacy behavior, callback scheduling,
audible output, and focus behavior on actual devices remain unverified and must
be recorded against the exact commit in `DEVICE_VERIFICATION.md`.
