# AGENTS.md

## Repository purpose

`garethpaul/android-speaker` is an Android application or sample. A speaking Android App

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `app` - application source or app module
- `build.gradle` - Gradle build configuration
- `gradlew` - checked-in Gradle wrapper

## Development commands

- Install dependencies: no repository-specific install command is documented.
- Full baseline: `make check`
- Combined verification: `make verify`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- Android unit tests when the SDK is configured: `./gradlew test`
- Android debug build when the SDK is configured: `./gradlew assembleDebug`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Language mix noted in the README: Java (2), shell (1).
- Use the checked-in Gradle wrapper for Android builds when an SDK is configured.

## Testing guidance

- A legacy instrumentation smoke test exists, but there is no substantive behavioral test suite; treat `make check` as the minimum baseline.
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.
- This legacy Android baseline pins Android build-tools 24.0.3 and Android Gradle Plugin 1.1.0.
- Speech input normalizes Java whitespace, Unicode separator characters, and control characters; it must be non-empty and is capped at 200 characters before dispatch to the platform `TextToSpeech` engine.
- The app does not request `INTERNET`; preserve engine readiness checks, `QUEUE_FLUSH`, synchronized utterance ownership, stale-callback rejection, and pause/destroy cleanup.
- Preserve synchronous initialization-failure cleanup and transient audio-focus ownership across callbacks and lifecycle changes.
- Startup checks that the required speech controls are available before wiring playback actions.
- Auto Backup disabled is part of the privacy baseline because the app has no documented restore behavior for user-entered speech text or generated playback state.
- The explicit launcher export boundary is limited to .MainActivity and preserves its MAIN/LAUNCHER entry point.
- This looks like a legacy Android project or sample. Expect Android SDK, Gradle, and support-library versions to matter.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
