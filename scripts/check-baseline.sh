#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MAIN_ACTIVITY="$ROOT_DIR/app/src/main/java/garethpaul/com/androidspeaker/MainActivity.java"
APP_BUILD="$ROOT_DIR/app/build.gradle"
MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
ROOT_BUILD="$ROOT_DIR/build.gradle"
SETTINGS_GRADLE="$ROOT_DIR/settings.gradle"
GRADLE_PROPERTIES="$ROOT_DIR/gradle.properties"
WRAPPER_PROPERTIES="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"
LAYOUT="$ROOT_DIR/app/src/main/res/layout/activity_main.xml"
README="$ROOT_DIR/README.md"
SECURITY="$ROOT_DIR/SECURITY.md"
RES_DIR="$ROOT_DIR/app/src/main/res"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CODEOWNERS="$ROOT_DIR/.github/CODEOWNERS"
PLATFORM_TTS_PLAN="$ROOT_DIR/docs/plans/2026-06-10-platform-text-to-speech.md"
ATOMIC_OWNERSHIP_PLAN="$ROOT_DIR/docs/plans/2026-06-10-atomic-utterance-ownership.md"
HOSTED_ANDROID_PLAN="$ROOT_DIR/docs/plans/2026-06-12-hosted-android-verification.md"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
LINT_CONFIG="$ROOT_DIR/app/lint.xml"
MERGED_MANIFEST_CHECK="$ROOT_DIR/scripts/check_merged_manifest.py"
MERGED_MANIFEST_TEST="$ROOT_DIR/scripts/test_check_merged_manifest.py"
INIT_FAILURE_CLEANUP_PLAN="$ROOT_DIR/docs/plans/2026-06-12-speaker-initialization-failure-cleanup.md"
LISTENER_REGISTRATION_PLAN="$ROOT_DIR/docs/plans/2026-06-13-speaker-listener-registration-guard.md"
DEVICE_VERIFICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-android-speaker-device-verification-checklist.md"
INSTRUMENTATION_BOOTSTRAP_PLAN="$ROOT_DIR/docs/plans/2026-06-14-instrumentation-application-bootstrap.md"
APPLICATION_TEST="$ROOT_DIR/app/src/androidTest/java/garethpaul/com/androidspeaker/ApplicationTest.java"
WRAPPER_PLAN="$ROOT_DIR/docs/plans/2026-06-12-gradle-wrapper-verification.md"
GRADLEW="$ROOT_DIR/gradlew"
GRADLEW_BAT="$ROOT_DIR/gradlew.bat"
WRAPPER_JAR="$ROOT_DIR/gradle/wrapper/gradle-wrapper.jar"

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}';
  elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}';
  else printf '%s\n' "A SHA-256 utility is required for wrapper verification." >&2; exit 1; fi
}

expected_wrapper_properties() {
  cat <<'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionSha256Sum=1d7c28b3731906fd1b2955946c1d052303881585fc14baedd675e4cf2bc1ecab
distributionUrl=https\://services.gradle.org/distributions/gradle-2.2.1-all.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF
}

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

if find "$ROOT_DIR/app/src" -type f \( -name '*.java' -o -name '*.kt' \) \
  -exec grep -E 'translate_tts|TTS_ENDPOINT|MediaPlayer|URLEncoder|setDataSource|prepareAsync' {} + | grep -q .; then
  printf '%s\n' "Android source sets must not restore an app-controlled remote speech path." >&2
  exit 1
fi

if find "$ROOT_DIR/app/src" -type f \( -name '*.java' -o -name '*.kt' \) \
  -exec grep -E 'java\.net|android\.net|HttpURLConnection|URLConnection|Socket|WebView|org\.apache\.http|okhttp|retrofit' {} + | grep -q .; then
  printf '%s\n' "Android source sets must not add direct network clients." >&2
  exit 1
fi

if [ -d "$ROOT_DIR/app/libs" ] && \
  find "$ROOT_DIR/app/libs" -type f \( -name '*.jar' -o -name '*.aar' \) -print | grep -q .; then
  printf '%s\n' "Local Android binary dependencies are outside the auditable source baseline." >&2
  exit 1
fi

