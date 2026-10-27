"""Check bootstrap detection with isolated PATHs and a local fake installer."""

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class MiniforgeTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory(prefix="miniforge-test-")
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)
        self.commands = self.root / "commands"
        self.commands.mkdir()
        for command in ("bash", "dirname", "mktemp", "rm", "mkdir", "awk",
                        "uname", "cp", "chmod", "tar", "gzip"):
            executable = shutil.which(command)
            self.assertIsNotNone(executable, command)
            (self.commands / command).symlink_to(executable)
        (self.commands / "python3").symlink_to(sys.executable)
        self.download = self.root / "downloaded"
        self.calls = self.root / "conda-calls"
        self.conda = self.root / "fake-conda"
        self.write_script(self.conda, 'printf "%s\\n" "$*" >> "$TEST_CALLS"\n')
        self.installer = self.root / "fake-installer.sh"
        self.write_script(self.installer, '''
[[ "$1" == -b && "$2" == -p ]] || exit 1
mkdir -p "$3/bin"
cp "$TEST_CONDA" "$3/bin/conda"
''')
        self.write_script(self.commands / "curl", '''
while (( $# )); do
  if [[ "$1" == -o ]]; then
    cp "$TEST_INSTALLER" "$2"
    printf 'downloaded\\n' > "$TEST_DOWNLOAD"
    exit 0
  fi
  shift
done
exit 1
''')
        # Detection should never execute Mamba or mistake it for Conda.
        self.write_script(self.commands / "mamba", 'exit 99\n')
        lock = self.root / "versions.lock"
        lock.write_text("tmux\tconda\t1.2.3\n")
        self.env = {
            "HOME": str(self.root), "PATH": str(self.commands), "FORCE": "1",
            "BIN": str(self.root / "bin"), "LOCKFILE": str(lock),
            "TEST_CONDA": str(self.conda), "TEST_INSTALLER": str(self.installer),
            "TEST_DOWNLOAD": str(self.download), "TEST_CALLS": str(self.calls),
        }

    @staticmethod
    def write_script(path, body):
        path.write_text("#!/usr/bin/env bash\n" + body)
        path.chmod(0o755)

    def run_script(self, script):
        result = subprocess.run(
            [str(self.commands / "bash"), str(ROOT / script)],
            env=self.env, capture_output=True, text=True, timeout=10,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def test_mamba_only_bootstraps_and_installs(self):
        self.run_script("scripts/tmux.sh")
        self.assertTrue(self.download.exists())
        self.assertTrue((self.root / "miniforge3/bin/conda").is_file())
        self.assertIn("install -y -n base -c conda-forge tmux=1.2.3", self.calls.read_text())

    def test_mamba_only_preflight_reports_bootstrap_without_installing(self):
        result = self.run_script("deps.sh")
        self.assertIn("will bootstrap Miniforge", result.stderr)
        self.assertNotIn("conda available", result.stdout)
        self.assertFalse(self.download.exists())

    def test_existing_conda_is_reused(self):
        for location in (self.commands / "conda", self.root / "miniforge3/bin/conda"):
            with self.subTest(location=location):
                location.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(self.conda, location)
                self.run_script("scripts/miniforge.sh")
                self.run_script("scripts/tmux.sh")
                result = self.run_script("deps.sh")
                self.assertIn("conda available", result.stdout)
                self.assertFalse(self.download.exists())
                self.assertTrue(self.calls.exists())
                location.unlink()
                self.calls.unlink()


if __name__ == "__main__":
    unittest.main()
