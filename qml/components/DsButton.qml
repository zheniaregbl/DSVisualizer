import QtQuick
import QtQuick.Controls
import DSVisualizer

Button {
    id: b
    property bool primary: false
    property bool ghost: false

    implicitHeight: 36
    topInset: 0; bottomInset: 0; leftInset: 0; rightInset: 0
    leftPadding: 14; rightPadding: 14
    font.family: Theme.fontUi; font.pixelSize: 13; font.weight: Font.Medium
    opacity: enabled ? 1 : 0.4
    scale: down ? 0.97 : 1
    Behavior on scale { NumberAnimation { duration: 120 } }

    contentItem: Text {
        text: b.text; font: b.font
        color: b.primary ? Theme.node : (b.ghost && !b.hovered ? Theme.muted : Theme.ink)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
        radius: Theme.radius
        color: b.primary ? Theme.accent : (b.ghost ? "transparent" : Theme.surface)
        border.color: b.primary ? Theme.accent
                    : b.hovered ? Theme.edge
                    : b.ghost ? "transparent" : Theme.line
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }
}