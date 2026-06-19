---
title: Gradle Wrapper Verification
date: 2026-06-12
status: completed
execution: code
---

# Gradle Wrapper Verification

## Summary

Add a checksum-capable generated Gradle Wrapper bootstrap while preserving the
speaker sample's Gradle 2.2.1, Java 8, API 22, strict lint, merged-manifest
privacy validation, TextToSpeech ownership, and failure cleanup.

## Problem Frame

The complete local and hosted Android gate is characterized, but the legacy
wrapper downloads Gradle 2.2.1 without archive verification and the SDK-free
checker does not authenticate the checked-in wrapper JAR or launchers.

## Requirements

- **R1:** Preserve Gradle 2.2.1, Android Gradle Plugin 1.1.0, Java 8, API 22,
  build-tools 24.0.3, dependencies, manifest privacy, and app behavior.
- **R2:** Pin the official Gradle 2.2.1 all-distribution SHA-256,
  `1d7c28b3731906fd1b2955946c1d052303881585fc14baedd675e4cf2bc1ecab`.
- **R3:** Regenerate the bootstrap with official Gradle 8.14.5 tooling and
  verify wrapper JAR SHA-256
  `7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172`.
- **R4:** Reject wrapper URL, checksum, JAR, launcher, documentation, and
  completion-evidence drift in the SDK-free checker.
- **R5:** Pass the complete local and final exact-head hosted Android and
  CodeQL gates before tracker reconciliation.

## Key Technical Decisions

- Use Gradle 8.14.5 only to generate the bootstrap while retaining the legacy
  runtime required by Android Gradle Plugin 1.1.0.
- Verify downloaded and checked-in artifacts as separate trust boundaries.
- Preserve the all distribution and document the uncached HTTPS dependency.

## Scope Boundaries

In scope: four wrapper files, static contracts, repository guidance, and
local/hosted evidence. Deferred: runtime modernization, dependencies,
TextToSpeech behavior, UI, manifest policy changes, and device testing.

## Implementation Units

### U1. Verified Wrapper Bootstrap

Generate the official bootstrap, retain Gradle 2.2.1, and prove fresh Java 8
success plus incorrect-checksum rejection.

### U2. Static Contracts And Documentation

Add exact wrapper and completed-plan contracts to the SDK-free checker and
document the online availability boundary.

### U3. Compatibility And Hosted Evidence

Run `make check` from the repository and an external working directory,
exercise focused mutations, and require final Check and CodeQL success.

## Risks And Mitigations

- Use a fresh Gradle user home so cached archives cannot hide verification.
- Verify the runtime under Java 8 before project tasks.
- Reject app, manifest, build-file, and workflow changes in this unit.

## Sources

- [Gradle Wrapper documentation](https://docs.gradle.org/current/userguide/gradle_wrapper.html)
- [Gradle security best practices](https://docs.gradle.org/current/userguide/best_practices_security.html)
- [Gradle 2.2.1 all-distribution checksum](https://services.gradle.org/distributions/gradle-2.2.1-all.zip.sha256)
- [Gradle 8.14.5 wrapper JAR checksum](https://services.gradle.org/distributions/gradle-8.14.5-wrapper.jar.sha256)

## Work Completed

- Regenerated all wrapper files with official Gradle 8.14.5 tooling while
  retaining Gradle 2.2.1 and the existing Android runtime.
- Added exact properties, wrapper JAR, launcher, documentation, and completed
  evidence contracts without changing app, manifest, build, or workflow files.

## Verification Completed

- A fresh temporary Gradle user home reported Gradle 2.2.1 on Corretto Java 8.
- A disposable wrapper with an incorrect checksum was rejected before execution.
- SDK-backed `make check` passed with zero lint issues, six parser tests, both
  unit-test variants, debug assembly, and merged-manifest privacy validation
  from the repository and an external working directory.
- Focused hostile mutations rejected wrapper properties, JAR, launcher,
  documentation, and incomplete plan evidence.
- Shell syntax and `git diff --check` passed.

## Hosted Verification

- On implementation head `6fe86e22a4d0e256b3176f0d212ccaf2a9417c31`,
  pull-request `Check` run `27441161511` passed the complete Java 8/API 22 and
  merged-manifest privacy gate.
- CodeQL run `27441160498` passed both the actions and java-kotlin analyzers.
- PR #4 was open and mergeable at that head. The final evidence-only commit
  must rerun both gates before tracker reconciliation.
