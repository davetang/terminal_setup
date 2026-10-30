"""Run with: python3 -m unittest discover -s tests -v.

Exercise the release-API lookup against a fake curl. A GitHub token must reach
GitHub as an Authorization header and nowhere else, and no token must mean no
header. Bash before 4.4 dies "unbound variable" on an empty array under set -u,
which the tokenless case hits; this test catches that when the bash on PATH is
that old (RHEL 7's 4.2), and checks the arguments everywhere else.
"""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
ASSET = ("https://github.com/o/r/releases/download/v1.0/"
         "tool-v1.0-x86_64-unknown-linux-musl.tar.gz")
# Records its arguments, one call per line, NUL-separated; answers with one
# release asset in the JSON shape GitHub and Gitea share.
FAKE_CURL = r'''#!/bin/sh
printf '%s\0' "$@" >> "$HOME/curl-args"
printf '\n' >> "$HOME/curl-args"
printf '{"assets": [{"browser_download_url": "%s"}]}\n' "$TEST_ASSET"
'''
# Called the way install_binary calls it: forge_asset's '| head -1' can SIGPIPE
# its feeder, so its status is not the verdict, the URL it prints is.
LOOKUP = ('source "$1/lib.sh"; '
          'url="$(forge_asset "$2" "tool-.*musl\\.tar\\.gz$" v1.0)" || true; '
          'printf "%s\\n" "$url"')


class ForgeApiTests(unittest.TestCase):
    def test_no_token_sends_no_header(self):
        args = self.lookup("o/r", token=None)
        self.assertNotIn("-H", args)
        self.assertEqual(args[-1],
                         "https://api.github.com/repos/o/r/releases/tags/v1.0")

    def test_token_goes_to_github(self):
        args = self.lookup("o/r", token="secret")
        self.assertIn("Authorization: Bearer secret", args)

    def test_token_stays_off_other_forges(self):
        args = self.lookup("gitea.com/o/r", token="secret")
        self.assertNotIn("-H", args)
        self.assertEqual(args[-1],
                         "https://gitea.com/api/v1/repos/o/r/releases/tags/v1.0")

    def lookup(self, repo, token):
        with tempfile.TemporaryDirectory(prefix="forge-api-test-") as tmp:
            home = Path(tmp)
            commands = home / "commands with spaces"
            commands.mkdir()
            curl = commands / "curl"
            curl.write_text(FAKE_CURL)
            curl.chmod(0o755)
            env = {"HOME": str(home), "PATH": f"{commands}:/usr/bin:/bin",
                   "BIN": str(home / "bin"), "TEST_ASSET": ASSET}
            if token is not None:
                env["GITHUB_TOKEN"] = token
            result = subprocess.run(
                [shutil.which("bash"), "-c", LOOKUP, "test", str(ROOT), repo],
                env=env, capture_output=True, text=True, timeout=10,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn("unbound variable", result.stderr)
            self.assertEqual(result.stdout.strip(), ASSET)
            calls = (home / "curl-args").read_text().splitlines()
            self.assertEqual(len(calls), 1, calls)
            return calls[0].split("\0")[:-1]


if __name__ == "__main__":
    unittest.main()
