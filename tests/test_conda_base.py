"""Run with: python3 -m unittest discover -s tests -v.

Exercise the installers with a fake Conda that defaults to the active
environment, so accidental writes to a project environment are observable.
No packages are downloaded or installed.
"""

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
FAKE_CONDA = r'''
import os
from pathlib import Path
import sys

args = sys.argv[1:]
base = Path(os.environ["TEST_CONDA_BASE"])
target = Path(os.environ.get("CONDA_PREFIX", str(base)))
for flag in ("-n", "--name"):
    if flag in args:
        name = args[args.index(flag) + 1]
        target = base if name == "base" else base / "envs" / name
for flag in ("-p", "--prefix"):
    if flag in args:
        target = Path(args[args.index(flag) + 1])

if args[0] == "install":
    (target / "installed-spec").write_text(args[-1])
elif args[0] == "run" and args[-2] == "which":
    (target / "queried-command").write_text(args[-1])
    print(target / "bin" / args[-1])
else:
    raise SystemExit("Unexpected Conda invocation: " + repr(args))
'''


class CondaBaseTests(unittest.TestCase):
    def test_installers_use_base(self):
        for active in (False, True):
            for script, package in (("tmux", "tmux"),
                                    ("visidata", "visidata"), ("llm", "llm")):
                with self.subTest(script=script, active=active):
                    self.check_installer(script, package, active)

    def check_installer(self, script, package, active):
        with tempfile.TemporaryDirectory(prefix="conda-base-test-") as tmp:
            root = Path(tmp)
            base, project, commands = (root / "base", root / "project",
                                       root / "commands with spaces")
            for directory in (base, project, commands):
                directory.mkdir()
            # An allowlist excludes host pip/pipx and installed tools, ensuring
            # both Python installers take their Conda fallback paths.
            for command in ("bash", "dirname", "mktemp", "rm", "mkdir", "awk"):
                executable = shutil.which(command)
                self.assertIsNotNone(executable, command)
                (commands / command).symlink_to(executable)
            (commands / "python3").symlink_to(sys.executable)
            conda = commands / "conda"
            conda.write_text("#!" + sys.executable + "\n" + FAKE_CONDA)
            conda.chmod(0o755)
            lock = root / "versions.lock"
            channel = "conda" if package == "tmux" else "pip"
            lock.write_text(f"{package}\t{channel}\t1.2.3\n")
            env = {
                "HOME": str(root), "PATH": str(commands), "FORCE": "1",
                "BIN": str(root / "bin"), "LOCKFILE": str(lock),
                "TEST_CONDA_BASE": str(base),
            }
            if active:
                env.update(CONDA_PREFIX=str(project), CONDA_DEFAULT_ENV="project",
                           CONDA_SHLVL="1")
            result = subprocess.run(
                [str(commands / "bash"), str(ROOT / "scripts" / f"{script}.sh")],
                env=env, capture_output=True, text=True, timeout=10,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual((base / "installed-spec").read_text(), f"{package}=1.2.3")
            self.assertEqual(list(project.iterdir()), [], "Project environment changed")
            if package == "tmux":
                self.assertEqual((base / "queried-command").read_text(), "tmux")
                self.assertIn(str(base / "bin" / "tmux"), result.stdout)


if __name__ == "__main__":
    unittest.main()
