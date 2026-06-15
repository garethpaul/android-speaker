import tempfile
import unittest
from pathlib import Path

from check_merged_manifest import validate_manifest


MANIFEST = """\
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="garethpaul.com.androidspeaker">
    <uses-sdk android:minSdkVersion="21" android:targetSdkVersion="22" />
    <application android:allowBackup="false">
        <activity android:name="garethpaul.com.androidspeaker.MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
"""


class MergedManifestTest(unittest.TestCase):
    def validate(self, contents):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "AndroidManifest.xml"
            path.write_text(contents, encoding="utf-8")
            validate_manifest(path)

    def test_accepts_expected_manifest(self):
        self.validate(MANIFEST)

    def test_rejects_package_change(self):
        with self.assertRaisesRegex(ValueError, "package changed"):
            self.validate(MANIFEST.replace("garethpaul.com.androidspeaker", "example.app", 1))

    def test_rejects_sdk_change(self):
        with self.assertRaisesRegex(ValueError, "target SDK changed"):
            self.validate(MANIFEST.replace('targetSdkVersion="22"', 'targetSdkVersion="23"'))

    def test_rejects_backup_enablement(self):
        with self.assertRaisesRegex(ValueError, "disable app-data backup"):
            self.validate(MANIFEST.replace('allowBackup="false"', 'allowBackup="true"'))

    def test_rejects_internet_permission(self):
        permission = '<uses-permission android:name="android.permission.INTERNET" />\n    '
        with self.assertRaisesRegex(ValueError, "must not request INTERNET"):
            self.validate(MANIFEST.replace("<uses-sdk", permission + "<uses-sdk"))

    def test_rejects_launcher_change(self):
        with self.assertRaisesRegex(ValueError, "launcher intent filter changed"):
            self.validate(MANIFEST.replace("android.intent.action.MAIN", "android.intent.action.VIEW"))

    def test_rejects_missing_launcher_export(self):
        with self.assertRaisesRegex(ValueError, "exactly one exported activity"):
            self.validate(MANIFEST.replace(' android:exported="true"', ""))

    def test_rejects_false_launcher_export(self):
        with self.assertRaisesRegex(ValueError, "exactly one exported activity"):
            self.validate(MANIFEST.replace('android:exported="true"', 'android:exported="false"'))

    def test_rejects_unrelated_export(self):
        contents = MANIFEST.replace(' android:exported="true"', "")
        contents = contents.replace(
            "    </application>",
            '        <activity android:name="example.Other" android:exported="true" />\n'
            "    </application>",
        )
        with self.assertRaisesRegex(ValueError, "launcher activity must be explicitly exported"):
            self.validate(contents)


if __name__ == "__main__":
    unittest.main()
