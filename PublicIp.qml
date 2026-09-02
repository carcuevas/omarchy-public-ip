import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
    id: root

    moduleName: "io.github.carcuevas.public-ip"

    property string publicIp: ""
    property string networkState: ""
    property bool busy: false
    property bool networkProbeBusy: false

    visible: true
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    function isValidIpv4(value) {
        var parts = String(value || "").trim().split(".")
        if (parts.length !== 4)
            return false

        for (var i = 0; i < 4; i++) {
            if (!/^[0-9]+$/.test(parts[i]))
                return false

            var octet = Number(parts[i])
            if (!Number.isInteger(octet) || octet < 0 || octet > 255)
                return false
        }

        return true
    }

    function isValidIpv6(value) {
        value = String(value || "").trim()

        if (value.length < 2 || value.length > 39 || value.indexOf(":") === -1)
            return false

        if (/\s/.test(value) || value.indexOf(".") !== -1)
            return false

        var doubleColon = value.indexOf("::")
        if (doubleColon !== -1 && doubleColon !== value.lastIndexOf("::"))
            return false

        var groups = value.split(":")
        var nonEmptyGroups = 0

        for (var i = 0; i < groups.length; i++) {
            if (groups[i] === "")
                continue

            if (!/^[0-9a-fA-F]{1,4}$/.test(groups[i]))
                return false

            nonEmptyGroups++
        }

        if (doubleColon === -1)
            return nonEmptyGroups === 8

        return nonEmptyGroups < 8
    }

    function isValidIp(value) {
        return isValidIpv4(value) || isValidIpv6(value)
    }

    function refresh() {
        if (busy)
            return

        busy = true
        publicIpProc.running = true
    }

    function checkNetwork() {
        if (networkProbeBusy)
            return

        networkProbeBusy = true
        networkStateProc.running = true
    }

    Process {
        id: publicIpProc

        // Each attempt is producer-capped at 64 bytes before it reaches the
        // temporary file. Only the successful attempt is emitted, so IPv4
        // and IPv6 output can never be concatenated into one collector.
        command: [
            "setsid",
            "timeout",
            "--signal=TERM",
            "--kill-after=1s",
            "9s",
            "bash",
            "-c",
            "set -o pipefail; " +
            "tmp=$(mktemp) || exit 1; " +
            "trap 'rm -f \"$tmp\"' EXIT; " +
            "curl -4 -fsS --max-time 8 https://api.ipify.org 2>/dev/null | " +
            "head -c 64 > \"$tmp\"; " +
            "rc=${PIPESTATUS[0]}; " +
            "if [ \"$rc\" -eq 0 ]; then cat \"$tmp\"; exit 0; fi; " +
            ": > \"$tmp\"; " +
            "curl -6 -fsS --max-time 8 https://api64.ipify.org 2>/dev/null | " +
            "head -c 64 > \"$tmp\"; " +
            "rc=${PIPESTATUS[0]}; " +
            "if [ \"$rc\" -eq 0 ]; then cat \"$tmp\"; exit 0; fi; " +
            "exit \"$rc\""
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var value = String(text || "").trim()

                if (root.isValidIp(value))
                    root.publicIp = value

                root.busy = false
            }
        }
    }

    Process {
        id: networkStateProc

        // Bound interface count, field lengths, address count, and total
        // serialized output. stderr is discarded and the whole process group
        // has a hard deadline.
        command: [
            "setsid",
            "timeout",
            "--signal=TERM",
            "--kill-after=1s",
            "3s",
            "bash",
            "-c",
            "trap 'exit 124' TERM INT; " +
            "ip -br addr 2>/dev/null | " +
            "awk 'BEGIN { total=0 } " +
            "NR > 32 { exit 2 } " +
            "{ line=substr($1,1,32) \" \" substr($2,1,16); " +
            "  for (i=3; i<=NF && i<=10; i++) " +
            "    line=line \" \" substr($i,1,64); " +
            "  line=line \"\\\\n\"; " +
            "  if (total + length(line) > 2048) exit 2; " +
            "  printf \"%s\", line; total += length(line) }'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var state = String(text || "").trim()

                if (state !== root.networkState) {
                    root.networkState = state
                    root.refresh()
                }

                root.networkProbeBusy = false
            }
        }
    }

    Timer {
        interval: 300000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: root.refresh()
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: root.checkNetwork()
    }

    WidgetButton {
        id: button

        anchors.fill: parent
        bar: root.bar

        text: root.publicIp !== "" ? root.publicIp : "—"
        fontSize: Style.font.bodySmall
        horizontalMargin: 5
        verticalPadding: 0

        tooltipText: root.busy
            ? "Updating public IP…"
            : "Public IP: " + (
                root.publicIp !== "" ? root.publicIp : "unknown"
            )

        onPressed: function(buttonId) {
            if (buttonId === Qt.RightButton)
                root.refresh()
        }
    }
}
