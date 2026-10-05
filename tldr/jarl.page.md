# jarl

> Just Another R Linter: fast lints for R code, many with automatic fixes.
> Settings come from a jarl.toml found above the files checked.
> More information: <https://jarl.etiennebacher.com>.

- Lint every R file in a directory tree:

`jarl check {{path/to/directory}}`

- Apply the fixes jarl considers safe (refuses on uncommitted changes unless `--allow-dirty`):

`jarl check --fix {{path/to/directory}}`

- Also apply fixes that may change what the code means:

`jarl check --fix --unsafe-fixes {{path/to/directory}}`

- Check only some rules, or a group of them such as PERF:

`jarl check --select {{PERF,assignment}} {{path/to/directory}}`

- Skip some rules:

`jarl check --ignore {{rule1,rule2}} {{path/to/directory}}`

- One finding per line instead of annotated snippets:

`jarl check --output-format concise {{path/to/directory}}`

- Count findings by rule, to see what is worth fixing first:

`jarl check --statistics {{path/to/directory}}`

- Explain what a rule flags and why:

`jarl rule {{any_is_na}}`
