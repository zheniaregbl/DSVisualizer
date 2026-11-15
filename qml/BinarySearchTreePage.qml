import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DSVisualizer

StructurePage {
    id: page
    group: "Иерархические"
    title: "Бинарное дерево поиска"
    description: "Слева — меньшие ключи, справа — большие. Без балансировки: скорость зависит от высоты дерева. Повторные ключи не добавляются."
    complexity: [["вставка / поиск / удаление", "O(h)"], ["худший случай", "O(n)"], ["обход", "O(n)"]]
    meta: "size = " + tree.count + "   ·   уровней = " + tree.height
    code: codeInsert
    readonly property var codeInsert: [
        "cur ← root",
        "while cur ≠ null:",
        "  if x = cur.key: return",
        "  cur ← x < key ? left : right",
        "в свободную ссылку ← Node(x)"
    ]
    readonly property var codeFind: [
        "cur ← root",
        "while cur ≠ null:",
        "  if x = cur.key: return cur",
        "  cur ← x < key ? left : right",
        "return null"
    ]
    readonly property var codeRemove: [
        "z ← search(x)",
        "if z = null: return",
        "if у z меньше двух детей:",
        "  заменить z его ребёнком",
        "else: s ← min(z.right)",
        "  z.key ← s.key",
        "  заменить s на s.right"
    ]
    readonly property var codeInorder: [
        "inorder(v):",
        "  if v = null: return",
        "  inorder(v.left)",
        "  visit(v)",
        "  inorder(v.right)"
    ]
    property var marked: null
    property color markColor: Theme.accent
    property string traversal: ""
    onStopped: marked = null
    onVisibleChanged: { if (!visible && busy) stop() }

    BinarySearchTreeModel {
        id: tree
        onCountChanged: { if (links) links.requestPaint() }
    }
    function mark(value, color) {
        marked = value
        markColor = color
        const values = tree.inorder()
        const index = values.indexOf(value)
        if (index >= 0) {
            const target = index * 72 + 18
            view.contentX = Math.max(0, Math.min(target - view.width / 2, view.contentWidth - view.width))
            const targetY = (tree.path(value).length - 1) * 88 + 40
            view.contentY = Math.max(0, Math.min(targetY - view.height / 2, view.contentHeight - view.height))
        }
    }
    function walk(steps, value, searchCode) {
        const path = tree.path(value)
        steps.push({code: searchCode, line: 0})
        for (let i = 0; i < path.length; ++i) {
            const key = path[i]
            steps.push({line: 1, act: () => page.mark(key, Theme.compare)})
            steps.push({line: key === value ? 2 : 3})
        }
    }
    function doInsert() {
        if (busy) return
        const x = input.value
        if (tree.count >= 100 && !tree.contains(x)) { toast("Лимит визуализации: 100 узлов"); return }
        const steps = []
        walk(steps, x, codeInsert)
        if (tree.contains(x)) {
            steps.push({line: 2, act: () => { page.mark(x, Theme.found); page.toast("Ключ уже существует"); page.log("insert(" + x + ") — дубликат") }})
        } else {
            steps.push({line: 4, act: () => {
                tree.insert(x); page.traversal = ""; page.mark(x, Theme.accent)
                page.log("insert(<b>" + x + "</b>)")
            }})
        }
        run(steps)
    }
    function doFind() {
        if (busy) return
        const x = input.value, found = tree.contains(x), steps = []
        walk(steps, x, codeFind)
        steps.push({line: found ? 2 : 4, act: () => {
            if (found) page.mark(x, Theme.found)
            else { page.marked = null; page.toast("Ключ не найден") }
            page.log("search(<b>" + x + "</b>) → " + (found ? "найден" : "null"))
        }})
        run(steps)
    }
    function doRemove() {
        if (busy) return
        const x = input.value, steps = []
        walk(steps, x, codeFind)
        steps.push({code: codeRemove, line: 0})
        if (!tree.contains(x)) {
            steps.push({line: 1, act: () => { page.marked = null; page.toast("Ключ не найден"); page.log("remove(" + x + ") → не найден") }})
        } else {
            steps.push({line: 2, act: () => page.mark(x, Theme.remove)})
            const successor = tree.successorPath(x)
            for (let i = 0; i < successor.length; ++i) {
                const key = successor[i]
                steps.push({line: 4, act: () => page.mark(key, Theme.compare)})
            }
            if (successor.length) steps.push({line: 5, act: () => page.log("Преемник: <b>" + successor[successor.length - 1] + "</b>")})
            steps.push({line: successor.length ? 6 : 3, act: () => {
                tree.remove(x); page.marked = null; page.traversal = ""
                page.log("remove(<b>" + x + "</b>)")
            }})
        }
        run(steps)
    }
    function doInorder() {
        if (busy) return
        traversal = ""
        const values = tree.inorder()
        if (!values.length) { toast("Дерево пусто"); return }
        const steps = [{code: codeInorder, line: 0}]
        for (let i = 0; i < values.length; ++i) {
            const key = values[i]
            steps.push({line: 3, act: () => {
                page.mark(key, Theme.found)
                page.traversal += (page.traversal.length ? " → " : "") + key
                page.log("visit(<b>" + key + "</b>)")
            }})
        }
        run(steps)
    }

    Text {
        anchors.centerIn: parent
        visible: tree.count === 0
        text: "Дерево пусто — введите значение и нажмите «Вставить»"
        color: Theme.muted; font.pixelSize: 13
    }
    Flickable {
        id: view
        anchors.fill: parent
        anchors.bottomMargin: result.visible ? result.height + 8 : 0
        contentWidth: Math.max(width, tree.count * 72 + 36)
        contentHeight: Math.max(height, tree.height * 88 + 36)
        clip: true
        ScrollBar.horizontal: ScrollBar {}
        ScrollBar.vertical: ScrollBar {}
        Canvas {
            id: links
            width: view.contentWidth; height: view.contentHeight
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onPaint: {
                const c = getContext("2d")
                c.reset(); c.strokeStyle = Theme.edge.toString(); c.lineWidth = 1.6
                const edges = tree.edges()
                const offset = (width - tree.count * 72) / 2 + 36
                for (let i = 0; i < edges.length; ++i) {
                    const e = edges[i]
                    c.beginPath()
                    c.moveTo(offset + e.from * 72, 40 + e.fromDepth * 88)
                    c.lineTo(offset + e.to * 72, 40 + e.toDepth * 88)
                    c.stroke()
                }
            }
        }
        Repeater {
            model: tree
            delegate: Rectangle {
                id: node
                required property int index
                required property int value
                required property int depth
                required property int parentRow
                readonly property bool isMarked: page.marked !== null && page.marked === value
                x: (view.contentWidth - tree.count * 72) / 2 + 12 + index * 72
                y: 16 + depth * 88
                width: 48; height: 48; radius: 24
                color: isMarked ? Theme.tint(page.markColor, 0.14) : Theme.node
                border.width: isMarked ? 2 : 1
                border.color: isMarked ? page.markColor : Theme.edge
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }
                Text {
                    anchors.centerIn: parent
                    text: node.value
                    color: node.isMarked ? page.markColor : Theme.ink
                    font.family: Theme.fontMono; font.pixelSize: 15; font.weight: Font.DemiBold
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.top; anchors.bottomMargin: 2
                    visible: node.parentRow < 0
                    text: "root"; color: Theme.accent
                    font.family: Theme.fontMono; font.pixelSize: 11
                }
            }
        }
    }
    Text {
        id: result
        anchors.bottom: parent.bottom
        width: parent.width
        visible: page.traversal.length > 0
        text: "Обход: " + page.traversal
        color: Theme.found; font.family: Theme.fontMono; font.pixelSize: 12
        elide: Text.ElideRight
    }
    dock: [
        DsInput { id: input; label: "значение"; onAccepted: page.doInsert() },
        DsButton { text: "Вставить"; primary: true; enabled: !page.busy; onClicked: page.doInsert() },
        DsButton { text: "Найти"; enabled: !page.busy; onClicked: page.doFind() },
        DsButton { text: "Удалить"; enabled: !page.busy; onClicked: page.doRemove() },
        DsButton { text: "Обход"; enabled: !page.busy; onClicked: page.doInorder() },
        Item { Layout.fillWidth: true },
        DsButton {
            text: "Очистить"; ghost: true; enabled: !page.busy
            onClicked: { tree.clear(); page.marked = null; page.traversal = ""; page.currentLine = -1; page.log("clear()") }
        }
    ]
}

