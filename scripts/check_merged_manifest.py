#!/usr/bin/env python3
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


ANDROID_NAMESPACE = "http://schemas.android.com/apk/res/android"
DEFAULT_MANIFEST = (
    Path(__file__).resolve().parents[1]
    / "app/build/intermediates/manifests/full/debug/AndroidManifest.xml"
)


def android_attribute(element, name):
    return element.get("{%s}%s" % (ANDROID_NAMESPACE, name))


def require(condition, message):
    if not condition:
        raise ValueError(message)


def validate_manifest(path):
    root = ET.parse(str(path)).getroot()
    require(
        root.get("package") == "garethpaul.com.androidspeaker",
        "merged manifest package changed",
    )

    uses_sdk = root.find("uses-sdk")
    require(uses_sdk is not None, "merged manifest is missing uses-sdk")
    require(android_attribute(uses_sdk, "minSdkVersion") == "21", "min SDK changed")
    require(android_attribute(uses_sdk, "targetSdkVersion") == "22", "target SDK changed")

    application = root.find("application")
    require(application is not None, "merged manifest is missing application")
    require(
        android_attribute(application, "allowBackup") == "false",
        "merged manifest must disable app-data backup",
    )

    for element in root:
        if element.tag.split("}")[-1].startswith("uses-permission"):
            require(
                android_attribute(element, "name") != "android.permission.INTERNET",
                "merged manifest must not request INTERNET",
            )

    launcher_activity = None
    for activity in application.findall("activity"):
        if android_attribute(activity, "name") == "garethpaul.com.androidspeaker.MainActivity":
            launcher_activity = activity
            break
    require(launcher_activity is not None, "launcher activity changed")

    for intent_filter in launcher_activity.findall("intent-filter"):
        actions = {
            android_attribute(action, "name")
            for action in intent_filter.findall("action")
        }
        categories = {
            android_attribute(category, "name")
            for category in intent_filter.findall("category")
        }
        if (
            "android.intent.action.MAIN" in actions
            and "android.intent.category.LAUNCHER" in categories
        ):
            return

    raise ValueError("launcher intent filter changed")


def main(argv):
    manifest = Path(argv[1]) if len(argv) > 1 else DEFAULT_MANIFEST
    try:
        validate_manifest(manifest)
    except (OSError, ET.ParseError, ValueError) as error:
        print("Merged manifest check failed: %s" % error, file=sys.stderr)
        return 1

    print("Merged manifest privacy checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
