# Omarchy Public IP

A small Omarchy bar widget that displays the machine's current public IPv4 or IPv6 address.

## Features

- Displays the current public IPv4 or IPv6 address
- Prefers IPv4 and falls back to IPv6 when IPv4 is unavailable
- Uses Omarchy's native bar typography, spacing, and colors
- Refreshes automatically every 5 minutes
- Detects local network/interface changes and refreshes automatically
- Right-click the IP to force an immediate refresh
- Runs with normal user permissions; no root privileges are required
- Limits the HTTP response to 64 bytes
- Validates the returned value as a real IPv4 or IPv6 address before displaying it

## Requirements

- Omarchy Quickshell bar
- `curl`
- Network access to `api.ipify.org` and/or `api64.ipify.org`

The plugin does not install services, modify NetworkManager, or require elevated privileges.

## Install

```sh
omarchy plugin add https://github.com/carcuevas/omarchy-public-ip.git --enable
```

## Remove

```sh
omarchy plugin remove io.github.carcuevas.public-ip
```

## Validation

```sh
PLUGIN_ID="io.github.carcuevas.public-ip"
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"
omarchy plugin validate "$PLUGIN_DIR"
```

## License

MIT
