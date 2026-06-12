# Hosted Android Verification

## Status: Planned

## Context

The canonical workflow clears Android SDK variables and therefore proves only
source contracts. The existing API 22 project passes Android lint, Gradle
unit-test tasks, and debug assembly locally with build-tools 24.0.3 and Java 8.
Its sole lint finding is the intentionally deferred target-SDK modernization
warning, and its generated manifest preserves the no-network privacy boundary.

## Goal

Run the complete legacy Android gate in hosted CI and verify the merged app
manifest while preserving platform TextToSpeech behavior and trust boundaries.

## Changes

- Install Android API 22 and build-tools 24.0.3 before selecting Java 8.
- Run canonical `make check` with a bounded timeout.
- Add `OldTargetApi` to the existing narrow legacy lint suppressions and make
  every other warning fatal.
- Select deterministic non-queued PNG crunching without skipping aapt
  validation.
- Parse the merged debug manifest and require the expected package, SDK bounds,
  backup opt-out, launcher activity, and absence of `INTERNET`.
- Preserve immutable actions, read-only permissions, disabled checkout
  credentials, workflow uniqueness, ownership, and exact checker enforcement.

## Verification

- Run SDK-backed `make check` locally.
- Run the complete gate from a fresh external clone.
- Exercise focused hostile workflow, Gradle, lint, manifest, Makefile, checker,
  documentation, and plan-status mutations.
- Pass `git diff --check`.
- Require exact-head hosted verification before completion.

## Boundaries

- Do not change speech input, engine readiness, utterance ownership, or cleanup.
- Do not change compile SDK, target SDK, Gradle, Android plugin, or dependencies.
- Do not add credentials, signing material, permissions, or network behavior.
