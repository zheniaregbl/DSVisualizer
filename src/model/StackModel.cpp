#include "StackModel.h"

QVariant StackModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || role != ValueRole) return {};
    return m_stack.at(std::size_t(index.row()));
}

void StackModel::push(int value) {
    const int row = count();
    beginInsertRows({}, row, row);
    m_stack.push(value);
    endInsertRows();
    emit countChanged();
    emit message(QString("push(%1): O(1) амортизированно").arg(value));
}

void StackModel::pop() {
    if (m_stack.empty()) { emit message("Стек пуст: pop невозможен"); return; }
    const int row = count() - 1;
    beginRemoveRows({}, row, row);
    int v = m_stack.pop();
    endRemoveRows();
    emit countChanged();
    emit message(QString("pop() → %1: O(1)").arg(v));
}

void StackModel::clear() {
    beginResetModel();
    m_stack.clear();
    endResetModel();
    emit countChanged();
    emit message("Стек очищен");
}