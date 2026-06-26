#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/android-speaker-space-mutation.XXXXXX")
trap 'rm -rf "$TEMP_DIR"' EXIT HUP INT TERM

mkdir -p "$TEMP_DIR/source/garethpaul/com/androidspeaker" "$TEMP_DIR/classes"
sed '/Character\.isSpaceChar(character)/d' \
  "$ROOT_DIR/app/src/main/java/garethpaul/com/androidspeaker/SpeechInput.java" \
  > "$TEMP_DIR/source/garethpaul/com/androidspeaker/SpeechInput.java"

if grep -Fq 'Character.isSpaceChar(character)' \
  "$TEMP_DIR/source/garethpaul/com/androidspeaker/SpeechInput.java"; then
  printf '%s\n' "Unicode space mutation did not remove the guard." >&2
  exit 1
fi

cat > "$TEMP_DIR/source/garethpaul/com/androidspeaker/UnicodeSpaceMutationHarness.java" <<'EOF'
package garethpaul.com.androidspeaker;

public final class UnicodeSpaceMutationHarness {
    public static void main(String[] args) {
        if (!"".equals(SpeechInput.normalize("\u00a0\u2007\u202f"))) {
            throw new AssertionError("Unicode separator-only input reached speech dispatch");
        }
    }
}
EOF

javac -d "$TEMP_DIR/classes" \
  "$TEMP_DIR/source/garethpaul/com/androidspeaker/SpeechInput.java" \
  "$TEMP_DIR/source/garethpaul/com/androidspeaker/UnicodeSpaceMutationHarness.java"

if java -cp "$TEMP_DIR/classes" \
  garethpaul.com.androidspeaker.UnicodeSpaceMutationHarness \
  >"$TEMP_DIR/output" 2>&1; then
  printf '%s\n' "Unicode speech-space mutation survived the focused harness." >&2
  exit 1
fi

if ! grep -Fq 'AssertionError' "$TEMP_DIR/output"; then
  cat "$TEMP_DIR/output" >&2
  printf '%s\n' "Unicode speech-space mutation failed for an unexpected reason." >&2
  exit 1
fi

printf '%s\n' "Unicode speech-space mutation was rejected."
