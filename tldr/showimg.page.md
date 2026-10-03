# showimg

> Show an image in the terminal you are sitting at, including over SSH and inside tmux or GNU screen.
> Sends it as a kitty graphics, iTerm2 inline image or sixel escape sequence; PNG needs no other tools.
> More information: <https://github.com/davetang/showimg>.

- Show an image below the command, as wide as the terminal allows:

`showimg {{path/to/plot.png}}`

- Show it at most 20 rows tall (PDF and SVG need pdftoppm, rsvg-convert or ImageMagick):

`showimg -r {{20}} {{path/to/heatmap.pdf}}`

- Show an image read from standard input:

`curl -s {{https://example.com/logo.png}} | showimg`

- Print which protocol (kitty, iterm or sixel) and size it used:

`showimg -v {{path/to/plot.png}}`

- Draw it with coloured characters instead, for terminals without images and for mosh (needs chafa):

`showimg -p text {{path/to/plot.png}}`

- Pick the protocol yourself, for example inside GNU screen with iTerm2 or WezTerm:

`export SHOWIMG_PROTOCOL={{iterm}}`

- Inside tmux, let programs send images to the terminal, or tmux drops them (put the same line in ~/.tmux.conf to keep it):

`tmux set -g allow-passthrough on`

- Test the terminal on its own, outside tmux and screen (a red rectangle, kitty protocol):

`printf '\e_Ga=T,f=24,s=1,v=1,c=10,r=5;/wAA\e\\\n'`
