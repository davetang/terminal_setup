- terminal-setup extras (davetang/terminal-setup):

- Run a tool over every match ({} is the file, {.} drops the extension):

`fd -e {{md}} -x pandoc {} -o {.}.pdf`

- Summarise every gzipped FASTQ found:

`fd '\.fq\.gz$' -x seqkit stats`

- Feed the fuzzy finder, with syntax-highlighted previews:

`fd -t f | fzf --preview 'bat --color=always {}'`

- Make it fzf's default source (add to your shell rc):

`export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'`
