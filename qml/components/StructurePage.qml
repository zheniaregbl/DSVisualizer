import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DSVisualizer

Item {
    id: page
    property string group
    property string title
    property string description
    property var complexity: []
    property var code: []
    property int currentLine: -1
    property string meta
    readonly property bool busy: stepper.running

    default property alias stageContent: stageArea.data
    property alias dock: dockRow.data

    property var _steps: []
    property int _i: 0
    Timer { id: stepper; interval: 480; repeat: true; onTriggered: page._next() }

    function run(steps) {
        if (stepper.running) return
        _steps = steps; _i = 0
        _next()
        stepper.start()
    }
    signal stopped()
    function stop() {
        if (!stepper.running) return
        stepper.stop()
        currentLine = -1
        log("операция прервана")
        stopped()
    }
    Shortcut { sequence: "Esc"; enabled: page.busy; onActivated: page.stop() }

    function _next() {
        if (_i >= _steps.length) { stepper.stop(); return }
        const s = _steps[_i++]
        if (s.code !== undefined) code = s.code
        if (s.line !== undefined) currentLine = s.line
        if (s.act) s.act()
    }

    ListModel { id: logModel }
    property int _logN: 0
    function log(t) { logModel.insert(0, { n: ++_logN, t: t }) }
    function toast(t) { toastText.text = t; toastAnim.restart() }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 18
            Layout.topMargin: 20
            spacing: 14

            ColumnLayout {
                spacing: 3
                Text {
                    text: page.group.toUpperCase()
                    color: Theme.muted; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1
                }
                Text {
                    text: page.title
                    color: Theme.ink; font.family: Theme.fontUi; font.pixelSize: 25; font.weight: Font.DemiBold
                }
                Text {
                    Layout.fillWidth: true
                    Layout.maximumWidth: 640
                    text: page.description
                    color: Theme.muted; font.pixelSize: 14; wrapMode: Text.WordWrap
                }
                Flow {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    spacing: 6
                    Repeater {
                        model: page.complexity
                        delegate: Rectangle {
                            required property var modelData
                            width: chip.implicitWidth + 18; height: 26; radius: 6
                            color: Theme.panel; border.color: Theme.line
                            Row {
                                id: chip
                                anchors.centerIn: parent
                                spacing: 7
                                Text { text: modelData[0]; color: Theme.muted; font.pixelSize: 12 }
                                Text {
                                    text: modelData[1]; color: Theme.ink
                                    font.family: Theme.fontMono; font.pixelSize: 12; font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14
                color: Theme.surface
                border.color: Theme.line
                clip: true

                Canvas {
                    anchors.fill: parent
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()
                        ctx.fillStyle = Theme.line.toString()
                        for (let x = 12; x < width; x += 24)
                            for (let y = 12; y < height; y += 24)
                                ctx.fillRect(x - 1, y - 1, 2, 2)
                    }
                }
                Text {
                    x: 16; y: 13
                    text: page.meta
                    color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 12
                }
                Item {
                    id: stageArea
                    anchors.fill: parent
                    anchors.margins: 16
                    anchors.topMargin: 40
                }
                Rectangle {
                    id: toastBox
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 14; opacity: 0
                    width: toastText.implicitWidth + 26; height: 32; radius: 8
                    color: Theme.ink
                    Text { id: toastText; anchors.centerIn: parent; color: Theme.surface; font.pixelSize: 13 }
                    SequentialAnimation {
                        id: toastAnim
                        NumberAnimation { target: toastBox; property: "opacity"; to: 1; duration: 200 }
                        PauseAnimation { duration: 1600 }
                        NumberAnimation { target: toastBox; property: "opacity"; to: 0; duration: 300 }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Flow {
                    id: dockRow
                    Layout.fillWidth: true
                    Layout.minimumWidth: 100
                    spacing: 8
                }
                DsButton {
                    Layout.alignment: Qt.AlignTop
                    text: "Стоп (Esc)"
                    enabled: page.busy
                    onClicked: page.stop()
                }
            }
        }

        Rectangle { Layout.fillHeight: true; implicitWidth: 1; color: Theme.line }

        ColumnLayout {
            Layout.preferredWidth: 300
            Layout.fillWidth: false
            Layout.fillHeight: true
            Layout.margins: 18
            Layout.topMargin: 20
            spacing: 10

            Text {
                text: "ПСЕВДОКОД"
                color: Theme.muted; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1
            }
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: codeCol.implicitHeight + 12
                radius: 10
                color: Theme.surface
                border.color: Theme.line
                clip: true

                Rectangle {
                    width: parent.width; height: 24
                    y: 6 + Math.max(page.currentLine, 0) * 24
                    opacity: page.currentLine >= 0 ? 1 : 0
                    color: Theme.tint(Theme.accent, 0.11)
                    Rectangle { width: 2; height: parent.height; color: Theme.accent }
                    Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
                Column {
                    id: codeCol
                    y: 6
                    width: parent.width
                    Repeater {
                        model: page.code
                        delegate: Row {
                            required property string modelData
                            required property int index
                            height: 24
                            leftPadding: 12
                            spacing: 10
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 16; horizontalAlignment: Text.AlignRight
                                text: index + 1; color: Theme.muted; opacity: 0.6
                                font.family: Theme.fontMono; font.pixelSize: 12
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData; textFormat: Text.PlainText
                                color: index === page.currentLine ? Theme.accent : Theme.ink
                                font.family: Theme.fontMono; font.pixelSize: 12
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 14
                Text {
                    Layout.fillWidth: true
                    text: "ЖУРНАЛ"
                    color: Theme.muted; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1
                }
                Text {
                    text: "очистить"
                    color: clearMa.containsMouse ? Theme.ink : Theme.muted
                    font.pixelSize: 11
                    MouseArea {
                        id: clearMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: logModel.clear()
                    }
                }
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: logModel

                Text {
                    visible: logModel.count === 0
                    text: "Здесь появятся операции"
                    color: Theme.muted; font.pixelSize: 13
                }

                delegate: Item {
                    required property int n
                    required property string t
                    width: ListView.view.width
                    height: 34
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        Text {
                            width: 22; text: n; color: Theme.muted
                            font.family: Theme.fontMono; font.pixelSize: 11
                        }
                        Text { text: t; textFormat: Text.StyledText; color: Theme.ink; font.pixelSize: 13 }
                    }
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.line }
                }
                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 300 }
                }
                displaced: Transition {
                    NumberAnimation { property: "y"; duration: 250; easing.type: Easing.OutCubic }
                }
            }
        }
    }
}