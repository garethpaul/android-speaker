# Android Speaker

Legacy Android sample that turns typed text into spoken audio using a remote
text-to-speech endpoint.

## Toolchain

This project currently uses the original Android build stack:

- Gradle wrapper 2.2.1
- Android Gradle Plugin 1.1.0
- compile SDK 22 / target SDK 22
- Android build-tools 24.0.3

Configure an Android SDK path before running Gradle:

```sh
export ANDROID_HOME=/path/to/android-sdk
```

or create an untracked `local.properties` file:

```properties
sdk.dir=/path/to/android-sdk
```

## Verify

Run the SDK-free source baseline check first:

```sh
scripts/check-baseline.sh
```

Then run Gradle after Android SDK configuration is available:

```sh
ANDROID_HOME=/home/gjones/android-sdk ./gradlew tasks --no-daemon
ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon
ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon
```

## Modernization Notes

The current baseline URL-encodes text before calling the TTS endpoint, uses an
HTTPS request URL, avoids logging user-entered text, and removes the unused
external-storage download path. It also uses HTTPS Maven Central for build
resolution. Future work should replace the remote TTS call with platform
`TextToSpeech` or a documented provider, add media playback tests, modernize SDK
levels, and verify runtime behavior on an emulator or device.
