#pragma once
#include <QAbstractListModel>
#include <QtQml/qqmlregistration.h>
#include "ArrayQueue.h"

class QueueModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int capacity READ capacity NOTIFY countChanged)
    Q_PROPERTY(int front READ front NOTIFY countChanged)
public:
    enum Roles { ValueRole = Qt::UserRole + 1, SlotRole };
    explicit QueueModel(QObject* parent = nullptr) : QAbstractListModel(parent) {}

    int rowCount(const QModelIndex& = {}) const override { return int(m_queue.size()); }
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override {
        return {{ValueRole, "value"}, {SlotRole, "slot"}};
    }
    int count() const { return int(m_queue.size()); }
    int capacity() const { return int(m_queue.capacity()); }
    int front() const { return int(m_queue.frontIndex()); }

    Q_INVOKABLE int peek() const { return m_queue.empty() ? 0 : m_queue.front(); }
    Q_INVOKABLE void enqueue(int value);
    Q_INVOKABLE void dequeue();
    Q_INVOKABLE void clear();

signals:
    void countChanged();
    void message(const QString& text);

private:
    ArrayQueue<int> m_queue;
};
