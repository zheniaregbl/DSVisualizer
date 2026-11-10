pragma Singleton
import QtQuick

QtObject {
    readonly property color bg:      "#111315"
    readonly property color panel:   "#16191B"
    readonly property color surface: "#1A1D20"
    readonly property color node:    "#23272B"
    readonly property color ink:     "#E7E9EA"
    readonly property color muted:   "#8B9298"
    readonly property color line:    "#2A2E32"
    readonly property color edge:    "#50575D"
    readonly property color accent:  "#8FA3FF"
    readonly property color compare: "#E9A23B"
    readonly property color found:   "#3DBE86"
    readonly property color remove:  "#EE6A60"

    readonly property string fontUi:   "Segoe UI"
    readonly property string fontMono: "Consolas"
    readonly property int radius: 8

    function tint(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
}