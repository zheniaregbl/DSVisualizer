import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DSVisualizer

StructurePage {
    id: page
    group: "Линейные"
    title: "Связный список"
    description: "Цепочка узлов: каждый хранит значение и указатель на следующий. Вставка в начало и конец — O(1), а до середины приходится идти от head по ссылкам."
    complexity: [["в начало", "O(1)"], ["в конец", "O(1)"], ["доступ [i]", "O(n)"], ["вставка/удаление [i]", "O(n)"], ["поиск", "O(n)"]]
    meta: "size = " + list.count + "   ·   head → [0]   ·   tail → [" + (list.count - 1) + "]"
    code: codePushFront

    readonly property var codePushFront: [
        "node ← new Node(x)",
        "node.next ← head",
        "head ← node",
        "if tail = null: tail ← node"
    ]
    readonly property var codePushBack: [
        "node ← new Node(x)",
        "if tail ≠ null: tail.next ← node",
        "else: head ← node",
        "tail ← node"
    ]
    readonly property var codeInsert: [
        "if i = 0: pushFront(x); return",
        "prev ← head",
        "repeat i − 1 times: prev ← prev.next",
        "node ← new Node(x, prev.next)",
        "prev.next ← node"
    ]
    readonly property var codeRemove: [
        "if i = 0: head ← head.next; return",
        "prev ← head",
        "repeat i − 1 times: prev ← prev.next",
        "victim ← prev.next",
        "prev.next ← victim.next",
        "if victim = tail: tail ← prev"
    ]
    readonly property var codeGet: [
        "if i < 0 or i ≥ size: ошибка",
        "cur ← head",
        "repeat i times: cur ← cur.next",
        "return cur.value"
    ]
    readonly property var codeFind: [
        "cur ← head; i ← 0",
        "while cur ≠ null:",
        "  if cur.value = x: return i",
        "  cur ← cur.next; i ← i + 1",
        "return −1"
    ]

    property int marked: -1
    onStopped: marked = -1
    property color markColor: Theme.accent

    LinkedListModel { id: list }

    function mark(i, c) { page.markColor = c; page.marked = i }
    function nextValue() { valueBox.text = String(Math.floor(Math.random() * 99) + 1) }

    function walkTo(steps, last) {
        steps.push({ line: 1, act: () => page.mark(0, Theme.compare) })
        for (let k = 1; k <= last; ++k) {
            const kk = k
            steps.push({ line: 2, act: () => page.mark(kk, Theme.compare) })
        }
    }

    function badIndex(code, i, max) {
        page.run([{ code: code, line: 0, act: () => {
            page.toast("Индекс " + i + " вне диапазона [0, " + max + "]")
            indexBox.shake()
        } }])
    }

    function doPushFront() {
        const x = valueBox.value
        page.run([
            { code: codePushFront, line: 0 },
            { line: 1 },
            { line: 2, act: () => { list.pushFront(x); page.mark(0, Theme.accent) } },
            { line: 3, act: () => { page.log("pushFront(<b>" + x + "</b>)"); page.nextValue() } }
        ])
    }

    function doPushBack() {
        const x = valueBox.value
        page.run([
            { code: codePushBack, line: 0 },
            { line: list.count ? 1 : 2 },
            { line: 3, act: () => {
                list.pushBack(x); page.mark(list.count - 1, Theme.accent)
                page.log("pushBack(<b>" + x + "</b>)"); page.nextValue()
            } }
        ])
    }

    function doInsert() {
        const x = valueBox.value, i = indexBox.value
        if (i < 0 || i > list.count) { badIndex(codeInsert, i, list.count); return }
        const steps = [{ code: codeInsert, line: 0 }]
        if (i === 0) {
            steps.push({ line: 0, act: () => { list.pushFront(x); page.mark(0, Theme.accent) } })
        } else {
            walkTo(steps, i - 1)
            steps.push({ line: 3 })
            steps.push({ line: 4, act: () => { list.insertAt(i, x); page.mark(i, Theme.accent) } })
        }
        steps.push({ act: () => { page.log("insertAt(" + i + ", <b>" + x + "</b>)"); page.nextValue() } })
        page.run(steps)
    }

    function doRemove() {
        const i = indexBox.value
        if (list.count === 0) {
            page.run([{ code: codeRemove, line: 0, act: () => page.toast("Список пуст") }])
            return
        }
        if (i < 0 || i >= list.count) { badIndex(codeRemove, i, list.count - 1); return }
        const steps = [{ code: codeRemove, line: 0 }]
        if (i > 0) {
            walkTo(steps, i - 1)
            steps.push({ line: 3, act: () => page.mark(i, Theme.remove) })
            steps.push({ line: 4 })
        } else {
            steps.push({ line: 0, act: () => page.mark(0, Theme.remove) })
        }
        const finish = { act: () => {
            list.removeAt(i); page.marked = -1
            page.log("removeAt(" + i + ")")
        } }
        if (i > 0 && i === list.count - 1) finish.line = 5
        steps.push(finish)
        page.run(steps)
    }

    function doGet() {
        const i = indexBox.value
        if (list.count === 0) {
            page.run([{ code: codeGet, line: 0, act: () => page.toast("Список пуст") }])
            return
        }
        if (i < 0 || i >= list.count) { badIndex(codeGet, i, list.count - 1); return }
        const steps = [{ code: codeGet, line: 0 },
                       { line: 1, act: () => page.mark(0, Theme.compare) }]
        for (let k = 1; k <= i; ++k) {
            const kk = k
            steps.push({ line: 2, act: () => page.mark(kk, Theme.compare) })
        }
        steps.push({ line: 3, act: () => {
            page.mark(i, Theme.found)
            page.log("get(" + i + ") → <b>" + list.at(i) + "</b>, пройдено узлов: " + (i + 1))
        } })
        page.run(steps)
    }

    function doFind() {
        const x = valueBox.value
        const target = list.find(x)
        const steps = [{ code: codeFind, line: 0 }]
        const last = target >= 0 ? target : list.count - 1
        for (let k = 0; k <= last; ++k) {
            const kk = k
            steps.push({ line: 1, act: () => page.mark(kk, Theme.compare) })
            if (kk === target)
                steps.push({ line: 2, act: () => {
                    page.mark(kk, Theme.found)
                    page.log("find(<b>" + x + "</b>) → " + kk + ", пройдено узлов: " + (kk + 1))
                } })
            else
                steps.push({ line: 3 })
        }
        if (target < 0)
            steps.push({ line: 4, act: () => {
                page.marked = -1
                page.toast("Не найдено")
                page.log("find(<b>" + x + "</b>) → −1, пройден весь список")
            } })
        page.run(steps)
    }

    Text {
        anchors.centerIn: parent
        visible: list.count === 0
        text: "Список пуст — добавьте элемент в начало или в конец"
        color: Theme.muted; font.pixelSize: 13
    }

    GridView {
        id: grid
        anchors.fill: parent
        anchors.topMargin: 8
        model: list
        cellWidth: 116
        cellHeight: 104
        clip: true
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar {}

        delegate: Item {
            id: cell
            required property int value
            required property int index
            readonly property bool isHead: index === 0
            readonly property bool isTail: index === list.count - 1
            readonly property bool isMarked: index === page.marked
            width: grid.cellWidth
            height: grid.cellHeight

            Text {
                anchors.horizontalCenter: box.horizontalCenter
                anchors.bottom: box.top
                anchors.bottomMargin: 6
                text: cell.isHead && cell.isTail ? "head·tail" : cell.isHead ? "head" : cell.isTail ? "tail" : ""
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
                anchors.left: box.right
                anchors.leftMargin: 6
                anchors.verticalCenter: box.verticalCenter
                text: cell.isTail ? "→ null" : "→"
                color: cell.isTail ? Theme.muted : Theme.edge
                font.family: Theme.fontMono; font.pixelSize: cell.isTail ? 12 : 18
            }
            Text {
                anchors.horizontalCenter: box.horizontalCenter
                anchors.top: box.bottom
                anchors.topMargin: 6
                text: "[" + cell.index + "]"
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
                NumberAnimation { property: "y"; to: 60; duration: 300; easing.type: Easing.InCubic }
            }
        }
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 300; easing.type: Easing.OutCubic }
        }
    }

    dock: [
        DsInput { id: valueBox; label: "значение"; onAccepted: page.doPushBack() },
        DsInput { id: indexBox; label: "индекс"; text: "0" },
        DsButton { text: "В начало"; primary: true; enabled: !page.busy; onClicked: page.doPushFront() },
        DsButton { text: "В конец";  enabled: !page.busy; onClicked: page.doPushBack() },
        DsButton { text: "Вставить"; enabled: !page.busy; onClicked: page.doInsert() },
        DsButton { text: "Удалить";  enabled: !page.busy; onClicked: page.doRemove() },
        DsButton { text: "Найти значение"; enabled: !page.busy; onClicked: page.doFind() },
        DsButton { text: "Элемент [i]";    enabled: !page.busy; onClicked: page.doGet() },
        Item { Layout.fillWidth: true },
        DsButton {
            text: "Очистить"; ghost: true; enabled: !page.busy
            onClicked: { list.clear(); page.marked = -1; page.currentLine = -1; page.log("clear()") }
        }
    ]
}
