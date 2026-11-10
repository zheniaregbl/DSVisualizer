#pragma once
#include <QAbstractListModel>
#include <QtQml/qqmlregistration.h>
#include "SinglyLinkedList.h"

class LinkedListModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    enum Roles { ValueRole = Qt::UserRole + 1 };
    explicit LinkedListModel(QObject* parent = nullptr) : QAbstractListModel(parent) {}

    int rowCount(const QModelIndex& = {}) const override { return int(m_list.size()); }
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override { return {{ValueRole, "value"}}; }
    int count() const { return int(m_list.size()); }

    Q_INVOKABLE void pushFront(int value);
    Q_INVOKABLE void pushBack(int value);
    Q_INVOKABLE void insertAt(int index, int value);
    Q_INVOKABLE void removeAt(int index);
    Q_INVOKABLE int find(int value) const;
    Q_INVOKABLE int at(int index) const;
    Q_INVOKABLE void clear();

signals:
    void countChanged();
    void message(const QString& text);

private:
    SinglyLinkedList<int> m_list;
};