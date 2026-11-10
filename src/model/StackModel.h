#pragma once
#include <QAbstractListModel>
#include <QtQml/qqmlregistration.h>
#include "ArrayStack.h"

class StackModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int capacity READ capacity NOTIFY countChanged)
public:
    enum Roles { ValueRole = Qt::UserRole + 1 };
    explicit StackModel(QObject* parent = nullptr) : QAbstractListModel(parent) {}

    int rowCount(const QModelIndex& = {}) const override { return int(m_stack.size()); }
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override { return {{ValueRole, "value"}}; }
    int count() const { return int(m_stack.size()); }
    int capacity() const { return int(m_stack.capacity()); }

    Q_INVOKABLE int peek() const { return m_stack.empty() ? 0 : m_stack.top(); }
    Q_INVOKABLE void push(int value);
    Q_INVOKABLE void pop();
    Q_INVOKABLE void clear();

signals:
    void countChanged();
    void message(const QString& text);

private:
    ArrayStack<int> m_stack;
};