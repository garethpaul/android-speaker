#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MAIN_ACTIVITY="$ROOT_DIR/app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java"
APP_BUILD="$ROOT_DIR/app/build.gradle"
MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
ROOT_BUILD="$ROOT_DIR/build.gradle"
LAYOUT="$ROOT_DIR/app/src/main/res/layout/activity_main.xml"
README="$ROOT_DIR/README.md"
RES_DIR="$ROOT_DIR/app/src/main/res"
PAUSE_RELEASE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-speaker-pause-release.md"

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

if ! grep -Fq 'URLEncoder.encode(normalizeSpeechText(text), "UTF-8")' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Normalized typed text must be URL-encoded with UTF-8." >&2
  exit 1
fi

if ! grep -Fq "static String normalizeSpeechText(String text)" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Speech text normalization helper is missing." >&2
  exit 1
fi

if ! grep -Fq "String speechText = normalizeSpeechText(text);" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Playback must normalize text before validation." >&2
  exit 1
fi

if ! grep -Fq "private static final int MAX_SPEECH_TEXT_LENGTH = 200" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Speech playback must keep a bounded text length." >&2
  exit 1
fi

if ! grep -Fq "speechText.length() > MAX_SPEECH_TEXT_LENGTH" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Speech playback must reject overlong text before building a TTS URL." >&2
  exit 1
fi

if ! grep -Fq "R.string.speech_input_too_long" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Overlong speech text Toast must use a string resource." >&2
  exit 1
fi

if ! grep -Fq "buildTextToSpeechUrl(speechText)" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Playback must use normalized text for the TTS URL." >&2
  exit 1
fi

if ! grep -Fq "if (textInput == null || button == null)" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Speaker startup must guard required layout controls." >&2
  exit 1
fi

if ! grep -Fq 'Log.e(TAG, "Speaker controls are unavailable.");' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Speaker startup control failures must use sanitized logging." >&2
  exit 1
fi

if ! grep -Fq "finish();" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Speaker startup must finish when required controls are unavailable." >&2
  exit 1
fi

if grep -Fq '"Enter text to speak."' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Empty-input Toast text must live in string resources." >&2
  exit 1
fi

if grep -Fq '"Unable to play speech audio."' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Playback-failure Toast text must live in string resources." >&2
  exit 1
fi

if ! grep -Fq "R.string.speech_input_required" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Empty-input Toast must use a string resource." >&2
  exit 1
fi

if ! grep -Fq "R.string.speech_playback_failed" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Playback-failure Toast must use a string resource." >&2
  exit 1
fi

if grep -Fq 'Log.v("android-search", param)' "$MAIN_ACTIVITY"; then
  printf '%s\n' "User-entered text must not be logged." >&2
  exit 1
fi

if grep -Fq "nextPlayer.prepare();" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Remote media playback must not prepare synchronously on the UI thread." >&2
  exit 1
fi

if ! grep -Fq "nextPlayer.prepareAsync();" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Remote media playback must use asynchronous preparation." >&2
  exit 1
fi

if ! grep -Fq "setOnPreparedListener" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Async media playback must start from an OnPreparedListener." >&2
  exit 1
fi

if ! grep -Fq "setOnErrorListener" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Async media playback must handle MediaPlayer errors." >&2
  exit 1
fi

if ! grep -Fq "setOnCompletionListener" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Async media playback must release completed MediaPlayer instances." >&2
  exit 1
fi

if ! grep -Fq "private void handlePlaybackCompletion(MediaPlayer completedPlayer)" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Playback completion handling must be centralized." >&2
  exit 1
fi

if ! grep -Fq "protected void onPause()" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Activity pause must release active speech playback." >&2
  exit 1
fi

if ! awk '
  /protected void onPause\(\)/ {
    in_on_pause = 1
    saw_release = 0
    saw_super = 0
  }
  in_on_pause && /releasePlayer\(\);/ {
    saw_release = 1
  }
  in_on_pause && /super\.onPause\(\);/ {
    saw_super = 1
  }
  in_on_pause && /^    }/ {
    if (saw_release && saw_super) {
      found = 1
    }
    in_on_pause = 0
  }
  END {
    exit found ? 0 : 1
  }
' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Activity pause must release playback and preserve the Android lifecycle callback." >&2
  exit 1
fi

if ! grep -Fq "if (mediaPlayer == null || player != mediaPlayer)" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Playback preparation must ignore stale MediaPlayer callbacks." >&2
  exit 1
fi

if ! grep -Fq "if (completedPlayer == null || player != completedPlayer)" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Playback completion handling must ignore stale MediaPlayer callbacks." >&2
  exit 1
fi

if ! grep -Fq "if (failedPlayer == null || player != failedPlayer)" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Playback failure handling must ignore stale MediaPlayer callbacks." >&2
  exit 1
fi

if ! grep -Fq "player = nextPlayer;" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Playback must mark the active MediaPlayer before data-source preparation." >&2
  exit 1
fi

if grep -Fq "WRITE_EXTERNAL_STORAGE" "$MANIFEST"; then
  printf '%s\n' "Unused external storage permission must not be requested." >&2
  exit 1
fi

if ! grep -Fq 'android:allowBackup="false"' "$MANIFEST"; then
  printf '%s\n' "Android Auto Backup must stay disabled for this speech sample." >&2
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

