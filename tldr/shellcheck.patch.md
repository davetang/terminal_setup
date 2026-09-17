- terminal-setup extras (davetang/terminal-setup):

- Lint every shell script in the tree:

`fd -e sh -x shellcheck`

- Follow `source`d files instead of skipping them:

`shellcheck -x {{path/to/script.sh}}`

- Floor the severity (error > warning > info > style):

`shellcheck -S {{warning}} {{path/to/script.sh}}`

- Findings as a table, via this setup's jq:

`shellcheck -f json {{path/to/script.sh}} | jq -r '.[] | [.line,.code,.message] | @tsv'`

- Silence one check for a single run:

`shellcheck -e {{SC2086}} {{path/to/script.sh}}`
