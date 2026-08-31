# Omarchy Public IP

A small Omarchy bar widget that displays the machine's current public IPv4 address.

## Features

- Displays the current public IPv4 address
- Uses Omarchy's native bar typography and colors
- Refreshes every 5 minutes
- Detects local network changes and refreshes automatically
- Right-click to refresh immediately
- Runs as the normal user; no root privileges are required

## Requirements

- Omarchy native Quickshell bar
- `curl`

## Installation

```bash
omarchy plugin add https://github.com/carcuevas/omarchy-public-ip.git --enable
```

## License

MIT
