"""Run with: python3 -m unittest discover -s tests -v.

Exercise scripts/ollama.sh against a fake curl that serves the release as a
plain tar (a pass-through zstd stands in for the decompressor). A download cut
off part-way through bin/ollama must not replace a working ollama, nor touch
its install record. No packages are downloaded.
"""

import io
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
URL = ("https://github.com/ollama/ollama/releases/download/v0.1.0/"
       "ollama-linux-amd64.tar.zst")
# Padded so a cut-off download can end inside it, as the real 39 MB one would.
PAYLOAD = (b"#!/bin/sh\necho 'client version is 0.1.0'\nexit 0\n# "
           + b"x" * 300_000 + b"\n")
OLD_BINARY = b"#!/bin/sh\necho 'client version is 0.0.9'\n"
OLD_RECORD = "ollama\tgh\tv0.0.9\n"
# The API call gets the release JSON; the download gets $TEST_TARBALL, cut to
# $TEST_BYTES bytes and failing the way curl does mid-transfer when it's set.
FAKE_CURL = r'''#!/bin/sh
for a; do url=$a; done
case $url in
  https://api.github.com/*)
    printf '{"browser_download_url": "%s"}\n' "$TEST_URL" ;;
  *)
    if [ -n "${TEST_BYTES:-}" ]; then
      head -c "$TEST_BYTES" "$TEST_TARBALL"; exit 18
    fi
    cat "$TEST_TARBALL" ;;
esac
'''


def bundle():
    data = io.BytesIO()
    with tarfile.open(fileobj=data, mode="w") as archive:
        for name, content in (("bin/ollama", PAYLOAD),
                              ("lib/ollama/runner", b"\0" * 100_000)):
            member = tarfile.TarInfo(name)
            member.size = len(content)
            member.mode = 0o755
            archive.addfile(member, io.BytesIO(content))
    return data.getvalue()


class OllamaTests(unittest.TestCase):
    def test_complete_download_installs(self):
        result, binary, record = self.run_installer(None)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(binary.read_bytes(), PAYLOAD)
        self.assertIn("ollama\tgh\tv0.1.0\n", record.read_text())

    def test_cut_off_download_keeps_existing(self):
        for size in (150_000, 0):
            with self.subTest(bytes=size):
                result, binary, record = self.run_installer(size)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn("nothing was installed", result.stderr)
                self.assertEqual(binary.read_bytes(), OLD_BINARY)
                self.assertEqual(record.read_text(), OLD_RECORD)

    def run_installer(self, cut_at):
        tmp = tempfile.TemporaryDirectory(prefix="ollama-test-")
        self.addCleanup(tmp.cleanup)
        home = Path(tmp.name)
        commands, bindir = home / "commands with spaces", home / "bin"
        for directory in (commands, bindir):
            directory.mkdir()
        for path, source in ((commands / "curl", FAKE_CURL),
                             (bindir / "zstd", "#!/bin/sh\nexec cat\n")):
            path.write_text(source)
            path.chmod(0o755)
        binary, record = bindir / "ollama", bindir / ".installed.lock"
        binary.write_bytes(OLD_BINARY)
        binary.chmod(0o755)
        record.write_text(OLD_RECORD)
        tarball = home / "bundle.tar"
        tarball.write_bytes(bundle())
        lock = home / "versions.lock"
        lock.write_text("ollama\tgh\tv0.1.0\n")
        env = {"HOME": str(home), "PATH": f"{commands}:/usr/bin:/bin",
               "BIN": str(bindir), "FORCE": "1", "LOCKFILE": str(lock),
               "TEST_URL": URL, "TEST_TARBALL": str(tarball)}
        if cut_at is not None:
            env["TEST_BYTES"] = str(cut_at)
        result = subprocess.run(
            [shutil.which("bash"), str(ROOT / "scripts" / "ollama.sh")],
            env=env, capture_output=True, text=True, timeout=20,
        )
        return result, binary, record


if __name__ == "__main__":
    unittest.main()
