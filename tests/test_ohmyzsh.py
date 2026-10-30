"""Run with: python3 -m unittest discover -s tests -v.

Exercise scripts/ohmyzsh.sh against a fake curl that serves a stand-in for
upstream's install.sh. Like the real one with KEEP_ZSHRC=yes, it keeps an
existing ~/.zshrc and otherwise writes one from its template. Nothing is cloned
or downloaded.

zsh only gets ~/bin and the tool hooks from the terminal-setup block, so
whichever way ~/.zshrc ends up, a missing block must be reported.
"""

from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
TS_BLOCK = ("# >>> terminal-setup >>>\n"
            "[ -f /x/shell/init.sh ] && source /x/shell/init.sh\n"
            "# <<< terminal-setup <<<\n")
OMZ_BEGIN = "# >>> oh-my-zsh >>>"
WARNING = "has no terminal-setup block"
FAKE_INSTALLER = r'''#!/bin/sh
mkdir -p "$ZSH" && echo '# oh-my-zsh' > "$ZSH/oh-my-zsh.sh"
if [ -f "$HOME/.zshrc" ] && [ "$KEEP_ZSHRC" = yes ]; then exit 0; fi
printf 'export ZSH="%s"\nZSH_THEME="robbyrussell"\nsource $ZSH/oh-my-zsh.sh\n' \
  "$ZSH" > "$HOME/.zshrc"
'''
# fetch() runs curl -fL ... -o <file> <url>; hand over the fake installer.
FAKE_CURL = r'''#!/bin/sh
while [ $# -gt 0 ]; do
  case $1 in -o) out=$2; shift ;; esac
  shift
done
cp "$TEST_INSTALLER" "$out"
'''


class OhMyZshTests(unittest.TestCase):
    def test_no_zshrc_warns_after_template(self):
        # The README's order: make setup skipped the missing ~/.zshrc, then
        # make zsh, then make ohmyzsh, whose installer writes ~/.zshrc.
        result, zshrc = self.run_installer(zshrc=None)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("oh-my-zsh.sh", zshrc.read_text())
        self.assertIn(WARNING, result.stderr)

    def test_block_goes_above_terminal_setup(self):
        result, zshrc = self.run_installer(zshrc="# mine\n\n" + TS_BLOCK)
        self.assertEqual(result.returncode, 0, result.stderr)
        text = zshrc.read_text()
        self.assertLess(text.index(OMZ_BEGIN), text.index(TS_BLOCK))
        self.assertNotIn(WARNING, result.stderr)

    def test_own_zshrc_without_block_warns(self):
        result, zshrc = self.run_installer(zshrc="# mine\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(OMZ_BEGIN, zshrc.read_text())
        self.assertIn(WARNING, result.stderr)

    def test_existing_clone_without_zshrc(self):
        result, zshrc = self.run_installer(zshrc=None, cloned=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(OMZ_BEGIN, zshrc.read_text())
        self.assertIn(WARNING, result.stderr)

    def run_installer(self, zshrc, cloned=False):
        tmp = tempfile.TemporaryDirectory(prefix="ohmyzsh-test-")
        self.addCleanup(tmp.cleanup)
        home = Path(tmp.name)
        commands = home / "commands with spaces"
        commands.mkdir()
        for name, source in (("curl", FAKE_CURL), ("git", "#!/bin/sh\n"),
                             ("zsh", "#!/bin/sh\n")):
            (commands / name).write_text(source)
            (commands / name).chmod(0o755)
        installer = home / "fake-install.sh"
        installer.write_text(FAKE_INSTALLER)
        if cloned:
            (home / ".oh-my-zsh").mkdir()
            (home / ".oh-my-zsh" / "oh-my-zsh.sh").write_text("# oh-my-zsh\n")
        path = home / ".zshrc"
        if zshrc is not None:
            path.write_text(zshrc)
        result = subprocess.run(
            [shutil.which("bash"), str(ROOT / "scripts" / "ohmyzsh.sh")],
            env={"HOME": str(home), "PATH": f"{commands}:/usr/bin:/bin",
                 "BIN": str(home / "bin"), "TEST_INSTALLER": str(installer)},
            capture_output=True, text=True, timeout=10,
        )
        return result, path


if __name__ == "__main__":
    unittest.main()
