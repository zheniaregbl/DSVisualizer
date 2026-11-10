import QtQuick
import DSVisualizer

Rectangle {
    id: root
    property string label: "значение"
    property alias text: field.text
    readonly property int value: parseInt(field.text) || 0
    signal accepted()
    function shake() { shakeAnim.restart() }

    implicitWidth: row.implicitWidth + 22
    implicitHeight: 36
    radius: Theme.radius
    color: Theme.surface
    border.color: field.activeFocus ? Theme.accent : Theme.line
    Behavior on border.color { ColorAnimation { duration: 150 } }
    transform: Translate { id: tr }

    Row {
        id: row
        x: 11
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label; color: Theme.muted; font.pixelSize: 12
        }
        TextInput {
            id: field
            anchors.verticalCenter: parent.verticalCenter
            width: 42
            text: "17"
            color: Theme.ink
            selectionColor: Theme.accent
            font.family: Theme.fontMono; font.pixelSize: 15; font.weight: Font.DemiBold
            validator: IntValidator { bottom: -999; top: 999 }
            selectByMouse: true
            onAccepted: root.accepted()
        }
    }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: tr; property: "x"; to: -5; duration: 60 }
        NumberAnimation { target: tr; property: "x"; to: 5;  duration: 60 }
        NumberAnimation { target: tr; property: "x"; to: -5; duration: 60 }
        NumberAnimation { target: tr; property: "x"; to: 0;  duration: 60 }
    }
}