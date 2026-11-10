import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DSVisualizer

ApplicationWindow {
    width: 1320; height: 820
    minimumWidth: 1100; minimumHeight: 680
    visible: true
    title: "Узел — визуализатор структур данных"
    color: Theme.bg

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            Layout.preferredWidth: 220
            Layout.fillWidth: false
            Layout.fillHeight: true
            Layout.leftMargin: 16
            Layout.topMargin: 22
            Layout.bottomMargin: 18
            spacing: 18

            Row {
                leftPadding: 10
                spacing: 11
                Canvas {
                    width: 30; height: 30
                    onPaint: {
                        const c = getContext("2d")
                        c.reset()
                        c.lineWidth = 1.6
                        c.strokeStyle = Theme.edge.toString()
                        c.beginPath(); c.moveTo(15, 9); c.lineTo(9, 21); c.moveTo(15, 9); c.lineTo(21, 21); c.stroke()
                        c.fillStyle = Theme.accent.toString()
                        c.beginPath(); c.arc(15, 8, 4.2, 0, Math.PI * 2); c.fill()
                        c.strokeStyle = Theme.ink.toString()
                        c.beginPath(); c.arc(9, 23, 3.4, 0, Math.PI * 2); c.stroke()
                        c.beginPath(); c.arc(21, 23, 3.4, 0, Math.PI * 2); c.stroke()
                    }
                }
                Column {
                    Text { text: "Узел"; color: Theme.ink; font.pixelSize: 18; font.weight: Font.Bold }
                    Text { text: "визуализатор структур"; color: Theme.muted; font.pixelSize: 11 }
                }
            }

            ListView {
                id: nav
                Layout.fillWidth: true
                Layout.fillHeight: true
                interactive: false
                spacing: 2
                model: ListModel {
                    ListElement { name: "Стек";            key: "LIFO"; group: "Линейные" }
                    ListElement { name: "Очередь";         key: "FIFO"; group: "Линейные" }
                    ListElement { name: "Связный список";  key: "→";    group: "Линейные" }
                    ListElement { name: "Дерево поиска";   key: "BST";  group: "Иерархические" }
                    ListElement { name: "Куча";            key: "min";  group: "Иерархические" }
                    ListElement { name: "Хеш-таблица";     key: "k→v";  group: "Ассоциативные" }
                }
                section.property: "group"
                section.delegate: Text {
                    required property string section
                    text: section.toUpperCase()
                    leftPadding: 10; topPadding: 14; bottomPadding: 6
                    color: Theme.muted; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1
                }
                highlight: Rectangle { radius: 8; color: Theme.surface; border.color: Theme.line }
                highlightMoveDuration: 350
                highlightMoveVelocity: -1

                delegate: Item {
                    id: navItem
                    required property string name
                    required property string key
                    required property int index
                    readonly property bool on: ListView.isCurrentItem
                    width: ListView.view.width
                    height: 36
                    opacity: on || ma.containsMouse ? 1 : 0.72
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Rectangle {
                        x: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 6; height: 6; radius: 3
                        color: navItem.on ? Theme.accent : Theme.edge
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }
                    Text {
                        x: 28
                        anchors.verticalCenter: parent.verticalCenter
                        text: navItem.name; color: Theme.ink; font.pixelSize: 14; font.weight: Font.Medium
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: navItem.key; color: Theme.muted
                        font.family: Theme.fontMono; font.pixelSize: 11
                    }
                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: nav.currentIndex = navItem.index
                    }
                }
            }

        }

        StackLayout {
            id: pages
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: nav.currentIndex
            onCurrentIndexChanged: viewIn.restart()
            transform: Translate { id: shift }

            StackPage {}
            QueuePage {}
            LinkedListPage {}
            StructurePage { group: "Иерархические"; title: "Бинарное дерево поиска"; description: "В разработке." }
            StructurePage { group: "Иерархические"; title: "Куча"; description: "В разработке." }
            StructurePage { group: "Ассоциативные"; title: "Хеш-таблица"; description: "В разработке." }
        }
    }

    ParallelAnimation {
        id: viewIn
        NumberAnimation { target: pages; property: "opacity"; from: 0; to: 1; duration: 350 }
        NumberAnimation { target: shift; property: "y"; from: 8; to: 0; duration: 400; easing.type: Easing.OutCubic }
    }
}