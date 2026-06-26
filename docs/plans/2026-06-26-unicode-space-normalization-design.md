# Unicode Space Normalization Design

## Problem

`SpeechInput.normalize` used `Character.isWhitespace`, which deliberately does
not classify U+00A0, U+2007, or U+202F as whitespace. Those no-break spaces can
therefore make visually blank input pass the required-text check and acquire
audio focus before reaching the platform `TextToSpeech` engine.

## Options

1. Enumerate the three no-break spaces. This fixes the observed cases but
   duplicates a platform classification and can miss other Unicode separator
   characters.
2. Remove every format or non-rendering character. This is broader than the
   bug and could alter legitimate emoji or language text.
3. Treat `Character.isSpaceChar` as whitespace alongside the existing Java
   whitespace and ISO-control checks.

Platform references:

- [Java SE 8 `Character`](https://docs.oracle.com/javase/8/docs/api/java/lang/Character.html)
- [Android `Character`](https://developer.android.com/reference/java/lang/Character)

## Decision

Use option 3. It matches the Java and Android platform definition of Unicode
space characters, preserves visible text and formatting characters, and keeps
the existing collapse-to-one-space behavior.

## Verification

Add unit and dependency-free harness cases for embedded and separator-only
no-break spaces. Add a hostile mutation that removes
`Character.isSpaceChar(character)` and must fail the focused harness.
