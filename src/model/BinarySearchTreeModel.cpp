#include "BinarySearchTreeModel.h"
#include <algorithm>

QVariant BinarySearchTreeModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= int(m_rows.size())) return {};
    const auto& row = m_rows[index.row()];
    switch (role) {
    case ValueRole: return row.value;
    case DepthRole: return row.depth;
    case ParentRole: return row.parent;
    default: return {};
    }
}
QHash<int, QByteArray> BinarySearchTreeModel::roleNames() const {
    return {{ValueRole, "value"}, {DepthRole, "depth"}, {ParentRole, "parentRow"}};
}
int BinarySearchTreeModel::append(const BinarySearchTree<int>::Node* node, int depth) {
    if (!node) return -1;
    int left = append(node->left, depth + 1);
    int row = int(m_rows.size());
    m_rows.push_back({node->value, depth, -1});
    m_height = std::max(m_height, depth + 1);
    int right = append(node->right, depth + 1);
    if (left >= 0) m_rows[left].parent = row;
    if (right >= 0) m_rows[right].parent = row;
    return row;
}
void BinarySearchTreeModel::rebuild() {
    m_rows.clear(); m_height = 0;
    append(m_tree.root(), 0);
}
bool BinarySearchTreeModel::insert(int value) {
    if (contains(value)) { emit message("Ключ уже существует"); return false; }
    beginResetModel();
    m_tree.insert(value); rebuild();
    endResetModel();
    emit countChanged();
    emit message(QString("insert(%1): O(h)").arg(value));
    return true;
}
bool BinarySearchTreeModel::remove(int value) {
    if (!contains(value)) { emit message("Ключ не найден"); return false; }
    beginResetModel();
    m_tree.remove(value); rebuild();
    endResetModel();
    emit countChanged();
    emit message(QString("remove(%1): O(h)").arg(value));
    return true;
}
QVariantList BinarySearchTreeModel::path(int value) const {
    QVariantList result;
    auto* node = m_tree.root();
    while (node) {
        result.append(node->value);
        if (node->value == value) break;
        node = value < node->value ? node->left : node->right;
    }
    return result;
}
QVariantList BinarySearchTreeModel::successorPath(int value) const {
    QVariantList result;
    auto* node = m_tree.find(value);
    if (!node || !node->left || !node->right) return result;
    for (node = node->right; node; node = node->left) result.append(node->value);
    return result;
}
QVariantList BinarySearchTreeModel::inorder() const {
    QVariantList result;
    for (int value : m_tree.inorder()) result.append(value);
    return result;
}
QVariantList BinarySearchTreeModel::edges() const {
    QVariantList result;
    for (int i = 0; i < int(m_rows.size()); ++i) {
        const auto& row = m_rows[i];
        if (row.parent >= 0)
            result.append(QVariantMap{{"from", row.parent}, {"to", i},
                {"fromDepth", m_rows[row.parent].depth}, {"toDepth", row.depth}});
    }
    return result;
}
void BinarySearchTreeModel::clear() {
    beginResetModel();
    m_tree.clear(); rebuild();
    endResetModel();
    emit countChanged();
    emit message("Дерево очищено");
}
