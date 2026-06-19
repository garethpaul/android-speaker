# Android Speaker Explicit Launcher Export Boundary

Status: Completed

## Problem

The app's sole `.MainActivity` owns the `MAIN`/`LAUNCHER` intent filter but
omits `android:exported`. Legacy Android infers launcher reachability, leaving
the component boundary implicit and blocking a future Android 12 target update
without a manifest correction.

## Priorities

1. Preserve launcher behavior while explicitly declaring the existing public
   entry point.
2. Extend the XML-based merged-manifest verifier and unit suite so missing,
   false, duplicate, unrelated, or filter-detached export declarations fail.
3. Keep speech lifecycle, utterance ownership, permissions, backup policy,
   build inputs, and dependencies unchanged.

## Requirements

- Set `android:exported="true"` only on `.MainActivity`.
- Require exactly one exported activity declaration in the merged manifest.
- Require the named exported activity to contain both `MAIN` and `LAUNCHER` in
  the same intent filter.
- Add mutation-sensitive source, parser-test, guidance, and completed-plan
  contracts.
- Preserve repository and external-directory verification equivalence.

## Implementation Units

### 1. Declare launcher reachability

**File:** `app/src/main/AndroidManifest.xml`

Add the explicit true attribute to the existing launcher activity only.

### 2. Enforce the merged boundary

**Files:** `scripts/check_merged_manifest.py`,
`scripts/test_check_merged_manifest.py`, `scripts/check-baseline.sh`

Use parsed XML to require one exported declaration, bind it to the named
launcher, and exercise missing, false, unrelated, and filter-detached cases.

### 3. Synchronize guidance

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
and this plan.

Document the intentional launcher boundary and completed verification evidence.

## Verification

- Run Python syntax and the focused merged-manifest unit suite.
- Run repository-root and external-directory `make check` with Java 8 and the
  configured Android SDK.
- Reject isolated source, merged-output, false, unrelated, filter, parser-test,
  guidance, and incomplete-plan mutations.
- Audit exact paths, generated artifacts, conflict markers, dependency and
  workflow drift, whitespace, and credential-shaped additions.

## Risks

- Launcher regression is controlled by binding the true export, activity name,
  and both launcher entries in parsed XML.
- Overexposure is controlled by requiring exactly one exported activity.
- This PR is stacked on PR #9 and must retain base-first merge ordering.

## Out Of Scope

- Speech engine, listener, utterance, toast, lifecycle, UI, or text changes.
- SDK, Gradle, Android plugin, dependency, permission, or target-SDK upgrades.
- Emulator, physical-device, speech-engine, language, audio-routing, and
  live-playback execution.

## Completion Evidence

- Python syntax and the nine-case focused merged-manifest suite passed.
- Repository-root and external-directory `make check` passed with Java 8 and
  the configured Android SDK, including debug/release unit tests, zero-issue
  lint, debug assembly, and parsed merged-manifest validation.
- Nine isolated mutations were rejected across source export, unrelated source
  export, merged export, false value, unrelated activity, launcher filter,
  parser tests, maintained guidance, and completed-plan evidence.
- Plan-aware review moved source-manifest enforcement from an attribute grep to
  the same parsed launcher/export contract used for merged output, keeping the
  SDK-free hosted gate mutation-sensitive.
- Exact-path diff, generated-artifact, conflict-marker, dependency/workflow
  drift, whitespace, and credential-shaped-addition audits passed.
- No emulator, physical device, speech engine, language, audio route, or live
  playback was exercised.
