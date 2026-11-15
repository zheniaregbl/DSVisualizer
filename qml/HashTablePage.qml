import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DSVisualizer

StructurePage {
    id: page
    group: "Ассоциативные"
    title: "Хеш-таблица"
    description: "Хеш-функция выбирает одну из семи корзин. Ключи с одинаковым хешем хранятся в цепочке. Повторные ключи не добавляются."
    complexity: [["в среднем", "O(1 + α)"], ["худший случай", "O(n)"]]
    meta: "size = " + table.count + "   ·   m = 7   ·   α = n / m = " + (table.count / table.bucketCount).toFixed(2)
    code: codeInsert
    readonly property var codeInsert: [
        "i ← ((x % 7) + 7) % 7",
        "for node in bucket[i]:",
        "  if node.key = x: return",
        "добавить x в конец цепочки"
    ]
    readonly property var codeFind: [
        "i ← ((x % 7) + 7) % 7",
        "for node in bucket[i]:",
        "  if node.key = x: return node",
        "return null"
    ]
    readonly property var codeRemove: [
        "i ← ((x % 7) + 7) % 7",
        "prev ← null; cur ← bucket[i]",
        "while cur ≠ null and cur.key ≠ x:",
        "  prev ← cur; cur ← cur.next",
        "if cur = null: return",
        "if prev: prev.next ← cur.next",
        "else: bucket[i] ← cur.next",
        "delete cur; size ← size − 1"
    ]
    property int markedBucket: -1
    property int markedNode: -1
    property color markColor: Theme.compare
    property string hashText: ""
    HashTableModel { id: table }
    function resetMarks() { markedBucket = -1; markedNode = -1; hashText = "" }
    onStopped: resetMarks()
    onVisibleChanged: { if (!visible && busy) stop() }

    function mark(bucket, node, color) {
        markedBucket = bucket; markedNode = node; markColor = color
        view.contentY = Math.max(0, Math.min(bucket * 66 - view.height / 2 + 33, view.contentHeight - view.height))
        view.contentX = Math.max(0, Math.min(node < 0 ? 0 : 108 + node * 100 - view.width / 2, view.contentWidth - view.width))
    }
    function startSteps(value, sourceCode) {
        const bucket = table.bucketIndex(value)
        return [{code: sourceCode, line: 0, act: () => {
            page.mark(bucket, -1, Theme.accent)
            page.hashText = "h(" + value + ") = " + bucket
            page.log(page.hashText)
        }}]
    }
    function walk(steps, value, removing) {
        const bucket = table.bucketIndex(value)
        const values = table.bucketValues(bucket)
        for (let i = 0; i < values.length; ++i) {
            const position = i, key = values[i]
            steps.push({line: removing ? 2 : 1, act: () => {
                page.mark(bucket, position, Theme.compare)
                page.log("Сравнить " + value + " и " + key)
            }})
            if (key === value) return i
            steps.push({line: removing ? 3 : 2})
        }
        return -1
    }
    function doInsert() {
        if (busy) return
        const value = input.value, bucket = table.bucketIndex(value)
        if (table.count >= 100 && !table.contains(value)) { toast("Лимит визуализации: 100 ключей"); return }
        const steps = startSteps(value, codeInsert)
        const found = walk(steps, value, false)
        if (found >= 0) {
            steps.push({line: 2, act: () => {
                page.mark(bucket, found, Theme.found)
                page.toast("Ключ уже существует"); page.log("insert(" + value + ") — дубликат")
            }})
        } else {
            steps.push({line: 3, act: () => {
                table.insert(value)
                page.mark(bucket, table.bucketValues(bucket).length - 1, Theme.accent)
                page.log("insert(<b>" + value + "</b>) → корзина " + bucket)
            }})
        }
        run(steps)
    }
    function doFind() {
        if (busy) return
        const value = input.value, bucket = table.bucketIndex(value)
        const steps = startSteps(value, codeFind)
        const found = walk(steps, value, false)
        steps.push({line: found >= 0 ? 2 : 3, act: () => {
            page.mark(bucket, found, Theme.found)
            if (found < 0) page.toast("Ключ не найден")
            page.log("search(<b>" + value + "</b>) → " + (found >= 0 ? "найден" : "null"))
        }})
        run(steps)
    }
    function doRemove() {
        if (busy) return
        const value = input.value, bucket = table.bucketIndex(value)
        const steps = startSteps(value, codeRemove)
        steps.push({line: 1})
        const found = walk(steps, value, true)
        if (found < 0) {
            steps.push({line: 4, act: () => {
                page.mark(bucket, -1, Theme.compare)
                page.toast("Ключ не найден"); page.log("remove(" + value + ") — не найден")
            }})
        } else {
            steps.push({line: found === 0 ? 6 : 5, act: () => page.mark(bucket, found, Theme.remove)})
            steps.push({line: 7, act: () => {
                table.remove(value); page.markedNode = -1
                page.log("remove(<b>" + value + "</b>)")
            }})
        }
        run(steps)
    }

    Text {
        id: formula
        text: page.hashText.length ? page.hashText : "h(x) = ((x % 7) + 7) % 7"
        color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 13
    }
    Flickable {
        id: view
        anchors.fill: parent; anchors.topMargin: 30
        contentWidth: Math.max(width, 180 + table.longestChain * 100)
        contentHeight: table.bucketCount * 66
        clip: true
        ScrollBar.horizontal: ScrollBar {}
        ScrollBar.vertical: ScrollBar {}
        Column {
            width: view.contentWidth
            Repeater {
                model: table
                delegate: Item {
                    id: bucketRow
                    required property int index
                    required property var values
                    width: view.contentWidth; height: 66
                    Rectangle {
                        x: 4; y: 10; width: 56; height: 38; radius: 6
                        color: bucketRow.index === page.markedBucket ? Theme.tint(Theme.accent, 0.14) : Theme.panel
                        border.color: bucketRow.index === page.markedBucket ? Theme.accent : Theme.line
                        Text {
                            anchors.centerIn: parent; text: "[" + bucketRow.index + "]"
                            color: Theme.ink; font.family: Theme.fontMono; font.pixelSize: 13
                        }
                    }
                    Text {
                        x: 70; y: 17; text: "→"
                        color: Theme.edge; font.pixelSize: 18
                    }
                    Row {
                        x: 108; y: 10
                        Repeater {
                            model: bucketRow.values
                            delegate: Item {
                                id: node
                                required property int index
                                required property int modelData
                                readonly property bool marked: bucketRow.index === page.markedBucket && index === page.markedNode
                                width: 100; height: 38
                                Rectangle {
                                    width: 64; height: 38; radius: 8
                                    color: node.marked ? Theme.tint(page.markColor, 0.14) : Theme.node
                                    border.color: node.marked ? page.markColor : Theme.edge
                                    border.width: node.marked ? 2 : 1
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    Text {
                                        anchors.centerIn: parent; text: node.modelData
                                        color: node.marked ? page.markColor : Theme.ink
                                        font.family: Theme.fontMono; font.pixelSize: 15
                                    }
                                }
                                Text { x: 74; y: 7; text: "→"; color: Theme.edge; font.pixelSize: 18 }
                            }
                        }
                        Text {
                            height: 38; verticalAlignment: Text.AlignVCenter
                            text: "null"; color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
    dock: [
        DsInput { id: input; label: "ключ"; onAccepted: page.doInsert() },
        DsButton { text: "Вставить"; primary: true; enabled: !page.busy; onClicked: page.doInsert() },
        DsButton { text: "Найти"; enabled: !page.busy; onClicked: page.doFind() },
        DsButton { text: "Удалить"; enabled: !page.busy; onClicked: page.doRemove() },
        Item { Layout.fillWidth: true },
        DsButton {
            text: "Очистить"; ghost: true; enabled: !page.busy
            onClicked: { table.clear(); page.resetMarks(); page.currentLine = -1; page.log("clear()") }
        }
    ]
}
