# tldr custom pages

Per-tool examples for [tealdeer](https://github.com/tealdeer-rs/tealdeer), the
`tldr` client this repo installs. Same material as
[`cheatsheet.md`](../cheatsheet.md), but delivered where you actually reach for
it: `tldr <tool>`.

One file per tool in this repo's set — 60 of them, matching `make check`.

## Does the name need `.patch`? Yes, and it changes the behaviour

Not decoration. tealdeer's lookup (`src/cache.rs`, `Cache::find_page`) treats the
two suffixes differently:

| File | What tealdeer does |
|------|--------------------|
| `<command>.page.md` | returned **instead of** the upstream page, and any `.patch.md` for that command is ignored |
| `<command>.patch.md` | **appended to** the upstream page — and only if one is found in the cache |

The last clause is the catch: a patch is not a page. `find_page` looks the patch
path up first but attaches it while searching the cached platform directories,
so if no upstream page exists the function returns `None` and `tldr <command>`
prints *page not found* — the patch is never shown. So the suffix has to follow
what upstream publishes:

- **51 tools have an upstream page** → `<command>.patch.md`, holding only the
  extra examples this setup adds (the marker line `- terminal-setup extras`
  shows where upstream ends).
- **9 have none to attach to** → `<command>.page.md`, a complete page: `csvtk`,
  `seqkit`, `viddy`, `ttyper`, `sendcb`, `notify`, `vd`, `gls`, `rig`.

Checked against tldr-pages, not assumed: `csvtk`, `seqkit`, `viddy`, `ttyper`,
`sendcb` and `notify` have no page at all, and visidata is published under
neither `vd` nor `visidata`. Re-check with `tldr <command>` after a `tldr --update`.

`gls` is the eighth for a different reason: upstream *does* publish it, but only
under the `osx` platform, because g-prefixed coreutils are normally a macOS
thing. On Linux that page is not in the platform directories tealdeer searches,
so a patch would have nothing to attach to — hence a full page. It stands in
for the whole g-prefixed set `make coreutils` installs, not just `gls`.

`rig` is the ninth for a third reason: upstream's `linux/rig` page is for a
different program, a random name and address generator (Debian's `rig`
package). A patch would append R examples to that tool's page; a full page
replaces it, which is what `tldr rig` should show once `make rig` has installed
the R one.

Two other quirks worth knowing:

- `tldr just` is upstream's **disambiguation** page (the command runner is
  `tldr just.1`), so `just.patch.md` appends to that short page rather than to
  the runner's.
- The suffixes changed in tealdeer 1.7.0 (`.page` → `.page.md`, `.patch` →
  `.patch.md`). These files use the current form; this repo installs a much
  newer tealdeer.

## Installing them

```sh
make tldr-pages                            # or: ./run.sh tldr-pages
```

It installs tealdeer first if it's missing (`make tldr`), then does what you'd
otherwise do by hand:

```sh
tldr --update                              # patches need a cached page to attach to
tldr --show-paths                          # confirm the "Custom pages dir:" line
mkdir -p ~/.local/share/tealdeer/pages
cp tldr/*.page.md tldr/*.patch.md ~/.local/share/tealdeer/pages/
```

`--show-paths` prints the directory tealdeer actually uses, followed by where
that came from — `/home/you/.local/share/tealdeer/pages (OS convention)` is the
Linux default. `[directories] custom_pages_dir` in
`~/.config/tealdeer/config.toml` overrides it; `make tldr-pages` copies to
whatever that line says.

It then checks every patch and warns about the two ways one can go unseen: no
upstream page in the cache for it to attach to, or a `<command>.page.md` in the
custom pages dir that replaces the upstream page and takes the patch with it.

Re-run it after a `git pull` to pick up edited pages. It overwrites only files
with the same names, so pages of your own are left alone, and a page this repo
drops stays in the custom pages dir until you delete it.

Then check one:

```sh
tldr ncdu      # upstream page, with this repo's examples appended
tldr csvtk     # a page that exists only here
```

## Editing

Format is ordinary tldr markdown, and tealdeer is strict about it: a line is a
title (`#`), a description (`>`), an example description (`-`), or a command —
which must both start *and* end with a backtick. **Anything else is silently
dropped**, so a stray comment line just disappears from the output. Commands are
one line each; `{{...}}` marks the parts to substitute.
