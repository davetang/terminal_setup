# ttyper

> Terminal-based typing test whose results screen breaks accuracy down per key.
> Languages are embedded in the binary; config lives under ~/.config/ttyper.
> More information: <https://github.com/max-niederman/ttyper>.

- Start a test in the default language (english200):

`ttyper`

- A longer test:

`ttyper -w {{100}}`

- Use a bigger or different word list:

`ttyper -l {{english1000}}`

- List every built-in language, programming languages included:

`ttyper --list-languages`

- Type a file, or "-" to read stdin:

`ttyper {{path/to/notes.md}}`

- Use your own word list without installing it as a language:

`ttyper --language-file {{~/weak.txt}}`

- Harder modes: no returning to a finished word, and restart on any mistake:

`ttyper --no-backtrack --sudden-death`

- Set the default language and colours:

`vi {{~/.config/ttyper/config.toml}}`
