---
title: Instrumentation Application Bootstrap
type: testing
status: completed
date: 2026-06-14
---

# Instrumentation Application Bootstrap

## Problem Frame

The checked-in `ApplicationTest` only declares a constructor. It compiles but
contains no test method, so instrumentation execution proves no application
bootstrap behavior.

## Requirements

- Create the application through the existing legacy `ApplicationTestCase`.
- Assert a non-null application instance with the Android Speaker package.
- Keep compatibility with the Android API 22 and Gradle 2.2.1 baseline.
- Add a fail-closed source contract and honest maintained guidance.

## Scope Boundaries

- Do not modernize Gradle, the Android plugin, target SDK, or TextToSpeech API.
- Do not invoke speech synthesis, engine selection, audio routing, or network
  side effects.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- Compile/package the instrumentation APK with the configured Android SDK.
- Run repository and external-directory `make check`.
- Reject hostile mutations for the test method, application creation, non-null
  assertion, package assertion, documentation, and plan completion.
- Record instrumentation execution as unexecuted unless a device or emulator is
  actually used.

## Risks

- This bootstrap assertion does not cover TextToSpeech engine availability,
  language selection, audio output, lifecycle timing, or device behavior.
- The legacy instrumentation test requires a compatible emulator or physical
  device for execution.

## Verification Results

- `app:assembleDebugAndroidTest` compiled and packaged the instrumentation APK
  against the configured Android SDK.
- Repository and external-directory `make check` passed the SDK-backed lint,
  unit-test, debug assembly, merged-manifest, and portable-contract gates.
- Six hostile mutations covering the test method, application creation,
  non-null assertion, package assertion, documentation, and completed-plan
  evidence were rejected.
- No emulator or physical-device instrumentation was executed, so the runtime
  assertion remains unexecuted locally.
