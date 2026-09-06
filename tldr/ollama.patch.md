- terminal-setup extras (davetang/terminal-setup):

- This setup installs the client only: there is no `ollama serve` here, so point it at a server (also settable in shell/init.sh):

`export OLLAMA_HOST={{http://gpu-box:11434}}`

- One-shot prompt that prints and exits:

`ollama run {{qwen3}} '{{one-line summary}}'`

- Prompt from a pipe or a file:

`cat {{notes.md}} | ollama run {{qwen3}} '{{summarise}}'`

- Client version; it warns when no server answers:

`ollama --version`

- Register that server's models with llm as well:

`llm install llm-ollama`