if [ ! -f "$ROOT_DIR/CHANGES.md" ]; then
  printf '%s\n' "CHANGES.md is missing." >&2
  exit 1
fi

if [ ! -f "$ROOT_DIR/Makefile" ]; then
  printf '%s\n' "Makefile is missing." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must run the SDK-free baseline check." >&2
  exit 1
fi

if ! grep -Fq "lint:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a lint gate." >&2
  exit 1
fi

if ! grep -Fq "test:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a test gate." >&2
  exit 1
fi

if ! grep -Fq "build:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a build gate." >&2
  exit 1
fi

if ! grep -Fq "verify: lint test build" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile verify must run lint, test, and build gates." >&2
  exit 1
fi

if grep -Fq "hello_world" "$RES_DIR/values/strings.xml" || grep -Fq "action_settings" "$RES_DIR/values/strings.xml"; then
  printf '%s\n' "Unused starter strings must not be restored." >&2
  exit 1
fi

if [ -f "$RES_DIR/menu/menu_main.xml" ]; then
  printf '%s\n' "Unused starter menu must not be restored." >&2
  exit 1
fi

if [ ! -f "$RES_DIR/drawable-nodpi/mega.png" ]; then
  printf '%s\n' "Speaker icon must stay in drawable-nodpi." >&2
  exit 1
fi

if [ -d "$RES_DIR/drawable" ] && find "$RES_DIR/drawable" -name '*.png' | grep -q .; then
  printf '%s\n' "Speaker PNG assets must not live in density-scaled drawable/." >&2
  exit 1
fi

if grep -Fq 'android:background="@color/red"' "$LAYOUT"; then
  printf '%s\n' "Screen background must live in the theme to avoid layout overdraw." >&2
  exit 1
fi

if ! grep -Fq 'android:text="@string/play_button"' "$LAYOUT"; then
  printf '%s\n' "Play button text must use a string resource." >&2
  exit 1
fi

if ! grep -Fq 'android:hint="@string/speech_input_hint"' "$LAYOUT"; then
  printf '%s\n' "Speech input must provide a hint." >&2
  exit 1
fi

if ! grep -Fq 'android:inputType="textCapSentences"' "$LAYOUT"; then
  printf '%s\n' "Speech input must declare an inputType." >&2
  exit 1
fi

if ! grep -Fq 'name="speech_input_required"' "$RES_DIR/values/strings.xml" || \
   ! grep -Fq 'name="speech_playback_failed"' "$RES_DIR/values/strings.xml" || \
   ! grep -Fq 'name="speech_input_too_long"' "$RES_DIR/values/strings.xml"; then
  printf '%s\n' "Playback toast strings must be resource-backed." >&2
  exit 1
fi

if ! grep -Fq "LintError" "$ROOT_DIR/app/lint.xml"; then
  printf '%s\n' "lint.xml must document the obsolete lint API database limitation." >&2
  exit 1
fi

if ! grep -Fq "IconMissingDensityFolder" "$ROOT_DIR/app/lint.xml"; then
  printf '%s\n' "lint.xml must document the nodpi bitmap asset baseline." >&2
  exit 1
fi

if ! grep -Fq "./gradlew lint --no-daemon" "$README"; then
  printf '%s\n' "README must document Gradle lint verification." >&2
  exit 1
fi

if ! grep -Fq "./gradlew test --no-daemon" "$README"; then
  printf '%s\n' "README must document Gradle test verification." >&2
  exit 1
fi

if ! grep -Fq "./gradlew assembleDebug --no-daemon" "$README"; then
  printf '%s\n' "README must document Gradle build verification." >&2
  exit 1
fi

if ! grep -Fq "make check" "$README"; then
  printf '%s\n' "README must document the make check wrapper." >&2
  exit 1
fi

if ! grep -Fq "asynchronous media preparation" "$README"; then
  printf '%s\n' "README must document asynchronous media preparation." >&2
  exit 1
fi

if ! grep -Fq "Auto Backup disabled" "$README"; then
  printf '%s\n' "README must document the disabled Auto Backup baseline." >&2
  exit 1
fi

if ! grep -Fq "required speech controls" "$README"; then
  printf '%s\n' "README must document required speech control startup guards." >&2
  exit 1
fi

if ! grep -Fq "Stale MediaPlayer callbacks are ignored" "$README"; then
  printf '%s\n' "README must document stale MediaPlayer callback guards." >&2
  exit 1
fi

if ! grep -Fq "Active speech playback is released when the activity pauses" "$README"; then
  printf '%s\n' "README must document pause-time playback release." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-speaker-startup-control-guard.md"; then
  printf '%s\n' "Speaker startup control guard plan must document make check verification." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-speaker-stale-player-callback-guard.md"; then
  printf '%s\n' "Speaker stale MediaPlayer callback plan must document make check verification." >&2
  exit 1
fi

if [ ! -f "$PAUSE_RELEASE_PLAN" ]; then
  printf '%s\n' "Speaker pause release plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$PAUSE_RELEASE_PLAN" || ! grep -Fq "make check" "$PAUSE_RELEASE_PLAN"; then
  printf '%s\n' "Speaker pause release plan must record completed status and make check verification." >&2
  exit 1
fi

printf '%s\n' "Android speaker baseline checks passed."
