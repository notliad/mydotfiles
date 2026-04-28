import Quickshell
import Quickshell.Io
import QtQuick

Item {
  id: root

  required property var theme
  required property string fontFamily
  required property int fontSize

  property string mediaLabel: ""
  property string mediaTooltip: "Nenhuma midia detectada."
  readonly property bool tooltipOpen: mouseArea.containsMouse && mediaLabel !== ""

  onTooltipOpenChanged: {
    if (tooltipOpen) {
      tooltipCloseTimer.stop()
    } else {
      tooltipCloseTimer.start()
    }
  }

  implicitWidth: Math.min(mediaText.implicitWidth, 260)
  implicitHeight: mediaText.implicitHeight

  Loader {
    id: playerctlLoader
    sourceComponent: mediaLabel === "" ? null : mediaText
  }

  function refreshMedia() {
    mediaProc.running = true
  }

  Text {
    id: mediaText
    anchors.fill: parent
    text: root.mediaLabel
    color: theme.text
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    font.bold: false
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: {
        launcher.command = ["sh", "-c", "playerctl play-pause"]
        launcher.running = true
    }
  }

  PopupWindow {
    visible: root.tooltipOpen || tooltipCloseTimer.running
    color: "transparent"
    anchor.item: root
    anchor.rect.x: 0
    anchor.rect.y: root.height + 8
    width: Math.min(mediaTooltipText.implicitWidth + 16, 340)
    height: mediaTooltipText.implicitHeight + 16

    Rectangle {
      anchors.fill: parent
      radius: 8
      color: theme.background
      border.color: theme.accent
      border.width: 1
      opacity: root.tooltipOpen ? 1 : 0
      scale: root.tooltipOpen ? 1 : 0.96
      y: root.tooltipOpen ? 0 : -6

      Behavior on opacity {
        NumberAnimation { duration: 170; easing.type: Easing.OutQuint }
      }

      Behavior on scale {
        NumberAnimation { duration: 220; easing.type: Easing.OutQuint }
      }

      Behavior on y {
        NumberAnimation { duration: 220; easing.type: Easing.OutQuint }
      }

      Text {
        id: mediaTooltipText
        anchors.fill: parent
        anchors.margins: 8
        text: root.mediaTooltip
        color: theme.text
        font.family: root.fontFamily
        font.pixelSize: Math.max(root.fontSize - 2, 10)
        wrapMode: Text.Wrap
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: refreshMedia()
  }

  Process {
    id: mediaProc
    command: ["sh", "-c", "playerctl metadata --format '{{status}}|{{artist}}|{{title}}|{{playerName}}' 2>/dev/null | head -n 1"]
    stdout: SplitParser {
      onRead: data => {
        var parts = data.trim().split("|")

        if (parts.length < 4 || (parts[1] === "" && parts[2] === "")) {
          mediaLabel = ""
          mediaTooltip = "Nenhuma midia ativa detectada por playerctl."
          return
        }

        var status = parts[0] || "Stopped"
        var artist = parts[1] || "Artista desconhecido"
        var title = parts[2] || "Faixa desconhecida"
        var playerName = parts[3] || "player desconhecido"
        var icon = status === "Playing" ? "󰎈" : ""

        mediaLabel = icon + " " + artist + " - " + title
        mediaTooltip = "Player: " + playerName + "\nEstado: " + status + "\nFaixa: " + artist + " - " + title + "\nClique para play/pause."
      }
    }
  }

  Timer {
    id: tooltipCloseTimer
    interval: 140
  }

  Process {
    id: launcher
  }

  Component.onCompleted: refreshMedia()
}