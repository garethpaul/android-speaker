# Speaker Utterance Ownership Tests

Status: Completed

## Problem

`MainActivity` serializes active utterance creation, conditional callback
clearing, and lifecycle abandonment with synchronized methods. Those methods
protect a real UI-thread/speech-callback race, but the repository only checks
their source text. A stale completion or error callback could erase ownership
of replacement speech without an executable unit test failing.

## Requirements

1. Extract utterance sequencing and active-ID ownership into a package-private
   pure Java component.
2. Keep creation, conditional clearing, and abandonment synchronized.
3. Preserve monotonic distinct IDs, replacement semantics, stale callback
   rejection, lifecycle abandonment, and current callback behavior.
4. Add JVM tests for first/replacement IDs, current and stale clearing, null
   clearing, abandonment, and callback-after-abandonment behavior.
5. Preserve TextToSpeech initialization, listener registration, queue mode,
   input validation, UI feedback, pause/destroy cleanup, and instrumentation.
6. Add mutation-sensitive portable contracts and truthful hosted/device limits.

## Implementation Units

### U1: Pure Ownership Component

**Files:**

- Create `app/src/main/java/garethpaul/com/androidspeaker/UtteranceOwnership.java`.
- Create `app/src/test/java/garethpaul/com/androidspeaker/UtteranceOwnershipTest.java`.
- Modify `app/build.gradle` with the existing ecosystem's JUnit 4 test-only
  dependency.

Move the synchronized ID state machine without Android dependencies and test
all ownership transitions directly.

### U2: Activity Integration

**File:** `app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java`

Delegate request creation, callback correlation, and lifecycle abandonment to
the component. Keep the listener's UI-thread error recheck and all engine/UI
behavior unchanged.

### U3: Contracts And Evidence

**Files:** `scripts/check-baseline.sh`, `README.md`, `VISION.md`, `CHANGES.md`,
and this plan.

Require the component, test cases, dependency, activity delegation, completed
evidence, and a clear device-runtime boundary.

## Test Scenarios

- First and replacement begins return distinct ordered IDs.
- Clearing the current ID succeeds exactly once.
- A stale or null ID cannot clear replacement ownership.
- Abandonment invalidates the current ID.
- A callback after abandonment cannot reclaim or clear future ownership.
- Activity error handling still rechecks ownership on the UI thread.

## Scope Boundaries

- Do not change speech text, queue mode, engine language, listener behavior,
  lifecycle timing, UI text, dependencies beyond test-only JUnit, or SDK levels.
- Do not claim TextToSpeech callback scheduling, audio, emulator, or device
  behavior from pure JVM tests.
- Keep this work stacked on the instrumentation-bootstrap pull request.

## Completed Verification

- The focused ownership tests passed all six transitions through the pinned
  legacy Gradle stack.
- Debug and release Gradle unit tasks passed, Android lint reported zero issues
  for both variants, and debug APK assembly succeeded with the installed SDK.
- The repository and external-directory `make check` gates passed with explicit
  SDK environment variables and bounded commands.
- Ten isolated hostile mutations were rejected for synchronization,
  replacement, stale/null clearing, abandonment, activity delegation, tests,
  dependency, guidance, and plan completion.
- Exact diff, generated-artifact and likely-secret audits, and whitespace checks
  passed after removing only explicit reproducible Gradle output.
- Hosted evidence is recorded separately from one bounded exact-head snapshot
  after push; TextToSpeech callbacks, audio, emulator, and device behavior are
  not claimed by these pure JVM tests.
