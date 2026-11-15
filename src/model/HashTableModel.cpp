#include "HashTableModel.h"
#include <algorithm>

QVariant HashTableModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= bucketCount() || role != ValuesRole)
        return {};
    return bucketValues(index.row());
}
QVariantList HashTableModel::bucketValues(int bucket) const {
    QVariantList result;
    if (bucket < 0 || bucket >= bucketCount()) return result;
    for (int value : m_table.bucketValues(bucket)) result.append(value);
    return result;
}
int HashTableModel::longestChain() const {
    int longest = 0;
    for (int bucket = 0; bucket < bucketCount(); ++bucket)
        longest = std::max(longest, int(m_table.bucketValues(bucket).size()));
    return longest;
}
void HashTableModel::notifyBucket(int bucket) {
    const QModelIndex row = index(bucket, 0);
    emit dataChanged(row, row, {ValuesRole});
    emit countChanged();
}
bool HashTableModel::insert(int value) {
    if (!m_table.insert(value)) { emit message("Ключ уже существует"); return false; }
    notifyBucket(bucketIndex(value));
    emit message(QString("insert(%1), корзина %2").arg(value).arg(bucketIndex(value)));
    return true;
}
bool HashTableModel::remove(int value) {
    if (!m_table.remove(value)) { emit message("Ключ не найден"); return false; }
    notifyBucket(bucketIndex(value));
    emit message(QString("remove(%1)").arg(value));
    return true;
}
void HashTableModel::clear() {
    m_table.clear();
    emit dataChanged(index(0, 0), index(bucketCount() - 1, 0), {ValuesRole});
    emit countChanged();
    emit message("Таблица очищена");
}
