# Visible Speech Content Boundary

Status: Completed

## Problem

Speech normalization rejected controls and Unicode separators, but strings
containing only format characters such as zero-width space/joiner or only
combining marks remained non-empty and reached the platform `TextToSpeech`
engine. Removing those code points globally would damage valid decomposed text
and emoji ZWJ sequences.

## Design

- Preserve normalized code points unchanged.
- Scan by Unicode code point rather than UTF-16 code unit.
- Require at least one letter, number, punctuation mark, or symbol category.
- Return empty for format-only, combining-mark-only, unassigned, private-use,
  or malformed-surrogate-only input.
- Preserve the existing whitespace normalization and 200-code-unit bound.

## Alternatives

- Treating every format character as whitespace breaks emoji ZWJ sequences.
- Removing every combining mark changes decomposed visible text.
- Checking only `trim().length()` repeats the existing invisible-input gap.

## Work Completed

- Added code-point category admission in `SpeechInput`.
- Added JVM coverage for format-only and combining-mark-only rejection plus
  decomposed accent and emoji ZWJ preservation.
- Added a rollback mutation that restores unconditional normalized output.
- Made the grouped JVM Make recipe fail fast and strengthened the existing
  Unicode-space mutation with an embedded-separator assertion so the new
  visibility guard cannot mask loss of separator normalization.
- Updated repository guidance, changelog, and static completion contracts.

## Verification Completed

- Red-first proof: the focused harness returned the zero-width format sequence
  instead of an empty string before implementation.
- The focused speech-input harness and rollback mutation pass after the fix.
- The Unicode-space mutation is rejected for its embedded normalization
  contract, and `make test` stops on any focused script failure.
- Nine merged-manifest tests, the speech-input harness, both hostile mutations,
  and the SDK-free baseline pass.
- `make check` passes from the repository and through an absolute Makefile path
  outside it; Android lint, unit tests, assembly, and merged-manifest output
  truthfully remain skipped locally because no SDK is configured.
- `SpeechInput.java` compiles with Java 7 source/target compatibility under the
  available Java 11 compiler.
- An injected failure in the first JVM script makes `make test` fail, proving
  the grouped recipe now stops instead of continuing to later scripts.
- Shell syntax, whitespace, generated-artifact, conflict-marker, and
  credential-shaped text audits pass.
