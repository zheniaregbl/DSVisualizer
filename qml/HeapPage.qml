import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DSVisualizer

StructurePage {
    id: page
    group: "Иерархические"
    title: "Двоичная min-куча"
    description: "Родитель не больше своих детей, поэтому минимум всегда в корне. Дерево хранится в массиве. Повторные значения разрешены."
    complexity: [["вставка", "O(log n)"], ["извлечь min", "O(log n)"], ["минимум", "O(1)"]]
    meta: "size = " + heap.count + "   ·   parent(i) = (i − 1) div 2"
    code: codeInsert
    readonly property var codeInsert: [
        "a.append(x); i ← size − 1",
        "while i > 0:",
        "  p ← (i − 1) div 2",
        "  if a[p] ≤ a[i]: break",
        "  swap(a[p], a[i]); i ← p"
    ]
    readonly property var codeExtract: [
        "if size = 0: ошибка",
        "result ← a[0]",
        "a[0] ← a.back(); a.pop_back()",
        "i ← 0",
        "while у i есть дети:",
        "  c ← меньший ребёнок; сравнить",
        "  если a[c] < a[i]: swap; i ← c",
        "  иначе: break",
        "return result"
    ]
    property int firstMarked: -1
    property int secondMarked: -1
    property color markColor: Theme.compare
    readonly property int levels: heap.count ? Math.floor(Math.log2(heap.count)) + 1 : 0

    HeapModel { id: heap; onCountChanged: { if (links) links.requestPaint() } }
    function resetMarks() { firstMarked = -1; secondMarked = -1 }
    onStopped: { heap.cancel(); resetMarks(); page.log("Незавершённая операция отменена") }
    onVisibleChanged: { if (!visible && busy) stop() }

    function animate(operations, sourceCode, resultText, finishLine) {
        const steps = [{code: sourceCode, line: 0, act: () => page.resetMarks()}]
        for (let i = 0; i < operations.length; ++i) {
            const index = i, operation = operations[i]
            steps.push({line: operation.line, act: () => {
                heap.showStep(index)
                page.firstMarked = operation.first
                page.secondMarked = operation.second
                page.markColor = operation.swapping ? Theme.accent : Theme.compare
                page.log(operation.text)
            }})
        }
        steps.push({line: finishLine, act: () => {
            heap.finish()
            page.resetMarks()
            page.log(resultText)
        }})
        run(steps)
    }
    function doInsert() {
        if (busy) return
        if (heap.count >= 63) { toast("Лимит визуализации: 63 элемента"); return }
        const value = input.value
        animate(heap.prepareInsert(value), codeInsert, "insert(<b>" + value + "</b>)", -1)
    }
    function doExtract() {
        if (busy) return
        if (!heap.count) {
            run([{code: codeExtract, line: 0, act: () => { page.toast("Куча пуста"); page.log("extractMin() — куча пуста") }}])
            return
        }
        const result = heap.minimum()
        animate(heap.prepareExtract(), codeExtract, "extractMin() → <b>" + result + "</b>", 8)
    }
    function doMinimum() {
        if (busy) return
        run([{code: ["if size = 0: ошибка", "return a[0]"], line: heap.count ? 1 : 0, act: () => {
            page.resetMarks()
            if (!heap.count) { page.toast("Куча пуста"); return }
            page.firstMarked = 0; page.markColor = Theme.found
            page.log("minimum() → <b>" + heap.minimum() + "</b>")
        }}])
    }
    function depth(index) { return Math.floor(Math.log2(index + 1)) }
    function nodeX(index) {
        const level = depth(index)
        const firstInLevel = Math.pow(2, level) - 1
        return scene.width * (index - firstInLevel + 0.5) / Math.pow(2, level)
    }
    function nodeY(index) { return 42 + depth(index) * 88 }

    Text {
        anchors.centerIn: parent
        visible: heap.count === 0
        text: "Куча пуста — введите значение и нажмите «Вставить»"
        color: Theme.muted; font.pixelSize: 13
    }
    Flickable {
        id: view
        anchors.fill: parent
        anchors.bottomMargin: 80
        clip: true
        contentWidth: Math.max(width, Math.pow(2, Math.max(0, page.levels - 1)) * 68)
        contentHeight: Math.max(height, page.levels * 88 + 32)
        ScrollBar.horizontal: ScrollBar {}
        ScrollBar.vertical: ScrollBar {}
        Item {
            id: scene
            width: view.contentWidth; height: view.contentHeight
            Canvas {
                id: links
                anchors.fill: parent
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    const c = getContext("2d")
                    c.reset(); c.strokeStyle = Theme.edge.toString(); c.lineWidth = 1.6
                    for (let i = 1; i < heap.count; ++i) {
                        const parent = Math.floor((i - 1) / 2)
                        c.beginPath()
                        c.moveTo(page.nodeX(parent), page.nodeY(parent))
                        c.lineTo(page.nodeX(i), page.nodeY(i))
                        c.stroke()
                    }
                }
            }
            Repeater {
                model: heap
                delegate: Rectangle {
                    id: node
                    required property int index
                    required property int value
                    readonly property bool marked: index === page.firstMarked || index === page.secondMarked
                    x: page.nodeX(index) - 24; y: page.nodeY(index) - 24
                    width: 48; height: 48; radius: 24
                    color: marked ? Theme.tint(page.markColor, 0.14) : Theme.node
                    border.color: marked ? page.markColor : Theme.edge
                    border.width: marked ? 2 : 1
                    Text {
                        anchors.centerIn: parent; text: node.value
                        color: node.marked ? page.markColor : Theme.ink
                        font.family: Theme.fontMono; font.pixelSize: 15
                    }
                    Text {
                        anchors.top: parent.bottom; anchors.topMargin: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: node.index === 0 ? "[0] · min" : "[" + node.index + "]"
                        color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 11
                    }
                }
            }
        }
    }
    ListView {
        id: arrayView
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        height: 70; orientation: ListView.Horizontal; spacing: 6
        model: heap; clip: true
        ScrollBar.horizontal: ScrollBar {}
        delegate: Item {
            id: cell
            required property int index
            required property int value
            width: 48; height: 56
            Rectangle {
                width: 48; height: 34; radius: 6
                color: Theme.node
                border.color: cell.index === page.firstMarked || cell.index === page.secondMarked ? page.markColor : Theme.edge
                Text {
                    anchors.centerIn: parent; text: cell.value
                    color: Theme.ink; font.family: Theme.fontMono; font.pixelSize: 14
                }
            }
            Text {
                y: 38; anchors.horizontalCenter: parent.horizontalCenter
                text: cell.index; color: Theme.muted
                font.family: Theme.fontMono; font.pixelSize: 11
            }
        }
    }
    dock: [
        DsInput { id: input; label: "значение"; onAccepted: page.doInsert() },
        DsButton { text: "Вставить"; primary: true; enabled: !page.busy; onClicked: page.doInsert() },
        DsButton { text: "Извлечь min"; enabled: !page.busy; onClicked: page.doExtract() },
        DsButton { text: "Минимум"; enabled: !page.busy; onClicked: page.doMinimum() },
        Item { Layout.fillWidth: true },
        DsButton {
            text: "Очистить"; ghost: true; enabled: !page.busy
            onClicked: { heap.clear(); page.resetMarks(); page.currentLine = -1; page.log("clear()") }
        }
    ]
}
