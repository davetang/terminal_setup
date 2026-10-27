"""Offline installer regression tests; run with unittest discovery."""

import bz2
import io
import lzma
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile
import unittest
import zipfile


ROOT = Path(__file__).resolve().parents[1]
PAYLOAD = b"#!/bin/sh\necho installed\n"
INSTALL = r'''
source "$1/lib.sh"
forge_asset() { printf 'https://example.invalid/%s\n' "${TEST_ASSET##*/}"; }
fetch() { cp "$TEST_ASSET" "$2"; }
# Exercise the Python ZIP fallback regardless of host unzip availability.
have() { [[ "$1" != unzip ]] && command -v "$1" >/dev/null 2>&1; }
install_binary bat
'''


def tar_bytes():
    data = io.BytesIO()
    with tarfile.open(fileobj=data, mode="w") as archive:
        member = tarfile.TarInfo("release/bat")
        member.size = len(PAYLOAD)
        member.mode = 0o755
        archive.addfile(member, io.BytesIO(PAYLOAD))
    return data.getvalue()


class BinaryExtractionTests(unittest.TestCase):
    def check_install(self, filename, content, succeeds, existing=True):
        with tempfile.TemporaryDirectory(prefix="binary-extraction-test-") as tmp:
            root = Path(tmp)
            asset = root / filename
            asset.write_bytes(content)
            bindir = root / "bin"
            bindir.mkdir()
            binary = bindir / "bat"
            record = bindir / ".installed.lock"
            old_binary = b"#!/bin/sh\necho original\n"
            old_record = "bat\tgh\tv0.1.0\n"
            if existing:
                binary.write_bytes(old_binary)
                binary.chmod(0o755)
                record.write_text(old_record)
            lock = root / "versions.lock"
            lock.write_text("bat\tgh\tv1.2.3\n")
            result = subprocess.run(
                [shutil.which("bash"), "-c", INSTALL, "test", str(ROOT)],
                env={
                    "HOME": str(root), "PATH": "/usr/bin:/bin",
                    "BIN": str(bindir), "FORCE": "1", "LOCKFILE": str(lock),
                    "TEST_ASSET": str(asset),
                },
                capture_output=True, text=True, timeout=10,
            )
            if succeeds:
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual(binary.read_bytes(), PAYLOAD)
                self.assertTrue(binary.stat().st_mode & 0o111)
                self.assertIn("bat\tgh\tv1.2.3\n", record.read_text())
            else:
                self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn("failed to extract", result.stderr)
                if existing:
                    self.assertEqual(binary.read_bytes(), old_binary)
                    self.assertEqual(record.read_text(), old_record)
                else:
                    self.assertFalse(binary.exists())
                    self.assertFalse(record.exists())

    def test_corrupt_archives_preserve_existing_install(self):
        for suffix in ("tar.gz", "tgz", "tar.bz2", "tbz", "tbz2",
                       "tar.xz", "txz", "tar", "zip"):
            with self.subTest(suffix=suffix):
                self.check_install("bat." + suffix, b"not an archive", succeeds=False)

    def test_corrupt_archive_does_not_create_install(self):
        self.check_install("bat.tar.gz", b"not an archive", succeeds=False, existing=False)

    def test_failed_tar_after_successful_decompression(self):
        for suffix, compress in (("tar.bz2", bz2.compress), ("tar.xz", lzma.compress)):
            with self.subTest(suffix=suffix):
                # tar extracts the executable, then fails on the trailing bad
                # header. Cleanup must not mask its error and allow installation.
                data = tar_bytes()[:1024] + b"x" * 1024
                self.check_install("bat." + suffix, compress(data), succeeds=False)

    def test_valid_archives(self):
        for suffix, mode in (("tar.gz", "w:gz"), ("tar.bz2", "w:bz2"),
                             ("tar.xz", "w:xz"), ("tar", "w")):
            with self.subTest(suffix=suffix):
                data = io.BytesIO()
                with tarfile.open(fileobj=data, mode=mode) as archive:
                    member = tarfile.TarInfo("release/bat")
                    member.size = len(PAYLOAD)
                    archive.addfile(member, io.BytesIO(PAYLOAD))
                self.check_install("bat." + suffix, data.getvalue(), succeeds=True)
        data = io.BytesIO()
        with zipfile.ZipFile(data, "w") as archive:
            archive.writestr("release/bat", PAYLOAD)
        self.check_install("bat.zip", data.getvalue(), succeeds=True)

    def test_raw_binary(self):
        self.check_install("bat-linux-amd64", PAYLOAD, succeeds=True)


if __name__ == "__main__":
    unittest.main()
