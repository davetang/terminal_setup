"""Run with: python3 -m unittest discover -s tests -v.

Exercise the visidata and llm installers against a fake pipx, pip3 and Conda.
A broken pipx must stop the install with a fix hint instead of a traceback,
and must not fall through to pip or Conda. No packages are downloaded.
"""

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
# The launcher pip writes for pipx, after a Python upgrade strands the package.
BROKEN_PIPX = r'''
import sys
sys.stderr.write("ModuleNotFoundError: No module named 'pipx'\n")
raise SystemExit(1)
'''
WORKING_PIPX = r'''
import os
from pathlib import Path
import sys

if sys.argv[1:] == ["--version"]:
    print("1.7.1")
else:
    with open(Path(os.environ["HOME"]) / "pipx-calls", "a") as calls:
        calls.write(" ".join(sys.argv[1:]) + "\n")
'''
# pip3 and conda record that they ran, so a fall-through is visible.
RECORDER = r'''
import os
from pathlib import Path
import sys

with open(Path(os.environ["HOME"]) / "fallback-calls", "a") as calls:
    calls.write(Path(sys.argv[0]).name + " " + " ".join(sys.argv[1:]) + "\n")
'''


class PipxTests(unittest.TestCase):
    def test_broken_pipx_stops_with_hint(self):
        for script in ("visidata", "llm"):
            with self.subTest(script=script):
                result, home = self.run_installer(script, BROKEN_PIPX)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn("doesn't run", result.stderr)
                self.assertIn("uv tool install --force pipx", result.stderr)
                self.assertNotIn("ModuleNotFoundError", result.stderr)
                self.assertFalse((home / "fallback-calls").exists(),
                                 "Fell through to pip/conda")

    def test_working_pipx_installs_pin(self):
        for script in ("visidata", "llm"):
            with self.subTest(script=script):
                result, home = self.run_installer(script, WORKING_PIPX)
                self.assertEqual(result.returncode, 0,
                                 result.stdout + result.stderr)
                self.assertEqual((home / "pipx-calls").read_text(),
                                 f"install --force {script}==1.2.3\n")
                self.assertFalse((home / "fallback-calls").exists())

    def test_deps_warns_about_broken_pipx(self):
        result, _ = self.run_installer("deps", BROKEN_PIPX)
        self.assertIn("doesn't run", result.stderr)
        self.assertNotIn("pip/pipx available", result.stdout)

    def run_installer(self, script, pipx_source):
        tmp = tempfile.TemporaryDirectory(prefix="pipx-test-")
        self.addCleanup(tmp.cleanup)
        home = Path(tmp.name)
        commands = home / "commands with spaces"
        commands.mkdir()
        for command in ("bash", "dirname", "mktemp", "rm", "mkdir", "awk"):
            executable = shutil.which(command)
            self.assertIsNotNone(executable, command)
            (commands / command).symlink_to(executable)
        (commands / "python3").symlink_to(sys.executable)
        for name, source in (("pipx", pipx_source), ("pip3", RECORDER),
                             ("conda", RECORDER)):
            fake = commands / name
            fake.write_text("#!" + sys.executable + "\n" + source)
            fake.chmod(0o755)
        lock = home / "versions.lock"
        lock.write_text(f"{script}\tpip\t1.2.3\n")
        path = ROOT / ("deps.sh" if script == "deps"
                       else f"scripts/{script}.sh")
        result = subprocess.run(
            [str(commands / "bash"), str(path)],
            env={"HOME": str(home), "PATH": str(commands), "FORCE": "1",
                 "BIN": str(home / "bin"), "LOCKFILE": str(lock)},
            capture_output=True, text=True, timeout=10,
        )
        return result, home


if __name__ == "__main__":
    unittest.main()
