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

        // IPv6 addresses contain at least two colons and may use :: once.
        if (value.length < 2 || value.length > 39 || value.indexOf(":") === -1)
            return false

        // Reject whitespace and IPv4-mapped/embedded IPv4 forms here.
        // The endpoint is queried with curl's IPv6 mode, so a pure IPv6
        // textual address is what we expect.
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

        // Without :: there must be exactly 8 groups.
        if (doubleColon === -1)
            return nonEmptyGroups === 8

        // With ::, it must compress at least one group.
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
        networkStateProc.running = true
    }

    Process {
        id: publicIpProc

        // Try IPv4 first and fall back to IPv6 if IPv4 is unavailable.
        // The output is capped at 64 bytes before reaching StdioCollector.
        command: [
            "sh",
            "-c",
            "curl -4 -fsS --max-time 8 --max-filesize 64 https://api.ipify.org || " +
            "curl -6 -fsS --max-time 8 --max-filesize 64 https://api64.ipify.org"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var value = String(text || "").trim()

                if (root.isValidIp(value))
                    root.publicIp = value

                root.busy = false
            }
        }

        stderr: StdioCollector {}
    }

    Process {
        id: networkStateProc

        command: [
            "sh",
            "-c",
            "ip -br addr | awk '$1 != \"lo\" {print $1,$2,$3}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var state = String(text || "").trim()

                if (state !== root.networkState) {
                    root.networkState = state
                    root.refresh()
                }
            }
        }

        stderr: StdioCollector {}
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
