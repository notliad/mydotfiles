import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

Row {
  id: root

  required property var theme
  required property string fontFamily
  required property int fontSize
  required property var panelWindow

  spacing: 8

  Repeater {
    model: SystemTray.items

    delegate: Item {
      id: trayItemRoot

      required property var modelData
      property var trayItem: modelData
      property string tooltipText: trayItem.tooltipTitle || trayItem.title || trayItem.id
      readonly property bool tooltipOpen: trayMouseArea.containsMouse && tooltipLabel.text !== ""

      onTooltipOpenChanged: {
        if (tooltipOpen) {
          tooltipCloseTimer.stop()
        } else {
          tooltipCloseTimer.start()
        }
      }

      width: 18
      height: 18

      Image {
        anchors.fill: parent
        source: trayItem.icon
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectFit
        smooth: true
      }

      MouseArea {
        id: trayMouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => {
          if (mouse.button === Qt.RightButton && trayItem.hasMenu) {
            trayItem.display(root.panelWindow, trayItemRoot.x, trayItemRoot.y + trayItemRoot.height)
            return
          }

          if (mouse.button === Qt.MiddleButton) {
            trayItem.secondaryActivate()
            return
          }

          if (trayItem.onlyMenu && trayItem.hasMenu) {
            trayItem.display(root.panelWindow, trayItemRoot.x, trayItemRoot.y + trayItemRoot.height)
            return
          }

          trayItem.activate()
        }
      }

      PopupWindow {
        visible: trayItemRoot.tooltipOpen || tooltipCloseTimer.running
        color: "transparent"
        anchor.item: trayItemRoot
        anchor.rect.x: trayItemRoot.width / 2 - width / 2
        anchor.rect.y: trayItemRoot.height + 8
        width: Math.min(tooltipLabel.implicitWidth + 16, 260)
        height: tooltipLabel.implicitHeight + 12

        Rectangle {
          id: tooltipCard
          anchors.fill: parent
          radius: 6
          color: root.theme.background
          border.color: root.theme.accent
          border.width: 1
          opacity: trayItemRoot.tooltipOpen ? 1 : 0
          scale: trayItemRoot.tooltipOpen ? 1 : 0.96
          y: trayItemRoot.tooltipOpen ? 0 : -6

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
            id: tooltipLabel
            anchors.fill: parent
            anchors.margins: 6
            text: trayItemRoot.tooltipText
              + (trayItem.tooltipDescription ? "\n" + trayItem.tooltipDescription : "")
              + "\nClique esquerdo: abrir"
              + (trayItem.hasMenu ? "\nClique direito: menu" : "")
            color: root.theme.text
            font.family: root.fontFamily
            font.pixelSize: Math.max(root.fontSize - 2, 10)
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
          }
        }
      }

      Timer {
        id: tooltipCloseTimer
        interval: 140
      }
    }
  }
}