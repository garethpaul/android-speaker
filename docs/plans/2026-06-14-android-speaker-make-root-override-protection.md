# Android Speaker Make Root Override Protection

Status: Completed

## Problem

The Makefile derives its repository root from its own location, but GNU Make
command-line variables override an ordinary assignment. A hostile `ROOT` value
can redirect baseline checks, Python unit discovery, Gradle gates, and merged
manifest verification away from the reviewed checkout.

## Requirements

1. Protect the Makefile-derived root with GNU Make's `override` directive.
2. Preserve configurable SDK and Gradle commands, every target, skip condition,
   Python test command, manifest-after-build ordering, and existing tasks.
3. Require exact protected-root and tool semantics plus complete rooted
   baseline, Python, Gradle, and manifest contracts.
4. Pass local, external-directory, and hostile-root `make check` gates.
5. Reject focused root, tool, path, environment, ordering, and completed-plan
   mutations.

## Verification

- Run shell/Python syntax and the dependency-free baseline checker first.
- Run bounded local, external-directory, and hostile command-line `ROOT`
  `make check` gates, recording whether SDK-backed tasks execute or skip.
- Run focused mutations plus workflow YAML, Android XML, SVG XML, artifact,
  conflict-marker, whitespace, and changed-line credential audits.

## Scope Boundaries

- Do not change speech behavior, listener lifecycle, permissions, dependencies,
  workflows, Android/Python source, resources, or manifest policy.
- Do not weaken wrapper, merged-manifest, or unit-test contracts.
- Do not create SDK placeholders or claim emulator/device verification.
- Do not merge or close any pull request without explicit owner authorization.

## Work Completed

- Protected the Makefile-derived root while preserving SDK/Gradle
  configurability, Python tests, Gradle tasks, manifest ordering, and skips.
- Added dependency-free contracts for exact variables and complete rooted
  baseline, Python, Gradle, manifest, ordering, and completed-plan behavior.

## Verification Results

- The focused baseline checker plus shell and Python syntax checks passed.
- Local, external-directory, and hostile command-line `ROOT` `make check`
  gates each passed the baseline checker and all six Python unit tests while
  remaining anchored to this checkout.
- No Android SDK was configured, so Gradle lint, tests, assembly, and merged
  manifest verification truthfully reported their designed skips in all three
  contexts; no SDK-backed or device result is claimed.
- All fourteen focused mutations were rejected: missing `override`, `CURDIR`,
  recursive root assignment, `firstword`, eager SDK or Gradle assignment,
  unrooted baseline, Python tests, manifest check, or Gradle build, missing
  SDK-root propagation, replaced Gradle test task, removed manifest dependency,
  and reopened plan status.
- Workflow YAML, Android XML, SVG XML, shell/Python syntax, conflict-marker,
  bytecode/artifact, whitespace, exact-diff, and credential audits passed; only
  the three intended files changed and no generated artifacts remained.
