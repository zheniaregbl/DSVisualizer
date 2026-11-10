import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DSVisualizer

StructurePage {
    id: page
    group: "Линейные"
    title: "Очередь"
    description: "Первым пришёл — первым ушёл. Кольцевой буфер: индекс front идёт по кругу, элементы не сдвигаются. Под каждым элементом — его ячейка массива a[i]."
    complexity: [["enqueue", "O(1)*"], ["dequeue", "O(1)"], ["front", "O(1)"]]
    meta: "front = " + (queue.count ? queue.front : "—")
          + "   ·   rear = " + (queue.count ? (queue.front + queue.count - 1) % queue.capacity : "—")
          + "   ·   size = " + queue.count + "   ·   cap = " + queue.capacity
    code: codeEnqueue

    readonly property var codeEnqueue: [
        "if size = cap:",
        "  grow(): cap ← 2·cap, разворачиваем кольцо",
        "rear ← (front + size) mod cap",
        "a[rear] ← x",
        "size ← size + 1"
    ]
    readonly property var codeDequeue: [
        "if size = 0:",
        "  ошибка: очередь пуста",
        "x ← a[front]",
        "front ← (front + 1) mod cap",
        "size ← size − 1",
        "return x"
    ]
    readonly property var codeFront: [
        "if size = 0: ошибка",
        "return a[front]"
    ]

    property int marked: -1
    onStopped: marked = -1
    property color markColor: Theme.accent

    QueueModel { id: queue }

    function doEnqueue() {
        const x = input.value
        const steps = [{ code: codeEnqueue, line: 0 }]
        if (queue.count === queue.capacity) {
            const newCap = queue.capacity ? queue.capacity * 2 : 4
            steps.push({ line: 1, act: () => page.log("grow: cap " + queue.capacity + " → " + newCap) })
        }
        steps.push({ line: 2 })
        steps.push({ line: 3, act: () => { queue.enqueue(x); page.markColor = Theme.accent; page.marked = queue.count - 1 } })
        steps.push({ line: 4, act: () => {
            page.log("enqueue(<b>" + x + "</b>) → a[" + (queue.front + queue.count - 1) % queue.capacity + "]")
            input.text = String(Math.floor(Math.random() * 99) + 1)
        } })
        page.run(steps)
    }

    function doDequeue() {
        if (queue.count === 0) {
            page.run([{ code: codeDequeue, line: 0 },
                      { line: 1, act: () => { page.toast("Очередь пуста"); page.log("dequeue() — очередь пуста"); input.shake() } }])
            return
        }
        page.run([
            { code: codeDequeue, line: 0 },
            { line: 2, act: () => { page.markColor = Theme.remove; page.marked = 0 } },
            { line: 3, act: () => {
                const v = queue.peek(); const slot = queue.front
                queue.dequeue(); page.marked = -1
                page.log("dequeue() → <b>" + v + "</b> из a[" + slot + "]")
            } },
            { line: 4 },
            { line: 5 }
        ])
    }

    function doFront() {
        if (queue.count === 0) {
            page.run([{ code: codeFront, line: 0, act: () => page.toast("Очередь пуста") }])
            return
        }
        page.run([
            { code: codeFront, line: 0 },
            { line: 1, act: () => { page.markColor = Theme.found; page.marked = 0; page.log("front() → <b>" + queue.peek() + "</b>") } }
        ])
    }

    Text {
        anchors.centerIn: parent
        visible: queue.count === 0
        text: "Очередь пуста — введите значение и нажмите Enqueue"
        color: Theme.muted; font.pixelSize: 13
    }

    GridView {
        id: grid
        anchors.fill: parent
        anchors.topMargin: 8
        model: queue
        cellWidth: 76
        cellHeight: 104
        clip: true
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar {}

        delegate: Item {
            id: cell
            required property int value
            required property int slot
            required property int index
            readonly property bool isFront: index === 0
            readonly property bool isRear: index === queue.count - 1
            readonly property bool isMarked: index === page.marked
            width: grid.cellWidth
            height: grid.cellHeight

            Text {
                anchors.horizontalCenter: box.horizontalCenter
                anchors.bottom: box.top
                anchors.bottomMargin: 6
                text: cell.isFront && cell.isRear ? "front·rear" : cell.isFront ? "front" : cell.isRear ? "rear" : ""
                color: Theme.accent
                font.family: Theme.fontMono; font.pixelSize: 11
            }
            Rectangle {
                id: box
                x: 4; y: 24
                width: 60; height: 52; radius: 8
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
                anchors.horizontalCenter: box.horizontalCenter
                anchors.top: box.bottom
                anchors.topMargin: 6
                text: "a[" + cell.slot + "]"
                color: Theme.muted; opacity: 0.75
                font.family: Theme.fontMono; font.pixelSize: 11
            }
        }

        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250 }
                NumberAnimation { property: "scale"; from: 0.6; to: 1; duration: 350; easing.type: Easing.OutBack }
            }
        }
        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; to: 0; duration: 300 }
                NumberAnimation { property: "y"; to: -60; duration: 300; easing.type: Easing.InCubic }
            }
        }
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 300; easing.type: Easing.OutCubic }
        }
    }

    dock: [
        DsInput { id: input; label: "значение"; onAccepted: page.doEnqueue() },
        DsButton { text: "Enqueue"; primary: true; enabled: !page.busy; onClicked: page.doEnqueue() },
        DsButton { text: "Dequeue"; enabled: !page.busy; onClicked: page.doDequeue() },
        DsButton { text: "Front";   enabled: !page.busy; onClicked: page.doFront() },
        Item { Layout.fillWidth: true },
        DsButton {
            text: "Очистить"; ghost: true; enabled: !page.busy
            onClicked: { queue.clear(); page.marked = -1; page.currentLine = -1; page.log("clear()") }
        }
    ]
}