expected_dependencies="    compile fileTree(dir: 'libs', include: ['*.jar'])"
actual_dependencies=$(sed -n '/^dependencies {$/,/^}$/p' "$APP_BUILD" | sed '1d;$d' | sed '/^[[:space:]]*$/d')
if [ "$actual_dependencies" != "$expected_dependencies" ]; then
  printf '%s\n' "Android dependencies must remain at the audited legacy baseline." >&2
  exit 1
fi

expected_gradle_paths=$(printf '%s\n' \
  "$APP_BUILD" \
  "$ROOT_BUILD" \
  "$GRADLE_PROPERTIES" \
  "$WRAPPER_PROPERTIES" \
  "$SETTINGS_GRADLE" | LC_ALL=C sort)
actual_gradle_paths=$(find "$ROOT_DIR" \
  -path "$ROOT_DIR/.git" -prune -o \
  -path "$ROOT_DIR/app/build" -prune -o \
  -type f \( -name '*.gradle' -o -name 'gradle.properties' -o -name 'gradle-wrapper.properties' \) \
  -print | LC_ALL=C sort)
if [ "$actual_gradle_paths" != "$expected_gradle_paths" ]; then
  printf '%s\n' "The fixed legacy build must not add executable Gradle configuration." >&2
  exit 1
fi

expected_root_build=$(cat <<'EOF'
// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        maven {
            url 'https://repo1.maven.org/maven2'
        }
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:1.1.0'


        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    repositories {
        maven {
            url 'https://repo1.maven.org/maven2'
        }
    }
}
EOF
)
if [ "$(cat "$ROOT_BUILD")" != "$expected_root_build" ]; then
  printf '%s\n' "Root Gradle configuration must match the audited legacy baseline." >&2
  exit 1
fi

