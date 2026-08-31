# Omarchy Public IP

A small Omarchy bar widget that displays the machine's current public IPv4 address.

## Features

- Displays the current public IPv4 address in the Omarchy bar
- Uses Omarchy's native bar styling
- Automatically refreshes every 5 minutes
- Detects network changes and refreshes automatically
- Right-click the widget to refresh immediately
- Runs as the normal user; no root privileges are required

## Requirements

- Omarchy with the native Quickshell bar
- `curl`
- Network access to `https://api.ipify.org`

## Installation

```bash
omarchy plugin add https://github.com/carcuevas/omarchy-public-ip.git --enable
```

## Usage

Add `io.github.carcuevas.public-ip` to your Omarchy bar layout.

Right-click the widget to force an immediate update.

## License

MIT
