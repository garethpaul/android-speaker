# Android Speaker Make Root Override Protection

Status: Planned

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