expected_app_build=$(cat <<'EOF'
apply plugin: 'com.android.application'

android {
    compileSdkVersion 22
    buildToolsVersion "24.0.3"

    aaptOptions {
        useNewCruncher false
    }

    lintOptions {
        warningsAsErrors true
    }

    defaultConfig {
        applicationId "garethpaul.com.androidspeaker"
        minSdkVersion 21
        targetSdkVersion 22
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
}
EOF
)
if [ "$(cat "$APP_BUILD")" != "$expected_app_build" ]; then
  printf '%s\n' "App Gradle configuration must match the audited legacy baseline." >&2
  exit 1
fi

if [ "$(cat "$SETTINGS_GRADLE")" != "include ':app'" ]; then
  printf '%s\n' "Gradle settings must keep the single audited app module." >&2
  exit 1
fi

expected_gradle_properties=$(cat <<'EOF'
# Project-wide Gradle settings.

# IDE (e.g. Android Studio) users:
# Gradle settings configured through the IDE *will override*
# any settings specified in this file.

# For more details on how to configure your build environment visit
# http://www.gradle.org/docs/current/userguide/build_environment.html

# Specifies the JVM arguments used for the daemon process.
# The setting is particularly useful for tweaking memory settings.
# Default value: -Xmx10248m -XX:MaxPermSize=256m
# org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8

# When configured, Gradle will run in incubating parallel mode.
# This option should only be used with decoupled projects. More details, visit
# http://www.gradle.org/docs/current/userguide/multi_project_builds.html#sec:decoupled_projects
# org.gradle.parallel=true
EOF
)
if [ "$(cat "$GRADLE_PROPERTIES")" != "$expected_gradle_properties" ]; then
  printf '%s\n' "Gradle properties must match the audited legacy baseline." >&2
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

LISTENER_SETUP=$(sed -n \
  '/int listenerStatus = engine.setOnUtteranceProgressListener(/,/textToSpeechReady = true;/p' \
  "$MAIN_ACTIVITY")
for listener_contract in \
  "int listenerStatus = engine.setOnUtteranceProgressListener(" \
  "if (listenerStatus == TextToSpeech.ERROR)" \
  "handleEngineInitializationFailure();" \
  "return;" \
  "textToSpeechReady = true;"; do
  if ! printf '%s\n' "$LISTENER_SETUP" | grep -Fq "$listener_contract"; then
    printf '%s\n' "Speaker listener registration guard is missing: $listener_contract" >&2
    exit 1
  fi
done
listener_call_line=$(printf '%s\n' "$LISTENER_SETUP" | grep -nF "int listenerStatus =" | cut -d: -f1)
listener_error_line=$(printf '%s\n' "$LISTENER_SETUP" | grep -nF "if (listenerStatus == TextToSpeech.ERROR)" | cut -d: -f1)
listener_cleanup_line=$(printf '%s\n' "$LISTENER_SETUP" | grep -nF "handleEngineInitializationFailure();" | cut -d: -f1)
listener_ready_line=$(printf '%s\n' "$LISTENER_SETUP" | grep -nF "textToSpeechReady = true;" | cut -d: -f1)
if [ -z "$listener_call_line" ] || [ -z "$listener_error_line" ] || \
   [ -z "$listener_cleanup_line" ] || [ -z "$listener_ready_line" ] || \
   [ "$listener_call_line" -ge "$listener_error_line" ] || \
   [ "$listener_error_line" -ge "$listener_cleanup_line" ] || \
   [ "$listener_cleanup_line" -ge "$listener_ready_line" ]; then
  printf '%s\n' "Speaker readiness must follow successful listener registration and failure cleanup." >&2
  exit 1
fi
if [ ! -f "$LISTENER_REGISTRATION_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$LISTENER_REGISTRATION_PLAN" || \
   ! grep -Fq "make check" "$LISTENER_REGISTRATION_PLAN" || \
   ! grep -Fq "hostile mutations" "$LISTENER_REGISTRATION_PLAN"; then
  printf '%s\n' "Speaker listener registration plan must record completed verification." >&2
  exit 1
fi

for required_device_path in "$ROOT_DIR/DEVICE_VERIFICATION.md" "$DEVICE_VERIFICATION_PLAN"; do
  if [ ! -f "$required_device_path" ]; then
    printf '%s\n' "Required Android Speaker device verification file is missing: ${required_device_path#"$ROOT_DIR/"}" >&2
    exit 1
  fi
done

for device_contract in \
  'commit SHA and pull request' \
  'synthetic speech text' \
  'Engine initialization' \
  'Engine unavailable' \
  'Listener registration failure' \
  'Overlength input' \
  'QUEUE_FLUSH replacement' \
  'Rapid speak replacement' \
  'Completion callback' \
  'Pause during speech' \
  'Destroy during speech' \
  'Engine change' \
  'Audio route change' \
  'Do not convert `not run` into passing evidence.' \
  'device identifiers, account names, voice recordings' \
  'every Android, speech-engine, audio, and lifecycle row as unexecuted'; do
  if ! grep -Fq "$device_contract" "$ROOT_DIR/DEVICE_VERIFICATION.md"; then
    printf '%s\n' "Android Speaker device checklist must keep contract: $device_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'DEVICE_VERIFICATION.md' "$README" || \
   ! grep -Fq 'explicit unexecuted rows' "$README" || \
   ! grep -Fq 'Android Speaker device verification matrix' "$ROOT_DIR/VISION.md" || \
   ! grep -Fq 'every runtime row explicitly unexecuted' "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' 'Repository guidance must document the unexecuted Android Speaker device matrix.' >&2
  exit 1
fi

for device_plan_contract in \
  'Status: Completed' \
  'make check' \
  'hostile mutations' \
  'No Android SDK, emulator, configured speech engine, controlled audio route, physical device, or live playback scenario was executed'; do
  if ! grep -Fq "$device_plan_contract" "$DEVICE_VERIFICATION_PLAN"; then
    printf '%s\n' "Android Speaker device plan must keep completion evidence: $device_plan_contract" >&2
    exit 1
  fi
done
for listener_doc in "$README" "$SECURITY" "$ROOT_DIR/CHANGES.md"; do
  if ! tr '\n' ' ' < "$listener_doc" | tr -s '[:space:]' ' ' | \
      grep -Fiq "listener registration failure"; then
    printf '%s\n' "$listener_doc must document listener registration failure handling." >&2
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

if find "$ROOT_DIR/app/src" -type f -name 'AndroidManifest.xml' \
  -exec grep -F "android.permission.INTERNET" {} + | grep -q .; then
  printf '%s\n' "Android source-set manifests must not request network access." >&2
  exit 1
fi

if find "$ROOT_DIR/app/src" -type f -name 'AndroidManifest.xml' \
  -exec grep -E '&#[xX]?[0-9A-Fa-f]+;' {} + | grep -q .; then
  printf '%s\n' "Android manifests must not obscure permission names with numeric entities." >&2
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

if ! grep -Fq "manifest: build" "$ROOT_DIR/Makefile" || \
   ! grep -Fq "PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s \$(ROOT)scripts -p 'test_*.py'" "$ROOT_DIR/Makefile" || \
   ! grep -Fq "PYTHONDONTWRITEBYTECODE=1 python3 \$(ROOT)scripts/check_merged_manifest.py" "$ROOT_DIR/Makefile" || \
   ! grep -Fq "verify: lint test manifest" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile verify must run source, unit, Android build, and merged-manifest gates." >&2
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

if ! grep -Fq "LintError" "$LINT_CONFIG"; then
  printf '%s\n' "lint.xml must document the obsolete lint API database limitation." >&2
  exit 1
fi

if ! grep -Fq "IconMissingDensityFolder" "$LINT_CONFIG"; then
  printf '%s\n' "lint.xml must document the nodpi bitmap asset baseline." >&2
  exit 1
fi

if ! grep -Fq "OldTargetApi" "$LINT_CONFIG"; then
  printf '%s\n' "lint.xml must document the deferred target-SDK modernization boundary." >&2
  exit 1
fi

if [ "$(grep -c '<issue id=' "$LINT_CONFIG")" -ne 3 ]; then
  printf '%s\n' "lint.xml must keep exactly the three documented legacy suppressions." >&2
  exit 1
fi

if [ ! -x "$MERGED_MANIFEST_CHECK" ] || [ ! -f "$MERGED_MANIFEST_TEST" ]; then
  printf '%s\n' "Merged-manifest checker and unit tests are required." >&2
  exit 1
fi

for manifest_contract in \
  'root.get("package") == "garethpaul.com.androidspeaker"' \
  'android_attribute(uses_sdk, "minSdkVersion") == "21"' \
  'android_attribute(uses_sdk, "targetSdkVersion") == "22"' \
  'android_attribute(application, "allowBackup") == "false"' \
  'android.permission.INTERNET' \
  'android.intent.action.MAIN' \
  'android.intent.category.LAUNCHER'; do
  if ! grep -Fq "$manifest_contract" "$MERGED_MANIFEST_CHECK"; then
    printf '%s\n' "Merged-manifest checker must keep contract: $manifest_contract" >&2
    exit 1
  fi
done

if [ "$(grep -c '^    def test_' "$MERGED_MANIFEST_TEST")" -ne 6 ]; then
  printf '%s\n' "Merged-manifest checker must keep six focused unit tests." >&2
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

workflow_paths=$(find "$ROOT_DIR/.github/workflows" -type f \( -name '*.yml' -o -name '*.yaml' \) -print | LC_ALL=C sort)
if [ "$workflow_paths" != "$CI_WORKFLOW" ]; then
  printf '%s\n' "The canonical check workflow must be the only GitHub Actions workflow." >&2
  exit 1
fi

expected_ci_workflow=$(cat <<'EOF'
name: Check

on:
  push:
    branches:
      - master
  pull_request:
  workflow_dispatch:

permissions:
  contents: read

env:
  FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true

concurrency:
  group: check-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  check:
    runs-on: ubuntu-24.04
    timeout-minutes: 15
    steps:
      - name: Check out repository
        uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
        with:
          persist-credentials: false

      - name: Install Android SDK packages
        run: '"${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-22" "build-tools;24.0.3"'

      - name: Set up Java 8
        uses: actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 # v5.2.0
        with:
          distribution: corretto
          java-version: "8"

      - name: Run full verification
        run: make check
EOF
)
if [ "$(cat "$CI_WORKFLOW")" != "$expected_ci_workflow" ]; then
  printf '%s\n' "GitHub Actions check workflow must match the complete credential-free Android contract." >&2
  exit 1
fi

if [ ! -f "$HOSTED_ANDROID_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "merged debug manifest" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "with zero lint issues, six parser unit" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "25 focused hostile workflow" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq 'pull-request run `27402555381`' "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq '`3d823386967a01c64f5de67239b872ba1d120fca`' "$HOSTED_ANDROID_PLAN"; then
  printf '%s\n' "Hosted Android verification plan must record completed local, manifest, and exact-head hosted evidence." >&2
  exit 1
fi

if [ ! -f "$CI_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$CI_PLAN" || \
   ! grep -Fq 'complete `make check` wrapper' "$CI_PLAN" || \
   ! grep -Fq "Android API 22 and build-tools 24.0.3" "$CI_PLAN" || \
   ! grep -Fq "merged debug manifest" "$CI_PLAN"; then
  printf '%s\n' "CI plan must document the complete hosted Android and merged-manifest gates." >&2
  exit 1
fi

if ! grep -Fq "GitHub Actions installs Android API 22 and build-tools 24.0.3" "$README" || \
   ! grep -Fq 'complete `make check` gate' "$README" || \
   ! grep -Fq "All other lint" "$README" || \
   ! grep -Fq "merged-manifest gate verifies" "$README"; then
  printf '%s\n' "README must document complete hosted Android, strict lint, and merged-manifest verification." >&2
  exit 1
fi

expected_codeowners=$(cat <<'EOF'
/.github/CODEOWNERS @garethpaul
/.github/workflows/ @garethpaul
/Makefile @garethpaul
/scripts/ @garethpaul
/build.gradle @garethpaul
/settings.gradle @garethpaul
/gradle.properties @garethpaul
/gradle/ @garethpaul
/gradlew @garethpaul
/gradlew.bat @garethpaul
/app/ @garethpaul
EOF
)
if [ ! -f "$CODEOWNERS" ] || [ "$(cat "$CODEOWNERS")" != "$expected_codeowners" ]; then
  printf '%s\n' "CODEOWNERS must protect the CI and Android privacy boundaries." >&2
  exit 1
fi

for make_contract in \
  'override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' \
  'ANDROID_HOME ?=' \
  'ANDROID_SDK_ROOT ?=' \
  'GRADLE ?= $(ROOT)gradlew' \
  'ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))'; do
  if ! grep -Fxq "$make_contract" "$ROOT_DIR/Makefile"; then
    printf '%s\n' "Makefile must keep contract: $make_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc '$(ROOT)scripts/check-baseline.sh' "$ROOT_DIR/Makefile")" -ne 1 ] || \
   [ "$(grep -Fc "PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s \$(ROOT)scripts -p 'test_*.py'" "$ROOT_DIR/Makefile")" -ne 1 ] || \
   [ "$(grep -Fc 'PYTHONDONTWRITEBYTECODE=1 python3 $(ROOT)scripts/check_merged_manifest.py; \' "$ROOT_DIR/Makefile")" -ne 1 ]; then
  printf '%s\n' "Baseline, Python unit, and manifest checks must use the protected root." >&2
  exit 1
fi

for gradle_contract in \
  'cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) lint --no-daemon; \' \
  'cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) test --no-daemon; \' \
  'cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) assembleDebug --no-daemon; \' ; do
  if [ "$(grep -Fc "$gradle_contract" "$ROOT_DIR/Makefile")" -ne 1 ]; then
    printf '%s\n' "Makefile must keep one complete rooted Gradle contract: $gradle_contract" >&2
    exit 1
  fi
done

if ! grep -Fxq 'manifest: build' "$ROOT_DIR/Makefile" || ! grep -Fxq 'verify: lint test manifest' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Manifest verification must remain after build in the verify gate." >&2
  exit 1
fi

if ! grep -Fxq "Status: Completed" "$ROOT_DIR/docs/plans/2026-06-14-android-speaker-make-root-override-protection.md"; then
  printf '%s\n' "Android Speaker Make root protection plan must record completed status." >&2
  exit 1
fi

if grep -Fq "/home/gjones" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must not embed a maintainer-specific Android SDK path." >&2
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

if [ ! -x "$GRADLEW" ] || [ ! -f "$GRADLEW_BAT" ] || [ ! -f "$WRAPPER_JAR" ] || [ ! -f "$WRAPPER_PROPERTIES" ]; then
  printf '%s\n' "Generated Gradle wrapper files must be present and gradlew must be executable." >&2; exit 1
fi
if [ "$(cat "$WRAPPER_PROPERTIES")" != "$(expected_wrapper_properties)" ]; then
  printf '%s\n' "Gradle wrapper properties must retain the reviewed Gradle 2.2.1 URL and checksum." >&2; exit 1
fi
if [ "$(sha256_file "$WRAPPER_JAR")" != "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172" ]; then
  printf '%s\n' "Gradle wrapper JAR must match Gradle's published 8.14.5 wrapper checksum." >&2; exit 1
fi
if [ "$(sha256_file "$GRADLEW")" != "b187b4c52e749f5760afdd6fadc31b2a98ad35fb249bf0dff03b72650f320409" ] || [ "$(sha256_file "$GRADLEW_BAT")" != "94102713eb8fb22d032397924c0f38ab2da783ba60d07054339f1190a0c4e2cd" ]; then
  printf '%s\n' "Gradle wrapper launchers must match the reviewed generated scripts." >&2; exit 1
fi
if ! grep -Fq "Gradle start up script for POSIX generated by Gradle." "$GRADLEW" || ! grep -Fq "Gradle startup script for Windows" "$GRADLEW_BAT"; then
  printf '%s\n' "Gradle wrapper launchers must retain generated provenance markers." >&2; exit 1
fi
if [ ! -f "$WRAPPER_PLAN" ] || ! grep -Fq "status: completed" "$WRAPPER_PLAN" || ! grep -Fq "fresh temporary Gradle user home" "$WRAPPER_PLAN" || ! grep -Fq "incorrect checksum was rejected" "$WRAPPER_PLAN" || ! grep -Fq 'SDK-backed `make check` passed' "$WRAPPER_PLAN" || ! grep -Fq "external working directory" "$WRAPPER_PLAN" || ! grep -Fq "hostile mutations rejected" "$WRAPPER_PLAN" || ! grep -Fq 'pull-request `Check` run `27441161511` passed' "$WRAPPER_PLAN" || ! grep -Fq 'CodeQL run `27441160498` passed' "$WRAPPER_PLAN" || ! grep -Fq "6fe86e22a4d0e256b3176f0d212ccaf2a9417c31" "$WRAPPER_PLAN"; then
  printf '%s\n' "Gradle wrapper plan must record completed local verification evidence." >&2; exit 1
fi
if ! grep -Fq "distributionSha256Sum" "$README" || ! grep -Fq "uncached build offline-reproducible" "$README" || ! grep -Fq "wrapper JAR and Gradle distribution checksums" "$SECURITY"; then
  printf '%s\n' "Repository docs must describe wrapper verification and its online boundary." >&2; exit 1
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

for instrumentation_contract in \
  "public void testApplicationCreatesSpeakerPackage() throws Exception" \
  "createApplication();" \
  "assertNotNull(getApplication());" \
  'assertEquals("garethpaul.com.androidspeaker", getApplication().getPackageName());'; do
  if ! grep -Fq "$instrumentation_contract" "$APPLICATION_TEST"; then
    printf '%s\n' "ApplicationTest must keep bootstrap assertion: $instrumentation_contract" >&2
    exit 1
  fi
done

for instrumentation_doc_contract in \
  "$README|instrumentation bootstrap creates the application" \
  "$ROOT_DIR/VISION.md|instrumentation bootstrap assertion" \
  "$ROOT_DIR/CHANGES.md|instrumentation bootstrap assertion"; do
  instrumentation_doc=${instrumentation_doc_contract%%|*}
  instrumentation_text=${instrumentation_doc_contract#*|}
  if ! grep -Fq "$instrumentation_text" "$instrumentation_doc"; then
    printf '%s\n' "$instrumentation_doc must document the instrumentation bootstrap assertion." >&2
    exit 1
  fi
done

for instrumentation_plan_contract in \
  "status: completed" \
  "make check" \
  "hostile mutations" \
  "No emulator or physical-device instrumentation was executed"; do
  if ! grep -Fqi "$instrumentation_plan_contract" "$INSTRUMENTATION_BOOTSTRAP_PLAN"; then
    printf '%s\n' "Instrumentation plan must keep completion evidence: $instrumentation_plan_contract" >&2
    exit 1
  fi
done

printf '%s\n' "Android speaker baseline checks passed."
