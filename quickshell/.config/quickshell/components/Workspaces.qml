import Quickshell.Hyprland
import QtQuick

Row {
  id: workspaceRow

  required property var theme
  required property string fontFamily
  required property int fontSize

  spacing: theme.itemSpacing
  anchors.verticalCenter: parent.verticalCenter
  
  Repeater {
    id: workspaceRepeater
    model: Hyprland.workspaces.values.length
        
    
    delegate: Item {
      id: workspaceItem

      required property int index

      property int workspaceId: index + 1
      // Hyprland.workspaces is a live ObjectModel. `.values` gives us a JS
      // array so we can use familiar helpers like `find`.
      property var workspace: Hyprland.workspaces.values.find(ws => ws.id === workspaceId)
      property bool isActive: Hyprland.focusedWorkspace?.id === workspaceId
      property real targetSize: isActive ? 15 : 10
      property real targetRadius: isActive ? 3 : 5
      property color targetColor: isActive ? theme.accent : theme.muted

      implicitWidth: indicator.width
      implicitHeight: indicator.height
      anchors.verticalCenter: parent.verticalCenter

      Rectangle {
        id: indicator
        width: workspaceItem.targetSize
        height: workspaceItem.targetSize
        radius: workspaceItem.targetRadius
        color: workspaceItem.targetColor

        Behavior on width {
          NumberAnimation {
            duration: 220
            easing.type: Easing.OutQuint
          }
        }

        Behavior on height {
          NumberAnimation {
            duration: 220
            easing.type: Easing.OutQuint
          }
        }

        Behavior on radius {
          NumberAnimation {
            duration: 220
            easing.type: Easing.OutQuint
          }
        }

        Behavior on color {
          ColorAnimation {
            duration: 180
            easing.type: Easing.OutQuad
          }
        }

        SequentialAnimation on scale {
          running: workspaceItem.isActive
          loops: 1
          NumberAnimation {
            to: 1.08
            duration: 120
            easing.type: Easing.OutQuint
          }
          NumberAnimation {
            to: 1.0
            duration: 140
            easing.type: Easing.OutQuint
          }
        }
      }

      MouseArea {
        id: workspaceMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        // This string is passed directly to Hyprland's IPC dispatcher.
        onClicked: Hyprland.dispatch("workspace " + workspaceItem.workspaceId)
      }
    }
  }
}