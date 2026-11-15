import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DSVisualizer
StructurePage {
    id: page
    group: "Линейные"
    title: "Динамический массив"
    description: "Элементы лежат подряд. Доступ по индексу — O(1), вставка и удаление требуют сдвига. При заполнении ёмкость удваивается."
    complexity: [["доступ / изменение", "O(1)"], ["вставка / удаление / поиск", "O(n)"], ["в конец", "O(1) аморт."]]
    meta: "size = " + array.count + "   ·   cap = " + array.capacity
    property int marked: -1
    onStopped: marked = -1
    onVisibleChanged: { if (!visible && busy) stop() }
    ArrayModel { id: array }
    function operation(op) {
        if (busy) return
        const i = indexBox.value, x = input.value
        if (op !== "find" && (i < 0 || i > array.count || (op !== "insert" && i === array.count))) {
            toast("Индекс вне диапазона"); indexBox.shake(); return
        }
        const steps = []
        if (op === "find") {
            code = ["for i ← 0 .. size − 1:", "  if a[i] = x: return i", "return −1"]
            let found = -1
            for (let k=0;k<array.count;++k) {
                const position=k
                steps.push({line:0,act:()=>page.marked=position})
                if (array.at(k)===x) { found=k; break }
            }
            steps.push({line:found>=0?1:2,act:()=>page.log("find(" + x + ") → " + found)})
        } else if (op === "insert" || op === "remove") {
            if(op === "insert" && array.count>=100) { toast("Лимит: 100 элементов"); return }
            code = op === "insert"
                ? ["if size = cap: grow()", "сдвиг a[j] → a[j+1]", "a[i] ← x; size++"]
                : ["проверить индекс i", "сдвиг a[j+1] → a[j]", "size--"]
            steps.push({line:0})
            for(let k=0;k<(op==="insert"?array.count-i:array.count-i-1);++k) {
                const position=op==="insert"?array.count-1-k:i+1+k
                steps.push({line:1,act:()=>{page.marked=position;page.log("Сдвиг ["+position+"] "+(op==="insert"?"вправо":"влево"))}})
            }
            steps.push({line:2,act:()=>{
                if(op==="insert") array.insert(i,x); else array.remove(i)
                page.marked=op==="insert"?i:-1
                page.log(op+"("+i+(op==="insert"?", "+x:"")+")")
            }})
        } else {
            code = [op==="get"?"return a[i]":"a[i] ← x"]
            steps.push({line:0,act:()=>{
                page.marked=i
                if(op==="set") array.set(i,x)
                page.log(op+"("+i+") → "+array.at(i))
            }})
        }
        run(steps)
    }
    GridView {
        anchors.fill: parent; model: array
        cellWidth: 84; cellHeight: 82; clip: true
        ScrollBar.vertical: ScrollBar {}
        delegate: Item {
            required property int index
            required property int value
            width:84; height:82
            Rectangle {
                width:70; height:44; radius:8
                color:Theme.node
                border.color: index===page.marked?Theme.accent:Theme.edge
                border.width:index===page.marked?2:1
                Text { anchors.centerIn:parent; text:value; color:Theme.ink; font.family:Theme.fontMono }
            }
            Text { y:50; text:"["+index+"]"; color:Theme.muted; font.family:Theme.fontMono }
        }
    }
    dock: [
        DsInput { id:input; label:"значение"; onAccepted:page.operation("insert") },
        DsInput { id:indexBox; label:"индекс"; text:"0" },
        DsButton { text:"Вставить"; primary:true; enabled:!page.busy; onClicked:page.operation("insert") },
        DsButton { text:"Удалить"; enabled:!page.busy; onClicked:page.operation("remove") },
        DsButton { text:"Получить"; enabled:!page.busy; onClicked:page.operation("get") },
        DsButton { text:"Изменить"; enabled:!page.busy; onClicked:page.operation("set") },
        DsButton { text:"Найти"; enabled:!page.busy; onClicked:page.operation("find") },
        DsButton { text:"Очистить"; enabled:!page.busy; onClicked:{array.clear();page.marked=-1;page.currentLine=-1;page.log("clear()")} }
    ]
}
