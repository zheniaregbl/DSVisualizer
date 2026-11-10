import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DSVisualizer

StructurePage {
    id: page
    group: "Линейные"
    title: "Стек"
    description: "Последним пришёл — первым ушёл. Элементы кладутся и снимаются только с вершины. Основа — динамический массив с удвоением ёмкости."
    complexity: [["push", "O(1)*"], ["pop", "O(1)"], ["peek", "O(1)"]]
    meta: "top = " + (stack.count - 1) + "   ·   size = " + stack.count + "   ·   cap = " + stack.capacity
    code: codePush

    readonly property var codePush: [
        "if size = cap:",
        "  grow(): cap ← 2·cap, копируем",
        "a[size] ← x",
        "size ← size + 1"
    ]
    readonly property var codePop: [
        "if size = 0:",
        "  ошибка: стек пуст",
        "size ← size − 1",
        "return a[size]"
    ]
    readonly property var codePeek: [
        "if size = 0: ошибка",
        "return a[size − 1]"
    ]

    property int marked: -1
    onStopped: marked = -1
    property color markColor: Theme.accent

    StackModel { id: stack }

    function doPush() {
        const x = input.value
        const steps = [{ code: codePush, line: 0 }]
        if (stack.count === stack.capacity) {
            const newCap = stack.capacity ? stack.capacity * 2 : 4
            steps.push({ line: 1, act: () => page.log("grow: cap " + stack.capacity + " → " + newCap) })
        }
        steps.push({ line: 2, act: () => { stack.push(x); page.markColor = Theme.accent; page.marked = stack.count - 1 } })
        steps.push({ line: 3, act: () => {
            page.log("push(<b>" + x + "</b>) → a[" + (stack.count - 1) + "]")
            input.text = String(Math.floor(Math.random() * 99) + 1)
        } })
        page.run(steps)
    }

    function doPop() {
        if (stack.count === 0) {
            page.run([{ code: codePop, line: 0 },
                      { line: 1, act: () => { page.toast("Стек пуст"); page.log("pop() — стек пуст"); input.shake() } }])
            return
        }
        const top = stack.count - 1
        page.run([
            { code: codePop, line: 0 },
            { line: 2, act: () => { page.markColor = Theme.remove; page.marked = top } },
            { line: 3, act: () => { const v = stack.peek(); stack.pop(); page.marked = -1; page.log("pop() → <b>" + v + "</b>") } }
        ])
    }

    function doPeek() {
        if (stack.count === 0) {
            page.run([{ code: codePeek, line: 0, act: () => page.toast("Стек пуст") }])
            return
        }
        page.run([
            { code: codePeek, line: 0 },
            { line: 1, act: () => { page.markColor = Theme.found; page.marked = stack.count - 1; page.log("peek() → <b>" + stack.peek() + "</b>") } }
        ])
    }

    Text {
        anchors.centerIn: parent
        visible: stack.count === 0
        text: "Стек пуст — введите значение и нажмите Push"
        color: Theme.muted; font.pixelSize: 13
    }

    ListView {
        id: view
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 320
        model: stack
        verticalLayoutDirection: ListView.BottomToTop
        spacing: 6
        clip: true
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar {}
        onCountChanged: positionViewAtEnd()

        delegate: Item {
            id: cell
            required property int value
            required property int index
            readonly property bool isTop: index === stack.count - 1
            readonly property bool isMarked: index === page.marked
            width: ListView.view.width
            height: 40

            Text {
                visible: cell.isTop
                anchors.right: box.left
                anchors.rightMargin: 12
                anchors.verticalCenter: box.verticalCenter
                text: "top →"; color: Theme.accent
                font.family: Theme.fontMono; font.pixelSize: 12
            }
            Rectangle {
                id: box
                anchors.centerIn: parent
                width: 150; height: 38; radius: 8
                color: cell.isMarked ? Theme.tint(page.markColor, 0.14) : Theme.node
                border.width: cell.isMarked ? 2 : 1
                border.color: cell.isMarked ? page.markColor : Theme.edge
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }
                Text {
                    anchors.centerIn: parent
                    text: cell.value
                    color: cell.isMarked ? page.markColor : Theme.ink
                    font.family: Theme.fontMono; font.pixelSize: 15; font.weight: Font.DemiBold
                }
            }
            Text {
                anchors.left: box.right
                anchors.leftMargin: 14
                anchors.verticalCenter: box.verticalCenter
                text: cell.index; color: Theme.muted; opacity: 0.75
                font.family: Theme.fontMono; font.pixelSize: 12
            }
        }

        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250 }
                NumberAnimation { property: "y"; from: -40; duration: 450; easing.type: Easing.OutBack }
            }
        }
        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; to: 0; duration: 300 }
                NumberAnimation { property: "x"; to: 200; duration: 300; easing.type: Easing.InCubic }
            }
        }
        displaced: Transition { NumberAnimation { property: "y"; duration: 250 } }
    }

    dock: [
        DsInput { id: input; label: "значение"; onAccepted: page.doPush() },
        DsButton { text: "Push"; primary: true; enabled: !page.busy; onClicked: page.doPush() },
        DsButton { text: "Pop";  enabled: !page.busy; onClicked: page.doPop() },
        DsButton { text: "Peek"; enabled: !page.busy; onClicked: page.doPeek() },
        Item { Layout.fillWidth: true },
        DsButton {
            text: "Очистить"; ghost: true; enabled: !page.busy
            onClicked: { stack.clear(); page.marked = -1; page.currentLine = -1; page.log("clear()") }
        }
    ]
}