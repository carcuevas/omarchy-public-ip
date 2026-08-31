import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
    id: root

    moduleName: "io.github.carcuevas.public-ip"

    property string publicIp: ""
    property string networkState: ""
    property bool busy: false

    // Text widgets must use WidgetButton rather than BarIconButton:
    // BarIconButton reserves a fixed icon slot, while the IP needs its
    // natural text width.
    visible: true
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    function refresh() {
        if (busy) return
        busy = true
        publicIpProc.running = true
    }

    function checkNetwork() {
        networkStateProc.running = true
    }

    Process {
        id: publicIpProc
        command: ["curl", "-4", "-fsS", "--max-time", "8", "https://api.ipify.org"]

        stdout: StdioCollector {
            onStreamFinished: {
                var value = String(text || "").trim()
                if (value !== "")
                    root.publicIp = value
                root.busy = false
            }
        }

        stderr: StdioCollector {}
    }

    Process {
        id: networkStateProc
        command: ["sh", "-c", "ip -br addr | awk '$1 != \"lo\" {print $1,$2,$3}'"]

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

    // Normal periodic refresh.
    Timer {
        interval: 300000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // Detect interface/address changes.
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
            : "Public IP: " + (root.publicIp !== "" ? root.publicIp : "unknown")

        onPressed: function(buttonId) {
            if (buttonId === Qt.RightButton)
                root.refresh()
        }
    }
}
