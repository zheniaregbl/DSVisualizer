#pragma once
#include <QAbstractListModel>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>
#include "BinarySearchTree.h"

class BinarySearchTreeModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int height READ height NOTIFY countChanged)
public:
    enum Roles { ValueRole = Qt::UserRole + 1, DepthRole, ParentRole };
    explicit BinarySearchTreeModel(QObject* parent = nullptr) : QAbstractListModel(parent) {}
    int rowCount(const QModelIndex& parent = {}) const override { return parent.isValid() ? 0 : int(m_rows.size()); }
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    int count() const { return int(m_tree.size()); }
    int height() const { return m_height; }
    Q_INVOKABLE bool insert(int value);
    Q_INVOKABLE bool remove(int value);
    Q_INVOKABLE bool contains(int value) const { return m_tree.find(value) != nullptr; }
    Q_INVOKABLE QVariantList path(int value) const;
    Q_INVOKABLE QVariantList successorPath(int value) const;
    Q_INVOKABLE QVariantList inorder() const;
    Q_INVOKABLE QVariantList edges() const;
    Q_INVOKABLE void clear();
signals:
    void countChanged();
    void message(const QString& text);
private:
    struct Row { int value; int depth; int parent; };
    void rebuild();
    int append(const BinarySearchTree<int>::Node* node, int depth);
    BinarySearchTree<int> m_tree;
    std::vector<Row> m_rows;
    int m_height = 0;
};
