#pragma once
#include <QAbstractListModel>
#include <QtQml/qqmlregistration.h>
#include "DynamicArray.h"
class ArrayModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int count READ count NOTIFY changed)
    Q_PROPERTY(int capacity READ capacity NOTIFY changed)
public:
    enum { ValueRole = Qt::UserRole + 1 };
    explicit ArrayModel(QObject* parent=nullptr):QAbstractListModel(parent){}
    int count() const { return int(m_array.size()); }
    int capacity() const { return int(m_array.capacity()); }
    int rowCount(const QModelIndex& p={}) const override { return p.isValid()?0:count(); }
    QVariant data(const QModelIndex& i,int role) const override {
        if (!i.isValid() || i.row()<0 || i.row()>=count() || role!=ValueRole) return {};
        return at(i.row());
    }
    QHash<int,QByteArray> roleNames() const override { return {{ValueRole,"value"}}; }
    Q_INVOKABLE int at(int i) const { return i>=0 && i<count()?m_array.at(i):0; }
    Q_INVOKABLE void insert(int i,int value);
    Q_INVOKABLE void remove(int i);
    Q_INVOKABLE void set(int i,int value);
    Q_INVOKABLE void clear();
signals:
    void changed();
private:
    DynamicArray<int> m_array;
};
