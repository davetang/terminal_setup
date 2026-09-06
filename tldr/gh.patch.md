- terminal-setup extras (davetang/terminal-setup):

- Reuse gh's login for this repo's installer, raising the GitHub API rate limit:

`export GITHUB_TOKEN=$(gh auth token)`

- Make gh the git credential helper for HTTPS clone and push:

`gh auth setup-git`

- Open issue and PR bodies in vi:

`gh config set editor vi`

- Open a PR with title and body taken from the commits:

`gh pr create --fill`

- Follow a workflow run until it finishes:

`gh run watch`

- Issues as an aligned table, via this setup's CSV tools:

`gh issue list --json number,title | jq -r '.[] | [.number,.title] | @tsv' | csvtk pretty -t -H`

- Anything the CLI does not wrap ({owner} and {repo} expand inside a clone):

`gh api --paginate {{/user/repos}} --jq '.[].full_name'`
