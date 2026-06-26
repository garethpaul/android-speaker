#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/android-speaker-visible-mutation.XXXXXX")
trap 'rm -rf "$TEMP_DIR"' EXIT HUP INT TERM

mkdir -p "$TEMP_DIR/source/garethpaul/com/androidspeaker" "$TEMP_DIR/classes"
sed 's/return hasSpeechContent(normalized) ? normalized.toString() : "";/return normalized.toString();/' \
  "$ROOT_DIR/app/src/main/java/garethpaul/com/androidspeaker/SpeechInput.java" \
  > "$TEMP_DIR/source/garethpaul/com/androidspeaker/SpeechInput.java"

if grep -Fq 'return hasSpeechContent(normalized)' \
  "$TEMP_DIR/source/garethpaul/com/androidspeaker/SpeechInput.java"; then
  printf '%s\n' "Visible speech mutation did not remove the content guard." >&2
  exit 1
fi

cat > "$TEMP_DIR/source/garethpaul/com/androidspeaker/VisibleSpeechMutationHarness.java" <<'JAVA'
package garethpaul.com.androidspeaker;

public final class VisibleSpeechMutationHarness {
    public static void main(String[] args) {
        if (!"".equals(SpeechInput.normalize("\u200b\u200d"))) {
            throw new AssertionError("format-only input reached speech dispatch");
        }
        if (!"".equals(SpeechInput.normalize("\u0301\u034f"))) {
            throw new AssertionError("combining-mark-only input reached speech dispatch");
        }
    }
}
JAVA

javac -d "$TEMP_DIR/classes" \
  "$TEMP_DIR/source/garethpaul/com/androidspeaker/SpeechInput.java" \
  "$TEMP_DIR/source/garethpaul/com/androidspeaker/VisibleSpeechMutationHarness.java"

if java -cp "$TEMP_DIR/classes" \
  garethpaul.com.androidspeaker.VisibleSpeechMutationHarness \
  >"$TEMP_DIR/output" 2>&1; then
  printf '%s\n' "Visible speech mutation survived the focused harness." >&2
  exit 1
fi

if ! grep -Fq 'AssertionError' "$TEMP_DIR/output"; then
  cat "$TEMP_DIR/output" >&2
  printf '%s\n' "Visible speech mutation failed for an unexpected reason." >&2
  exit 1
fi

printf '%s\n' "Visible speech mutation was rejected."
