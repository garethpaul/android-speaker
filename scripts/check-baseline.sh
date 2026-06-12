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
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
PLATFORM_TTS_PLAN="$ROOT_DIR/docs/plans/2026-06-10-platform-text-to-speech.md"
ATOMIC_OWNERSHIP_PLAN="$ROOT_DIR/docs/plans/2026-06-10-atomic-utterance-ownership.md"
INIT_FAILURE_CLEANUP_PLAN="$ROOT_DIR/docs/plans/2026-06-12-speaker-initialization-failure-cleanup.md"

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

if grep -Eq 'translate_tts|MediaPlayer|URLEncoder|setDataSource|prepareAsync' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Speaker playback must not restore the undocumented remote media path." >&2
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
  printf '%s\n' "Speech playback must reject overlong text before engine dispatch." >&2
  exit 1
fi

if ! grep -Fq "R.string.speech_input_too_long" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Overlong speech text Toast must use a string resource." >&2
  exit 1
fi

if ! grep -Fq "if (textInput == null || playButton == null)" "$MAIN_ACTIVITY"; then
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

for tts_contract in \
  "implements TextToSpeech.OnInitListener" \
  "new TextToSpeech(getApplicationContext(), this)" \
  "status != TextToSpeech.SUCCESS" \
  "engine.setLanguage(Locale.US)" \
  "TextToSpeech.LANG_MISSING_DATA" \
  "TextToSpeech.LANG_NOT_SUPPORTED" \
  "playButton.setEnabled(false)" \
  "playButton.setEnabled(true)" \
  "setOnUtteranceProgressListener" \
  "private synchronized String beginUtterance()" \
  "private synchronized boolean clearActiveUtterance(String utteranceId)" \
  "private synchronized void abandonActiveUtterance()" \
  "clearActiveUtterance(utteranceId)" \
  'String utteranceId = "speaker-" + (++utteranceSequence)' \
  "String utteranceId = beginUtterance()" \
  "engine.speak(speechText, TextToSpeech.QUEUE_FLUSH, null, utteranceId)" \
  "if (result == TextToSpeech.ERROR)" \
  "textToSpeech.stop()" \
  "textToSpeech.shutdown()"; do
  if ! grep -Fq "$tts_contract" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing platform text-to-speech contract: $tts_contract" >&2
    exit 1
  fi
done

if grep -Fq "volatile String activeUtteranceId" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Utterance ownership must use atomic transitions rather than a volatile check-then-clear." >&2
  exit 1
fi

if ! grep -Fq "public void onError(final String utteranceId)" "$MAIN_ACTIVITY" || \
   ! grep -Fq "if (clearActiveUtterance(utteranceId))" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Playback errors must recheck utterance ownership on the UI thread." >&2
  exit 1
fi

if [ "$(grep -Fc "playButton.setEnabled(false);" "$MAIN_ACTIVITY")" -lt 2 ]; then
  printf '%s\n' "Playback must stay disabled before initialization and after engine failure." >&2
  exit 1
fi

if [ "$(grep -Fc "clearActiveUtterance(utteranceId)" "$MAIN_ACTIVITY")" -lt 3 ]; then
  printf '%s\n' "Speech completion, callback failure, and dispatch failure must correlate utterances." >&2
  exit 1
fi

INIT_FAILURE_HANDLER=$(sed -n \
  '/private void handleEngineInitializationFailure()/,/private synchronized String beginUtterance()/p' \
  "$MAIN_ACTIVITY")
for failure_cleanup_contract in \
  "TextToSpeech engine = textToSpeech;" \
  "textToSpeech = null;" \
  "if (engine != null)" \
  "engine.stop();" \
  "engine.shutdown();"; do
  if ! printf '%s\n' "$INIT_FAILURE_HANDLER" | grep -Fq "$failure_cleanup_contract"; then
    printf '%s\n' "Speaker initialization failure cleanup is missing: $failure_cleanup_contract" >&2
    exit 1
  fi
done

