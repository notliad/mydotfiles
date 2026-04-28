import Quickshell.Io
import QtQuick
import QtQuick.Layouts


RowLayout {
  required property var theme
  required property string fontFamily
  required property int fontSize

  property int cpuUsage: 0
  property int lastCpuIdle: 0
  property int lastCpuTotal: 0
  property string memUsage: ""
  property string memAvailable: ""
  property string bluetoothLabel: "󰂲 off"
  property string bluetoothState: "off"
  property color bluetoothColor: theme.danger
  property string bluetoothTooltip: "Bluetooth desligado."
  property string wifiLabel: "󰤮 offline"
  property string wifiTooltip: "Wi-Fi desconectado."
  property string soundLabel: "󰕾 --%"
  property string soundTooltip: "Volume do dispositivo padrão."
  property string batteryLabel: "󰁹 --%"
  property string batteryTooltip: "Estado da bateria indisponível."

  function refreshFastStats() {
    cpuProc.running = true
    memProc.running = true
  }

  function refreshDeviceStats() {
    bluetoothProc.running = true
    wifiProc.running = true
    soundProc.running = true
    batteryProc.running = true
  }


  Process {
    id: cpuProc
    command: ["sh", "-c", "head -1 /proc/stat"]

    stdout: SplitParser {
      onRead: data => {
        // /proc/stat reports cumulative CPU time. We compare the new sample to
        // the previous one to estimate usage over the last timer interval.
        var p = data.trim().split(/\s+/)
        var idle = parseInt(p[4]) + parseInt(p[5])
        var total = p.slice(1).reduce((a, b) => a + parseInt(b), 0)
        if (lastCpuTotal > 0) {
          cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
        }
        lastCpuTotal = total
        lastCpuIdle = idle
      }
    }
  }

  Process {
    id: memProc
    command: ["sh", "-c", "free -m | grep Mem"]
    stdout: SplitParser {
      onRead: data => {
        //calculate memory showing GB of a total
        var parts = data.trim().split(/\s+/)
        var total = parseInt(parts[1]) || 1
        var used = parseInt(parts[2]) || 0
        var available = parseInt(parts[6]) || 0
        memUsage = (used / 1024).toFixed(1) + "/" + (total / 1024).toFixed(1) + "GB"
        memAvailable = (available / 1024).toFixed(1) + "GB livres"
      }
    }
  }

  Timer {
    // Polling every 2 seconds keeps the bar responsive without spawning these
    // helper processes on every rendered frame.
    interval: 2000
    running: true
    repeat: true
    onTriggered: refreshFastStats()
  }

  Timer {
    // Device state changes less often than CPU/RAM, so poll these more gently.
    interval: 5000
    running: true
    repeat: true
    onTriggered: refreshDeviceStats()
  }

  Process {
    id: bluetoothProc
    command: ["sh", "-c", "rfkill --output TYPE,SOFT,HARD | awk 'NR > 1 && $1 == \"bluetooth\" { if ($2 == \"unblocked\" && $3 == \"unblocked\") state = \"on\"; else blocked = 1 } END { if (state == \"on\") print \"on\"; else if (blocked) print \"blocked\"; else print \"off\" }'"]
    stdout: SplitParser {
      onRead: data => {
        var state = data.trim()
        bluetoothState = state

        if (state === "on") {
          bluetoothLabel = "󰂯"
          bluetoothColor = theme.accent
          bluetoothTooltip = "Bluetooth ligado.\nEstado: pronto para conexoes."
        } else if (state === "blocked") {
          bluetoothLabel = "󰂲"
          bluetoothColor = theme.muted
          bluetoothTooltip = "Bluetooth bloqueado por software ou hardware.\nVerifique rfkill ou tecla fisica."
        } else {
          bluetoothLabel = "󰂲"
          bluetoothColor = theme.danger
          bluetoothTooltip = "Bluetooth desligado."
        }
      }
    }
  }

  Process {
    id: wifiProc
    command: ["sh", "-c", "iw dev wlan0 link | awk '/SSID:/ {ssid = substr($0, index($0, $2))} /signal:/ {signal = $2} END { if (ssid != \"\") print ssid \"|\" signal; else print \"offline\" }'"]
    stdout: SplitParser {
      onRead: data => {
        var parts = data.trim().split("|")

        if (parts[0] === "offline" || parts[0] === "") {
          wifiLabel = "󰤮 offline"
          wifiTooltip = "Wi-Fi desconectado.\nInterface: wlan0"
          return
        }

        // RSSI is negative dBm. Less negative means stronger signal.
        var signal = parseInt(parts[1])
        var icon = "󰤯"
        if (signal >= -55) {
          icon = "󰤨"
        } else if (signal >= -67) {
          icon = "󰤥"
        } else if (signal >= -75) {
          icon = "󰤢"
        }

        wifiLabel = icon + " " + parts[0]
        wifiTooltip = "Rede: " + parts[0] + "\nSinal: " + parts[1] + " dBm\nInterface: wlan0"
      }
    }
  }

  Process {
    id: soundProc
    command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{ volume = int($2 * 100 + 0.5); muted = ($3 == \"[MUTED]\"); printf \"%d|%s\\n\", volume, muted ? \"muted\" : \"live\" }'"]
    stdout: SplitParser {
      onRead: data => {
        var parts = data.trim().split("|")
        var volume = parts[0] || "--"
        var isMuted = parts[1] === "muted"
        var icon = isMuted ? "󰝟" : (parseInt(volume) > 50 ? "󰕾" : "󰖀")
        soundLabel = icon + " " + volume + "%"
        soundTooltip = "Volume: " + volume + "%" + (isMuted ? "\nAudio mutado." : "\nAudio ativo.")
      }
    }
  }

  Process {
    id: batteryProc
    command: ["sh", "-c", "printf '%s|%s\n' \"$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)\" \"$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)\""]
    stdout: SplitParser {
      onRead: data => {
        var parts = data.trim().split("|")
        var status = parts[0] || "Unknown"
        var percent = parseInt(parts[1])
        var icon = "󰁹"

        if (status === "Charging") {
          icon = "󰂄"
        } else if (percent >= 95) {
          icon = "󰁹"
        } else if (percent >= 75) {
          icon = "󰂀"
        } else if (percent >= 55) {
          icon = "󰁿"
        } else if (percent >= 35) {
          icon = "󰁾"
        } else if (percent >= 15) {
          icon = "󰁽"
        } else {
          icon = "󰂎"
        }

        batteryLabel = icon + " " + (isNaN(percent) ? "--" : percent) + "%"
        batteryTooltip = "Bateria: " + (isNaN(percent) ? "--" : percent) + "%\nEstado: " + status
      }
    }
  }

  Component.onCompleted: {
    refreshFastStats()
    refreshDeviceStats()
  }

  InfoChip {
    text: " " + cpuUsage + "%"
    tooltipText: "Uso atual de CPU: " + cpuUsage
    tooltipAlignment: Text.AlignLeft
    theme: parent.theme
    fontFamily: parent.fontFamily
    fontSize: parent.fontSize
    textColor: theme.warning
  }

  InfoChip {
    text: " " + memUsage
    tooltipText: "Memoria em uso: " + memUsage + "\nDisponivel: " + memAvailable
    tooltipAlignment: Text.AlignLeft
    theme: parent.theme
    fontFamily: parent.fontFamily
    fontSize: parent.fontSize
    textColor: theme.warning
  }

  InfoChip {
    text: bluetoothLabel
    tooltipText: bluetoothTooltip
    clickCommand: "omarchy-launch-bluetooth"
    tooltipAlignment: Text.AlignLeft
    theme: parent.theme
    fontFamily: parent.fontFamily
    fontSize: parent.fontSize
    textColor: bluetoothColor
  }

  InfoChip {
    text: wifiLabel
    tooltipText: wifiTooltip
    clickCommand: "omarchy-launch-wifi"
    tooltipAlignment: Text.AlignLeft
    tooltipMaxWidth: 300
    theme: parent.theme
    fontFamily: parent.fontFamily
    fontSize: parent.fontSize
    textColor: theme.text
  }

  InfoChip {
    text: soundLabel
    tooltipText: soundTooltip
    clickCommand: "omarchy-launch-audio"
    tooltipAlignment: Text.AlignLeft
    tooltipMaxWidth: 300
    theme: parent.theme
    fontFamily: parent.fontFamily
    fontSize: parent.fontSize
    textColor: theme.text
  }

  InfoChip {
    text: batteryLabel
    tooltipText: batteryTooltip
    tooltipAlignment: Text.AlignLeft
    theme: parent.theme
    fontFamily: parent.fontFamily
    fontSize: parent.fontSize
    textColor: theme.text
  }
}