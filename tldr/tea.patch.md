- terminal-setup extras (davetang/terminal-setup):

- Log in once per server; tea is multi-server, and -l picks one later:

`tea logins add -n {{work}} -u {{https://git.example.org}} -t {{token}}`

- The token is stored in plain text, so lock the file down:

`chmod 600 {{~/.config/tea/config.yml}}`

- Issues as TSV, explored in visidata:

`tea issues ls -o tsv --state all | vd -f tsv`

- Pick your own columns:

`tea pr ls -f {{index,title,ci}} -o table`

- Any endpoint the CLI does not wrap:

`tea api /repos/{owner}/{repo}/issues | jq -r '.[].title'`

- Also act as a git credential helper for HTTPS:

`tea logins add --git-credentials`
