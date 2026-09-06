- terminal-setup extras (davetang/terminal-setup):

- Raw sockets are needed, so grant the capability once instead of sudo every time (needs root that once):

`sudo setcap cap_net_raw+ep {{~/bin/trip}}`

- Cap the number of hops with -t; -m selects the output mode, not the TTL:

`sudo trip -t {{30}} {{1.1.1.1}}`

- UDP probes instead of the default ICMP:

`sudo trip --udp {{example.com}}`

- A CSV report instead of the TUI, into this setup's table tools:

`sudo trip -m csv -C {{5}} {{example.com}} | csvtk pretty`
