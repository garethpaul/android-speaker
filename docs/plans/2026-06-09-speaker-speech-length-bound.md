# Speaker Speech Length Bound

## Status: Completed

## Context

The speaker sample trims empty input before building a remote TTS URL, but it
did not bound the length of user-entered text. Very large input could create an
oversized URL and send more text than the sample can reasonably explain or
verify.

## Objectives

- Preserve the existing typed-text-to-audio flow.
- Reject overlong speech text before constructing the TTS URL.
- Keep the rejection user-visible with a string resource.
- Protect the behavior with the SDK-free baseline checker.

## Work Completed

- Added `MAX_SPEECH_TEXT_LENGTH = 200`.
- Rejected normalized text longer than the cap before media player setup.
- Added `speech_input_too_long` to string resources.
- Extended `scripts/check-baseline.sh` to require the length bound and
  resource-backed toast.
- Updated README, VISION, and CHANGES.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Gradle lint, tests, and debug assembly run when a compatible Android SDK is
configured.
