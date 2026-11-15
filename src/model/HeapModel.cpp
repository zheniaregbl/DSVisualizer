#include "HeapModel.h"

QVariant HeapModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= count() || role != ValueRole) return {};
    return m_display[index.row()];
}
int HeapModel::minimum() const {
    return m_heap.empty() ? 0 : m_heap.minimum();
}
void HeapModel::display(const std::vector<int>& values) {
    beginResetModel();
    m_display = values;
    endResetModel();
    emit countChanged();
}
QVariantList HeapModel::prepareInsert(int value) { return prepare(true, value); }
QVariantList HeapModel::prepareExtract() { return prepare(false, 0); }

QVariantList HeapModel::prepare(bool inserting, int value) {
    cancel();
    QVariantList steps;
    if (!inserting && m_heap.empty()) return steps;
    m_pending = m_heap;

    auto observe = [&](MinHeap<int>::Step step, std::size_t first, std::size_t second) {
        int line = 0;
        QString text;
        bool swapping = false;
        switch (step) {
        case MinHeap<int>::Append: line = 0; text = "Добавить в конец массива"; break;
        case MinHeap<int>::CompareParent: line = 2; text = "Сравнить с родителем"; break;
        case MinHeap<int>::SwapUp: line = 4; text = "Обмен: поднять элемент"; swapping = true; break;
        case MinHeap<int>::ReplaceRoot: line = 2; text = "Перенести последний элемент в корень"; break;
        case MinHeap<int>::CompareChild: line = 5; text = "Сравнить с меньшим ребёнком"; break;
        case MinHeap<int>::SwapDown: line = 6; text = "Обмен: опустить элемент"; swapping = true; break;
        }
        m_frames.push_back(m_pending.values());
        steps.append(QVariantMap{{"line", line}, {"first", int(first)}, {"second", int(second)},
                                 {"text", text}, {"swapping", swapping}});
    };
    if (inserting) m_pending.insert(value, observe);
    else m_pending.extractMin(observe);
    m_hasPending = true;
    return steps;
}
void HeapModel::showStep(int index) {
    if (m_hasPending && index >= 0 && index < int(m_frames.size()))
        display(m_frames[index]);
}
void HeapModel::finish() {
    if (!m_hasPending) return;
    m_heap = m_pending;
    m_frames.clear();
    m_hasPending = false;
    display(m_heap.values());
}
void HeapModel::cancel() {
    m_frames.clear();
    m_hasPending = false;
    display(m_heap.values());
}
void HeapModel::clear() {
    m_heap.clear();
    cancel();
}
