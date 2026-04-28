import Quickshell
import Quickshell.Io
import QtQuick

Item {
  id: root

  required property var theme
  required property string fontFamily
  required property int fontSize
  required property string text
  property string tooltipText: ""
  property color textColor: theme.text
  property bool bold: true
  property string clickCommand: ""
  property int tooltipMaxWidth: 260
  property int tooltipPadding: 8
  property int tooltipRadius: 8
  property int tooltipAlignment: Text.AlignHCenter
  property bool tooltipMonospace: false
  readonly property bool tooltipOpen: mouseArea.containsMouse && root.tooltipText !== ""

  implicitWidth: label.implicitWidth
  implicitHeight: label.implicitHeight

  onTooltipOpenChanged: {
    if (tooltipOpen) {
      tooltipCloseTimer.stop()
    } else {
      tooltipCloseTimer.start()
    }
  }

  Text {
    id: label
    anchors.centerIn: parent
    text: root.text
    color: root.textColor
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    font.bold: root.bold
    scale: mouseArea.containsMouse ? 1.03 : 1.0

    Behavior on scale {
      NumberAnimation {
        duration: 160
        easing.type: Easing.OutQuint
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: root.clickCommand !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor

    onClicked: {
      if (root.clickCommand === "") {
        return
      }

      launcher.command = ["sh", "-c", root.clickCommand]
      launcher.running = true
    }
  }

  PopupWindow {
    id: tooltipBubble
    visible: root.tooltipOpen || tooltipCloseTimer.running
    color: "transparent"
    anchor.item: root
    anchor.rect.x: root.width / 2 - width / 2
    anchor.rect.y: root.height + 8
    width: Math.min(tooltipLabel.implicitWidth + root.tooltipPadding * 2, root.tooltipMaxWidth)
    height: tooltipLabel.implicitHeight + root.tooltipPadding * 2

    Rectangle {
      id: tooltipCard
      anchors.fill: parent
      radius: root.tooltipRadius
      color: theme.background
      border.color: theme.accent
      border.width: 1
      opacity: root.tooltipOpen ? 1 : 0
      scale: root.tooltipOpen ? 1 : 0.96
      y: root.tooltipOpen ? 0 : -6

      Behavior on opacity {
        NumberAnimation {
          duration: 170
          easing.type: Easing.OutQuint
        }
      }

      Behavior on scale {
        NumberAnimation {
          duration: 220
          easing.type: Easing.OutQuint
        }
      }

      Behavior on y {
        NumberAnimation {
          duration: 220
          easing.type: Easing.OutQuint
        }
      }

      Text {
        id: tooltipLabel
        anchors.fill: parent
        anchors.margins: root.tooltipPadding
        text: root.tooltipText
        color: theme.text
        font.family: root.tooltipMonospace ? root.fontFamily : root.fontFamily
        font.pixelSize: Math.max(root.fontSize - 2, 10)
        wrapMode: Text.Wrap
        horizontalAlignment: root.tooltipAlignment
        verticalAlignment: Text.AlignVCenter
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
}