import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQml
import "./components"
 
PanelWindow {
  id: root

  // Keep all visual tokens here so the child components stay focused on behavior.
  readonly property QtObject theme: QtObject {
    readonly property color background: "#a1a1a1"
    readonly property color accent: "#383838"
    readonly property color danger: "#f7768e"
    readonly property color muted: "#787878"
    readonly property color text: "#333333"
    readonly property color warning: "#333333"
    readonly property int barHeight: 30
    readonly property int sidePadding: 10
    readonly property int itemSpacing: 14
  }

  // A small type scale is easier to grow than a single hard-coded font size.
  readonly property QtObject typeScale: QtObject {
    readonly property int small: 12
    readonly property int body: 14
    readonly property int emphasis: 14
  }

  readonly property string fontFamily: "JetBrainsMono Nerd Font"

  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: theme.barHeight
  // Reserve the panel's height so tiled windows do not render underneath it.
  exclusiveZone: implicitHeight
  color: "transparent"


  Rectangle {
    anchors.fill: parent
    color: theme.background
    bottomLeftRadius: 8
    bottomRightRadius: 8
  }

  Row {
    anchors.left: parent.left
    anchors.leftMargin: theme.sidePadding
    anchors.verticalCenter: parent.verticalCenter
    spacing: theme.itemSpacing

    Workspaces {
      theme: root.theme
      fontFamily: root.fontFamily
      fontSize: root.typeScale.body
    }

    NowPlaying {
      width: 240
      theme: root.theme
      fontFamily: root.fontFamily
      fontSize: root.typeScale.body
    }
  }

  Clock {
    anchors.centerIn: parent

    theme: root.theme
    fontFamily: root.fontFamily
    fontSize: root.typeScale.body
  }

  Row {
    anchors.right: parent.right
    anchors.rightMargin: theme.sidePadding
    anchors.verticalCenter: parent.verticalCenter
    spacing: theme.itemSpacing

    SystemTrayWidget {
      theme: root.theme
      fontFamily: root.fontFamily
      fontSize: root.typeScale.body
      panelWindow: root
    }

    System {
      theme: root.theme
      fontFamily: root.fontFamily
      fontSize: root.typeScale.body
      spacing: theme.itemSpacing
    }
  }
}
