#include "LinkedListModel.h"

QVariant LinkedListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || role != ValueRole) return {};
    return m_list.at(std::size_t(index.row()));
}

void LinkedListModel::pushFront(int value) {
    beginInsertRows({}, 0, 0);
    m_list.pushFront(value);
    endInsertRows();
    emit countChanged();
    emit message(QString("pushFront(%1): O(1)").arg(value));
}

void LinkedListModel::pushBack(int value) {
    const int row = count();
    beginInsertRows({}, row, row);
    m_list.pushBack(value);
    endInsertRows();
    emit countChanged();
    emit message(QString("pushBack(%1): O(1) — есть указатель на хвост").arg(value));
}

void LinkedListModel::insertAt(int index, int value) {
    if (index < 0 || index > count()) {
        emit message(QString("Индекс %1 вне диапазона [0, %2]").arg(index).arg(count()));
        return;
    }
    beginInsertRows({}, index, index);
    m_list.insertAt(std::size_t(index), value);
    endInsertRows();
    emit countChanged();
    emit message(QString("insertAt(%1, %2): O(n) — проход до позиции").arg(index).arg(value));
}

void LinkedListModel::removeAt(int index) {
    if (index < 0 || index >= count()) {
        emit message(count() == 0 ? QString("Список пуст")
                                  : QString("Индекс %1 вне диапазона [0, %2]").arg(index).arg(count() - 1));
        return;
    }
    beginRemoveRows({}, index, index);
    int v = m_list.removeAt(std::size_t(index));
    endRemoveRows();
    emit countChanged();
    emit message(QString("removeAt(%1) → %2: O(n)").arg(index).arg(v));
}

int LinkedListModel::find(int value) const {
    return int(m_list.find(value));
}

int LinkedListModel::at(int index) const {
    if (index < 0 || index >= count()) return 0;
    return m_list.at(std::size_t(index));
}

void LinkedListModel::clear() {
    beginResetModel();
    m_list.clear();
    endResetModel();
    emit countChanged();
    emit message("Список очищен");
}