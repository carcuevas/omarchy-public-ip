# Omarchy Public IP

A small Omarchy Quattro bar widget that displays the machine's current public IPv4 address.

## Features

- Displays the current public IPv4 address
- Uses Omarchy's native bar typography, spacing, and colors
- Refreshes automatically every 5 minutes
- Detects local network/interface changes and refreshes automatically
- Right-click the IP to force an immediate refresh
- Runs with the normal user's permissions; no root privileges are required

## Requirements

- Omarchy Quattro
- `curl`
- Network access to `https://api.ipify.org`

The plugin does not install services, modify NetworkManager, or require elevated privileges.

## Install

From the public repository:

```sh
omarchy plugin add https://github.com/carcuevas/omarchy-public-ip.git --enable
```

## Configure

The plugin defaults to the right side of the bar.

You can place it elsewhere using Omarchy's normal bar configuration tools.

## Remove

```sh
omarchy plugin remove io.github.carcuevas.public-ip
```

## Development / validation

Validate the installed plugin with:

```sh
PLUGIN_ID="io.github.carcuevas.public-ip"
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"

omarchy plugin validate "$PLUGIN_DIR"
```

The plugin's manifest entry point is:

```text
PublicIp.qml
```

`qmllint` may report unresolved `qs.Commons` / `qs.Ui` imports when run standalone with a plain `-I "$OMARCHY_PATH/shell"` invocation. This is also reproducible with Omarchy's own built-in widgets; Omarchy's plugin validator is the authoritative manifest/layout validation for this plugin.

## License

MIT