if [ ! -f "$INIT_FAILURE_CLEANUP_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$INIT_FAILURE_CLEANUP_PLAN" || \
   ! grep -Fq "make check" "$INIT_FAILURE_CLEANUP_PLAN"; then
  printf '%s\n' "Speaker initialization failure cleanup plan must record completed make check verification." >&2
  exit 1
fi

if grep -Fq "android.permission.INTERNET" "$MANIFEST"; then
  printf '%s\n' "Platform text-to-speech must not request network access." >&2
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

if ! grep -Fq 'android:maxLength="200"' "$LAYOUT"; then
  printf '%s\n' "Speech input must enforce the documented length bound in the UI." >&2
  exit 1
fi

if ! grep -Fq 'name="speech_input_required"' "$RES_DIR/values/strings.xml" || \
   ! grep -Fq 'name="speech_engine_unavailable"' "$RES_DIR/values/strings.xml" || \
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

if ! grep -Fq "GitHub Actions" "$README"; then
  printf '%s\n' "README must document the GitHub Actions baseline." >&2
  exit 1
fi

if ! grep -Fq 'platform `TextToSpeech`' "$README"; then
  printf '%s\n' "README must document platform text-to-speech playback." >&2
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

if ! grep -Fq 'not request the `INTERNET` permission' "$README"; then
  printf '%s\n' "README must document the network-permission removal." >&2
  exit 1
fi

if ! grep -Fq "stops active speech when the activity pauses" "$README"; then
  printf '%s\n' "README must document pause-time speech cleanup." >&2
  exit 1
fi

if ! grep -Fq "Utterance ownership transitions are synchronized" "$README"; then
  printf '%s\n' "README must document atomic utterance ownership." >&2
  exit 1
fi

if ! grep -Fq "Failed speech-engine initialization releases the engine immediately" "$README"; then
  printf '%s\n' "README must document initialization failure cleanup." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-speaker-startup-control-guard.md"; then
  printf '%s\n' "Speaker startup control guard plan must document make check verification." >&2
  exit 1
fi

if [ ! -f "$CI_WORKFLOW" ]; then
  printf '%s\n' "GitHub Actions check workflow is missing." >&2
  exit 1
fi

for workflow_contract in \
  "permissions:" \
  "contents: read" \
  "runs-on: ubuntu-24.04" \
  "cancel-in-progress: true" \
  "timeout-minutes: 5" \
  "workflow_dispatch:" \
  "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" \
  'ANDROID_HOME: ""' \
  'ANDROID_SDK_ROOT: ""' \
  "run: make check"; do
  if ! grep -Fq "$workflow_contract" "$CI_WORKFLOW"; then
    printf '%s\n' "GitHub Actions check workflow must keep contract: $workflow_contract" >&2
    exit 1
  fi
done

for make_contract in \
  'ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' \
  'ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))'; do
  if ! grep -Fq "$make_contract" "$ROOT_DIR/Makefile"; then
    printf '%s\n' "Makefile must keep contract: $make_contract" >&2
    exit 1
  fi
done

if grep -Fq "/home/gjones" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must not embed a maintainer-specific Android SDK path." >&2
  exit 1
fi

if [ ! -f "$CI_PLAN" ]; then
  printf '%s\n' "Speaker CI baseline plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CI_PLAN" || ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "Speaker CI baseline plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$PLATFORM_TTS_PLAN" ]; then
  printf '%s\n' "Platform text-to-speech plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$PLATFORM_TTS_PLAN" || ! grep -Fq "make check" "$PLATFORM_TTS_PLAN"; then
  printf '%s\n' "Platform text-to-speech plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$ATOMIC_OWNERSHIP_PLAN" ]; then
  printf '%s\n' "Atomic utterance ownership plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$ATOMIC_OWNERSHIP_PLAN" || \
   ! grep -Fq "make check" "$ATOMIC_OWNERSHIP_PLAN"; then
  printf '%s\n' "Atomic utterance ownership plan must record completed status and make check verification." >&2
  exit 1
fi

printf '%s\n' "Android speaker baseline checks passed."
