#pragma once
#include <QAbstractListModel>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>
#include "HashTable.h"

class HashTableModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int bucketCount READ bucketCount CONSTANT)
    Q_PROPERTY(int longestChain READ longestChain NOTIFY countChanged)
public:
    enum Roles { ValuesRole = Qt::UserRole + 1 };
    explicit HashTableModel(QObject* parent = nullptr) : QAbstractListModel(parent) {}
    int rowCount(const QModelIndex& parent = {}) const override { return parent.isValid() ? 0 : bucketCount(); }
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override { return {{ValuesRole, "values"}}; }
    int count() const { return int(m_table.size()); }
    int bucketCount() const { return HashTable<int>::BucketCount; }
    int longestChain() const;

    Q_INVOKABLE int bucketIndex(int value) const { return m_table.bucketIndex(value); }
    Q_INVOKABLE QVariantList bucketValues(int bucket) const;
    Q_INVOKABLE bool contains(int value) const { return m_table.contains(value); }
    Q_INVOKABLE bool insert(int value);
    Q_INVOKABLE bool remove(int value);
    Q_INVOKABLE void clear();
signals:
    void countChanged();
    void message(const QString& text);
private:
    void notifyBucket(int bucket);
    HashTable<int> m_table;
};
