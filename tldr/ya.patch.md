- terminal-setup extras (davetang/terminal-setup):

- yazi and ya come from the same release in this setup, so they always match:

`ya --version`

- Add a plugin:

`ya pkg add {{yazi-rs/plugins:full-border}}`

- Bring plugins back in step after `FORCE=1 make yazi`:

`ya pkg upgrade`
