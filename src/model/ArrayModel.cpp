#include "ArrayModel.h"
void ArrayModel::insert(int i,int value) {
    if(i<0 || i>count()) return;
    beginResetModel(); m_array.insert(i,value); endResetModel(); emit changed();
}
void ArrayModel::remove(int i) {
    if(i<0 || i>=count()) return;
    beginResetModel(); m_array.remove(i); endResetModel(); emit changed();
}
void ArrayModel::set(int i,int value) {
    if(i<0 || i>=count()) return;
    m_array.set(i,value); emit dataChanged(index(i,0),index(i,0),{ValueRole});
}
void ArrayModel::clear() {
    beginResetModel(); m_array.clear(); endResetModel(); emit changed();
}
