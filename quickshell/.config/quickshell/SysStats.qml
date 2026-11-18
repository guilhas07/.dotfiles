import QtQuick
import Quickshell.Io

// CPU %, RAM % (click for GiB), coretemp °C. Polled every 3s from /proc and /sys.
Row {
    id: root

    property real cpu: 0
    property real memUsed: 0
    property real memTotal: 1
    property real temp: 0
    property bool memAlt: false
    property string tempPath: ""
    property var lastCpu: null

    readonly property var tempIcons: [0xF2CB, 0xF2C9, 0xF2C7].map(c => String.fromCodePoint(c))

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const f = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = f[3] + f[4];
            const total = f.reduce((a, b) => a + b, 0);
            if (root.lastCpu) {
                const dt = total - root.lastCpu.total;
                if (dt > 0)
                    root.cpu = 1 - (idle - root.lastCpu.idle) / dt;
            }
            root.lastCpu = { idle, total };
        }
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const get = key => Number(text().match(new RegExp(`^${key}:\\s+(\\d+)`, "m"))?.[1] ?? 0);
            root.memTotal = get("MemTotal") / 1048576;
            root.memUsed = root.memTotal - get("MemAvailable") / 1048576;
        }
    }

    FileView {
        id: tempFile
        path: root.tempPath
        onLoaded: root.temp = Number(text()) / 1000
    }

    // hwmon numbering changes between boots: find coretemp by name.
    Process {
        running: true
        command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do [ \"$(cat $h/name)\" = coretemp ] && echo $h/temp1_input && break; done"]
        stdout: StdioCollector {
            onStreamFinished: root.tempPath = text.trim()
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            meminfo.reload();
            if (root.tempPath) tempFile.reload();
        }
    }

    BarButton {
        text: `CPU ${Math.round(root.cpu * 100)}%`
        hoverable: false
    }

    BarButton {
        text: root.memAlt
            ? `RAM ${root.memUsed.toFixed(1)}/${root.memTotal.toFixed(1)}G`
            : `RAM ${Math.round(root.memUsed / root.memTotal * 100)}%`
        onClicked: root.memAlt = !root.memAlt
    }

    BarButton {
        readonly property bool critical: root.temp >= 80
        visible: root.tempPath !== ""
        text: `${root.tempIcons[Math.min(2, Math.floor(root.temp / 34))]} ${Math.round(root.temp)}°C`
        textColor: critical ? Theme.crit : Theme.fg
        hoverable: false
    }
}
