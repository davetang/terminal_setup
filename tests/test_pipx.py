"""Run with: python3 -m unittest discover -s tests -v.

Exercise the visidata and llm installers against fake pipx, uv, pip3 and
Conda commands. The installers try pipx, then uv, then pip, then Conda; a
broken pipx must stop the install with a fix hint instead of a traceback, and
must not fall through. No packages are downloaded.
"""

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
# The launcher pip writes for pipx, after a Python upgrade strands the package.
BROKEN = r'''
import sys
sys.stderr.write("ModuleNotFoundError: No module named 'pipx'\n")
raise SystemExit(1)
'''
# Every working fake records "<name> <args>" in $HOME/calls. 'pipx --version'
# is how the installers check that pipx runs, so it isn't recorded.
FAKE = r'''
import os
from pathlib import Path
import sys

if sys.argv[1:] == ["--version"]:
    print("1.7.1")
else:
    with open(Path(os.environ["HOME"]) / "calls", "a") as calls:
        calls.write(" ".join([Path(sys.argv[0]).name] + sys.argv[1:]) + "\n")
'''
FALLBACKS = {"uv": FAKE, "pip3": FAKE, "conda": FAKE}


class PipxTests(unittest.TestCase):
    def test_broken_pipx_stops_with_hint(self):
        for script in ("visidata", "llm"):
            with self.subTest(script=script):
                result, home = self.run_installer(
                    script, {"pipx": BROKEN, **FALLBACKS})
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn("doesn't run", result.stderr)
                self.assertIn("uv tool install --force pipx", result.stderr)
                self.assertNotIn("ModuleNotFoundError", result.stderr)
                self.assertFalse((home / "calls").exists(),
                                 "Fell through to uv/pip/conda")

    def test_working_pipx_comes_first(self):
        self.check_calls({"pipx": FAKE, **FALLBACKS}, {},
                         "pipx install --force {}==1.2.3\n")

    def test_uv_without_pipx(self):
        self.check_calls(FALLBACKS, {},
                         "uv tool install --force {}==1.2.3\n")

    def test_uv_in_bin_before_it_is_on_path(self):
        self.check_calls({"pip3": FAKE, "conda": FAKE}, {"uv": FAKE},
                         "uv tool install --force {}==1.2.3\n")

    def test_deps_warns_about_broken_pipx(self):
        result, _ = self.run_installer("deps", {"pipx": BROKEN, **FALLBACKS})
        self.assertIn("doesn't run", result.stderr)
        self.assertNotIn("available (for visidata and llm)", result.stdout)

    def check_calls(self, path_fakes, bin_fakes, expected):
        for script in ("visidata", "llm"):
            with self.subTest(script=script):
                result, home = self.run_installer(script, path_fakes, bin_fakes)
                self.assertEqual(result.returncode, 0,
                                 result.stdout + result.stderr)
                self.assertEqual((home / "calls").read_text(),
                                 expected.format(script))

    def run_installer(self, script, path_fakes, bin_fakes=None):
        tmp = tempfile.TemporaryDirectory(prefix="pipx-test-")
        self.addCleanup(tmp.cleanup)
        home = Path(tmp.name)
        commands, bin_dir = home / "commands with spaces", home / "bin"
        for directory in (commands, bin_dir):
            directory.mkdir()
        for command in ("bash", "dirname", "mktemp", "rm", "mkdir", "awk"):
            executable = shutil.which(command)
            self.assertIsNotNone(executable, command)
            (commands / command).symlink_to(executable)
        (commands / "python3").symlink_to(sys.executable)
        for directory, fakes in ((commands, path_fakes),
                                 (bin_dir, bin_fakes or {})):
            for name, source in fakes.items():
                fake = directory / name
                fake.write_text("#!" + sys.executable + "\n" + source)
                fake.chmod(0o755)
        lock = home / "versions.lock"
        lock.write_text(f"{script}\tpip\t1.2.3\n")
        path = ROOT / ("deps.sh" if script == "deps"
                       else f"scripts/{script}.sh")
        result = subprocess.run(
            [str(commands / "bash"), str(path)],
            env={"HOME": str(home), "PATH": str(commands), "FORCE": "1",
                 "BIN": str(bin_dir), "LOCKFILE": str(lock)},
            capture_output=True, text=True, timeout=10,
        )
        return result, home


if __name__ == "__main__":
    unittest.main()
