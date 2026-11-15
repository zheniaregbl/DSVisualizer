#pragma once
#include <QAbstractListModel>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>
#include "MinHeap.h"

class HeapModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    enum Roles { ValueRole = Qt::UserRole + 1 };
    explicit HeapModel(QObject* parent = nullptr) : QAbstractListModel(parent) {}
    int rowCount(const QModelIndex& parent = {}) const override { return parent.isValid() ? 0 : count(); }
    int count() const { return int(m_display.size()); }
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override { return {{ValueRole, "value"}}; }

    Q_INVOKABLE int minimum() const;
    Q_INVOKABLE QVariantList prepareInsert(int value);
    Q_INVOKABLE QVariantList prepareExtract();
    Q_INVOKABLE void showStep(int index);
    Q_INVOKABLE void finish();
    Q_INVOKABLE void cancel();
    Q_INVOKABLE void clear();
signals:
    void countChanged();
private:
    QVariantList prepare(bool inserting, int value);
    void display(const std::vector<int>& values);
    MinHeap<int> m_heap;
    MinHeap<int> m_pending;
    std::vector<int> m_display;
    std::vector<std::vector<int>> m_frames;
    bool m_hasPending = false;
};
