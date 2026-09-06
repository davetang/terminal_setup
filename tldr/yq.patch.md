- terminal-setup extras (davetang/terminal-setup):

- YAML to JSON, so jq can take over:

`yq -o=json '.' {{path/to/file.yaml}} | jq '{{.services}}'`

- JSON back to YAML:

`yq -P '.' {{path/to/file.json}}`

- Pull one nested value:

`yq '{{.services.web.image}}' {{docker-compose.yml}}`
