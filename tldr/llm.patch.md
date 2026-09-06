- terminal-setup extras (davetang/terminal-setup):

- Write a commit message from what is staged:

`git diff --staged | llm -s '{{write a commit message}}'`

- Continue the previous conversation:

`llm '{{and shorter}}' -c`

- Summarise a file or a URL:

`llm -f {{README.md}} '{{summarise this}}'`

- Use local models through the ollama client this setup installs:

`llm install llm-ollama && llm -m {{qwen3}} '{{explain this error}}'`

- Search past prompts; they are logged to SQLite:

`llm logs -q {{docker}}`

- Override the default model for this shell only (see shell/init.sh):

`export LLM_MODEL={{gpt-4.1-mini}}`
