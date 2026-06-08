#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MAIN_ACTIVITY="$ROOT_DIR/app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java"
APP_BUILD="$ROOT_DIR/app/build.gradle"
MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
ROOT_BUILD="$ROOT_DIR/build.gradle"

if ! grep -Fq "url 'https://repo1.maven.org/maven2'" "$ROOT_BUILD"; then
  printf '%s\n' "Build repositories must use HTTPS Maven Central." >&2
  exit 1
fi

if grep -Fq "jcenter()" "$ROOT_BUILD"; then
  printf '%s\n' "Build repositories must not use JCenter." >&2
  exit 1
fi

if ! grep -Fq 'buildToolsVersion "24.0.3"' "$APP_BUILD"; then
  printf '%s\n' "Android build-tools must stay pinned to 24.0.3 for 64-bit aapt." >&2
  exit 1
fi

if grep -Fq "commons-lang" "$APP_BUILD"; then
  printf '%s\n' "Unused commons-lang dependency must not be reintroduced." >&2
  exit 1
fi

if ! grep -Fq 'private static final String TTS_ENDPOINT = "https://translate.google.com/translate_tts?tl=en&q="' "$MAIN_ACTIVITY"; then
  printf '%s\n' "HTTPS TTS endpoint constant is missing or changed." >&2
  exit 1
fi

if ! grep -Fq 'URLEncoder.encode(text, "UTF-8")' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Typed text must be URL-encoded with UTF-8." >&2
  exit 1
fi

if grep -Fq 'Log.v("android-search", param)' "$MAIN_ACTIVITY"; then
  printf '%s\n' "User-entered text must not be logged." >&2
  exit 1
fi

if grep -Fq "WRITE_EXTERNAL_STORAGE" "$MANIFEST"; then
  printf '%s\n' "Unused external storage permission must not be requested." >&2
  exit 1
fi

if git -C "$ROOT_DIR" ls-files '.idea/*' '*.iml' | grep -q .; then
  printf '%s\n' "Generated IDE metadata must not be tracked." >&2
  exit 1
fi

if ! grep -Fq "Android build-tools 24.0.3" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the pinned Android build-tools version." >&2
  exit 1
fi

if ! grep -Fq "HTTPS Maven Central" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document Maven Central build resolution." >&2
  exit 1
fi

printf '%s\n' "Android speaker baseline checks passed."
