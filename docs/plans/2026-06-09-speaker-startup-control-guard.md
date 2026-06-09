---
title: Speaker Startup Control Guard
type: reliability
status: completed
date: 2026-06-09
---

# Speaker Startup Control Guard

## Problem Frame

The activity assumed the speech input and play button always bind from the
layout. A resource mismatch or layout regression would leave startup with null
controls and crash when registering playback actions.

## Scope Boundaries

- Preserve the existing layout IDs and typed-text-to-audio flow.
- Do not redesign the UI or change media playback behavior.
- Keep existing input normalization, length bounds, and playback cleanup.
- Keep verification available through the SDK-free baseline script.

## Implementation Units

### U1: Guard Required Controls

Files:

- Modify `app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java`

Approach:

- Check the speech input and play button after layout inflation.
- Log a sanitized startup error when either control is unavailable.
- Finish the activity before wiring playback actions.

### U2: Cover And Document The Contract

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Add SDK-free checks for the required-control guard.
- Document the startup guard in project notes.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- `git diff --check`
