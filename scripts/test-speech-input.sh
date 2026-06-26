#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/android-speaker-input.XXXXXX")
trap 'rm -rf "$TEMP_DIR"' EXIT HUP INT TERM

mkdir -p "$TEMP_DIR/source/garethpaul/com/androidspeaker" "$TEMP_DIR/classes"
cp "$ROOT_DIR/app/src/main/java/garethpaul/com/androidspeaker/SpeechInput.java" \
  "$TEMP_DIR/source/garethpaul/com/androidspeaker/SpeechInput.java"

cat > "$TEMP_DIR/source/garethpaul/com/androidspeaker/SpeechInputHarness.java" <<'EOF'
package garethpaul.com.androidspeaker;

public final class SpeechInputHarness {
    public static void main(String[] args) {
        assertEquals("Hello world", SpeechInput.normalize("Hello\u0000 world\n"));
        assertEquals("", SpeechInput.normalize("\u0000\n\t"));
        assertEquals("Hello world", SpeechInput.normalize("Hello\u00a0\u2007\u202fworld"));
        assertEquals("", SpeechInput.normalize("\u00a0\u2007\u202f"));
    }

    private static void assertEquals(String expected, String actual) {
        if (!expected.equals(actual)) {
            throw new AssertionError("expected <" + expected + "> but was <" + actual + ">");
        }
    }
}
EOF

javac -d "$TEMP_DIR/classes" \
  "$TEMP_DIR/source/garethpaul/com/androidspeaker/SpeechInput.java" \
  "$TEMP_DIR/source/garethpaul/com/androidspeaker/SpeechInputHarness.java"
java -cp "$TEMP_DIR/classes" garethpaul.com.androidspeaker.SpeechInputHarness
printf '%s\n' "Speech input harness passed."
