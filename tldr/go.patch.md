- terminal-setup extras (davetang/terminal-setup):

- Where this toolchain lives (no GOROOT needed — go resolves its own symlink):

`go env GOROOT`

- Install a program; it lands in $GOPATH/bin (~/go/bin), not ~/bin:

`go install {{github.com/owner/tool@latest}}`

- Build a static binary that runs anywhere, the way most tools here are shipped:

`CGO_ENABLED={{0}} go build -ldflags {{'-s -w'}} -o {{path/to/output}}`

- Cross-compile without a cross toolchain:

`GOOS={{linux}} GOARCH={{arm64}} go build -o {{path/to/output}}`

- Run the tests with the race detector:

`go test -race ./...`

- Format and tidy before committing:

`gofmt -w {{path/to/file.go}} && go mod tidy`
