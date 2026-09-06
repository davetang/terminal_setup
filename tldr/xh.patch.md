- terminal-setup extras (davetang/terminal-setup):

- Ask a forge API the question this repo's installer asks:

`xh {{https://api.github.com/repos/sharkdp/bat/releases/latest}} | jq -r '.tag_name'`

- Send a bearer token (the same one that raises `make install`'s rate limit):

`xh -A bearer -a "$GITHUB_TOKEN" {{https://api.github.com/rate_limit}}`

- Download a release asset into ~/bin:

`xh --download {{https://example.com/tool.tar.gz}} -o {{~/bin/tool}}`

- Print the equivalent curl command instead of sending anything:

`xh --curl --offline {{get}} {{https://example.com}}`
