#include "QueueModel.h"

QVariant QueueModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid()) return {};
    const auto i = std::size_t(index.row());
    if (role == ValueRole) return m_queue.at(i);
    if (role == SlotRole)  return int(m_queue.slotOf(i));
    return {};
}

void QueueModel::enqueue(int value) {
    const int row = count();
    const bool willGrow = m_queue.size() == m_queue.capacity();
    beginInsertRows({}, row, row);
    m_queue.enqueue(value);
    endInsertRows();
    if (willGrow && row > 0)
        emit dataChanged(index(0), index(row - 1), {SlotRole});
    emit countChanged();
    emit message(QString("enqueue(%1): O(1) амортизированно").arg(value));
}

void QueueModel::dequeue() {
    if (m_queue.empty()) { emit message("Очередь пуста: dequeue невозможен"); return; }
    beginRemoveRows({}, 0, 0);
    int v = m_queue.dequeue();
    endRemoveRows();
    emit countChanged();
    emit message(QString("dequeue() → %1: O(1)").arg(v));
}

void QueueModel::clear() {
    beginResetModel();
    m_queue.clear();
    endResetModel();
    emit countChanged();
    emit message("Очередь очищена");
}
