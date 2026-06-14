# Android Speaker Device Verification Matrix

Use this matrix only for an exact implementation commit. Record the commit SHA and pull request
before testing so speech-engine and lifecycle evidence cannot be transferred to
a different implementation.

## Evidence Rules

- Use synthetic speech text that contains no personal, account, location,
  health, or business-sensitive information.
- Record the Android SDK, API level, device or emulator class, TextToSpeech
  engine and version, language, audio route, result, and evidence identifier.
- Do not include device identifiers, account names, voice recordings, user-entered
  text, unrelated notifications, engine data, or raw diagnostic dumps.
- Store durable evidence outside git. Link only a sanitized run, screenshot, or
  short log excerpt by stable identifier.
- Record each result as `pass`, `fail`, `blocked`, or `not run`, with an owner
  and follow-up for every result other than `pass`.
- Do not convert `not run` into passing evidence.

## Run Identity

| Field | Value |
| --- | --- |
| Commit SHA | `not run` |
| Pull request | `not run` |
| Android SDK / API | `not run` |
| Device or emulator | `not run` |
| Speech engine / version | `not run` |
| Language / locale | `not run` |
| Audio route | `not run` |
| Synthetic text | `not run` |
| Evidence location | `not run` |

## Verification Matrix

| Scenario | Expected evidence | Result | Evidence |
| --- | --- | --- | --- |
| Engine initialization | Playback controls remain disabled until engine, language, and listener setup succeed. | `not run` | `not run` |
| Engine unavailable | Failed initialization releases the unusable engine and keeps playback disabled. | `not run` | `not run` |
| Listener registration failure | Listener setup failure prevents readiness and releases the engine. | `not run` | `not run` |
| Valid speech | Synthetic text is spoken once through the selected platform engine without logging or persistence. | `not run` | `not run` |
| Empty input | Blank text is rejected without dispatching an utterance. | `not run` | `not run` |
| Overlength input | Input above 200 characters is rejected before engine dispatch. | `not run` | `not run` |
| QUEUE_FLUSH replacement | A newer request replaces active speech and owns subsequent completion callbacks. | `not run` | `not run` |
| Rapid speak replacement | Repeated taps cannot let stale callbacks clear or mutate the current utterance. | `not run` | `not run` |
| Completion callback | Successful completion clears only the matching utterance ownership state. | `not run` | `not run` |
| Pause during speech | Pausing the activity stops active speech and rejects late callbacks. | `not run` | `not run` |
| Destroy during speech | Destruction stops and shuts down the engine without retaining native resources. | `not run` | `not run` |
| Engine change | Switching the configured platform engine preserves readiness and failure boundaries. | `not run` | `not run` |
| Audio route change | Speaker, wired, Bluetooth, mute, and volume changes remain platform-controlled and crash-free. | `not run` | `not run` |
| Process relaunch | Relaunch starts without stale text, utterance ownership, generated audio, or engine state. | `not run` | `not run` |

## Current Status

No Android SDK, emulator, configured speech engine, controlled audio route,
physical device, or live playback scenario was executed for this checklist.
Treat every Android, speech-engine, audio, and lifecycle row as unexecuted until
evidence is attached to the exact commit.
