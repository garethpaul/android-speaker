.PHONY: build check lint manifest test verify

ANDROID_HOME ?=
ANDROID_SDK_ROOT ?=
ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))
GRADLE ?= $(ROOT)gradlew

lint:
	$(ROOT)scripts/check-baseline.sh
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) lint --no-daemon; \
	else \
		echo "Android SDK not configured; Gradle lint skipped."; \
	fi

test:
	PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s $(ROOT)scripts -p 'test_*.py'
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) test --no-daemon; \
	else \
		echo "Android SDK not configured; Gradle tests skipped."; \
	fi

build:
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) assembleDebug --no-daemon; \
	else \
		echo "Android SDK not configured; Gradle build skipped."; \
	fi

manifest: build
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		PYTHONDONTWRITEBYTECODE=1 python3 $(ROOT)scripts/check_merged_manifest.py; \
	else \
		echo "Android SDK not configured; merged manifest check skipped."; \
	fi

verify: lint test manifest

check: verify
