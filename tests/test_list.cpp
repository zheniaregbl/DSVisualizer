#include "TestSupport.h"
#include "SinglyLinkedList.h"

// Проверяет состояние нового списка и ошибки изменения несуществующей позиции.
void testEmptyList() {
    SinglyLinkedList<int> list;
    CHECK(list.empty());
    CHECK(list.size() == 0);
    CHECK(list.find(10) == -1);
    CHECK_OUT_OF_RANGE(list.removeAt(0));
    CHECK_OUT_OF_RANGE(list.insertAt(1, 10));
}

// Проверяет добавление в начало, конец и середину, а также чтение по индексу.
void testInsert() {
    SinglyLinkedList<int> list;
    list.pushBack(20);
    list.pushFront(10);
    list.pushBack(40);
    list.insertAt(2, 30);
    list.insertAt(0, 0);
    list.insertAt(list.size(), 50);

    CHECK(list.size() == 6);
    CHECK(!list.empty());
    for (int i = 0; i < 6; i++) {
        CHECK(list.at(i) == i * 10);
    }
}

// Проверяет поиск первого совпадения, отрицательного значения и отсутствующего элемента.
void testFind() {
    SinglyLinkedList<int> list;
    list.pushBack(10);
    list.pushBack(-5);
    list.pushBack(-5);
    CHECK(list.find(10) == 0);
    CHECK(list.find(-5) == 1);
    CHECK(list.find(99) == -1);
    CHECK(list.size() == 3);
}

// Проверяет удаление середины, хвоста, головы и единственного узла.
void testRemove() {
    SinglyLinkedList<int> list;
    list.pushBack(10);
    list.pushBack(20);
    list.pushBack(30);
    CHECK(list.removeAt(1) == 20);
    CHECK(list.at(0) == 10);
    CHECK(list.at(1) == 30);

    CHECK(list.removeAt(1) == 30);
    list.pushBack(40); // После удаления хвоста новый хвост должен работать.
    CHECK(list.at(1) == 40);
    CHECK(list.removeAt(0) == 10);
    CHECK(list.removeAt(0) == 40);
    CHECK(list.empty());

    list.pushBack(50); // После удаления единственного узла список используется снова.
    list.pushFront(5);
    CHECK(list.size() == 2);
    CHECK(list.at(0) == 5);
    CHECK(list.at(1) == 50);
}

// Проверяет отказ при неверной позиции и сохранение элементов.
void testInvalidIndex() {
    SinglyLinkedList<int> list;
    list.pushBack(10);
    CHECK_OUT_OF_RANGE(list.insertAt(2, 20));
    CHECK_OUT_OF_RANGE(list.removeAt(1));
    CHECK(list.size() == 1);
    CHECK(list.at(0) == 10);
}

// Проверяет повторную очистку и добавление после неё.
void testClear() {
    SinglyLinkedList<int> list;
    list.pushBack(10);
    list.pushBack(20);
    list.clear();
    list.clear();
    CHECK(list.empty());
    CHECK(list.size() == 0);
    CHECK(list.find(10) == -1);

    list.pushFront(0);
    list.pushBack(1);
    CHECK(list.at(0) == 0);
    CHECK(list.at(1) == 1);
}

// Запускает тесты односвязного списка.
int main() {
    return runTests({
        {"empty list", testEmptyList},
        {"insert", testInsert},
        {"find", testFind},
        {"remove", testRemove},
        {"invalid index", testInvalidIndex},
        {"clear", testClear}
    });
}
