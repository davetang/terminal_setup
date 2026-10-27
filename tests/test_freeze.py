"""Offline checks that failed release lookups cannot discard version pins."""

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
FAKE_CURL = r'''
import json, os, sys

url = sys.argv[-1]
match = os.environ.get("TEST_FAIL_MATCH", "")
failed = match and (match == "all" or match in url)
mode = os.environ.get("TEST_FAIL_MODE", "error")
if failed and mode != "body":
    raise SystemExit(0 if mode == "empty" else 22)
if "/commits/HEAD" in url:
    response = {"sha": "b" * 40}
elif "/releases/latest" in url:
    response = {"tag_name": "v9.9.9"}
elif "api.anaconda.org" in url:
    response = {"latest_version": "9.9.9"}
elif "pypi.org" in url:
    response = {"info": {"version": "9.9.9"}}
elif "ftp.gnu.org" in url:
    print("screen-9.9.9.tar.gz")
    raise SystemExit(22 if failed else 0)
elif "go.dev" in url:
    response = [{"version": "go9.9.9", "stable": True}]
elif "api.adoptium.net" in url:
    response = {"most_recent_lts": 25}
else:
    raise SystemExit("Unexpected URL: " + url)
print(json.dumps(response))
raise SystemExit(22 if failed else 0)
'''


class FreezeTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory(prefix="freeze-test-")
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)
        commands = self.root / "commands"
        commands.mkdir()
        curl = commands / "curl"
        curl.write_text("#!" + sys.executable + "\n" + FAKE_CURL)
        curl.chmod(0o755)
        self.lock = self.root / "versions.lock"
        self.original = (ROOT / "versions.lock").read_text()
        self.env = {
            "HOME": str(self.root), "PATH": str(commands) + ":/usr/bin:/bin",
            "LOCKFILE": str(self.lock),
        }

    def freeze(self, fail="", mode="error"):
        return subprocess.run(
            [shutil.which("bash"), str(ROOT / "scripts/freeze.sh")],
            env=dict(self.env, TEST_FAIL_MATCH=fail, TEST_FAIL_MODE=mode),
            capture_output=True, text=True, timeout=30,
        )

    def assert_failure(self, result, original):
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("no lockfile changes written", result.stderr)
        if original is None:
            self.assertFalse(self.lock.exists())
        else:
            self.assertEqual(self.lock.read_text(), original)

    def test_offline_preserves_existing_lock(self):
        self.lock.write_text(self.original)
        self.assert_failure(self.freeze("all"), self.original)

    def test_offline_does_not_create_incomplete_lock(self):
        self.assert_failure(self.freeze("all"), None)

    def test_each_failed_source_prevents_partial_update(self):
        for endpoint in ("/repos/sharkdp/bat/", "/repos/ollama/ollama/",
                         "/repos/r-lib/rig/", "/commits/HEAD", "api.anaconda.org",
                         "pypi.org", "ftp.gnu.org", "go.dev", "api.adoptium.net"):
            with self.subTest(endpoint=endpoint):
                # Without a JDK feature pin, Adoptium must also be resolved.
                original = "\n".join(line for line in self.original.splitlines()
                                     if not line.startswith("openjdk\t")) + "\n"
                self.lock.write_text(original)
                self.assert_failure(self.freeze(endpoint), original)

    def test_failed_response_with_body_is_not_used(self):
        self.lock.write_text(self.original)
        self.assert_failure(self.freeze("/repos/sharkdp/bat/", "body"), self.original)

    def test_empty_response_is_not_used(self):
        self.lock.write_text(self.original)
        self.assert_failure(self.freeze("/repos/sharkdp/bat/", "empty"), self.original)

    def test_success_refreshes_pins_and_preserves_jdk_choice(self):
        self.lock.write_text(self.original)
        result = self.freeze()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        expected = {"gh": "v9.9.9", "git": "b" * 40, "conda": "9.9.9",
                    "pip": "9.9.9", "gnu": "9.9.9", "go": "go9.9.9"}
        rows = [line.split("\t") for line in self.lock.read_text().splitlines()
                if line and not line.startswith("#")]
        old_rows = [line.split("\t") for line in self.original.splitlines()
                    if line and not line.startswith("#")]
        self.assertEqual({(n, c) for n, c, v in rows}, {(n, c) for n, c, v in old_rows})
        for name, channel, version in rows:
            if channel == "adoptium":
                self.assertIn([name, channel, version], old_rows)
            else:
                self.assertEqual(version, expected[channel], name)

    def test_success_can_create_complete_lock(self):
        result = self.freeze()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        contents = self.lock.read_text()
        self.assertIn("openjdk\tadoptium\t25\n", contents)
        self.assertIn("bat\tgh\tv9.9.9\n", contents)


if __name__ == "__main__":
    unittest.main()
