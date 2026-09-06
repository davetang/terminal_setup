- terminal-setup extras (davetang/terminal-setup):

- HTML to GitHub-flavoured Markdown:

`pandoc {{page.html}} -t gfm -o {{page.md}}`

- Standalone HTML with a table of contents:

`pandoc {{README.md}} -s --toc -o {{readme.html}}`

- Convert a directory of notes in parallel:

`fd -e md | parallel pandoc {} -o {.}.pdf`
