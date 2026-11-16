#include "TestSupport.h"
#include "DynamicArray.h"

// Проверяет размер и ёмкость только что созданного массива.
void testEmptyArray() {
    DynamicArray<int> array;
    CHECK(array.size() == 0);
    CHECK(array.capacity() == 0);
}

// Проверяет вставку в начало, середину и конец, а также чтение по индексу.
void testInsertAndRead() {
    DynamicArray<int> array;
    array.insert(0, 10);
    array.insert(1, 30);
    array.insert(1, 20);
    array.insert(0, 5);

    CHECK(array.size() == 4);
    CHECK(array.at(0) == 5);
    CHECK(array.at(1) == 10);
    CHECK(array.at(2) == 20);
    CHECK(array.at(3) == 30);
}

// Проверяет изменение значений, включая ноль, отрицательные числа и повторы.
void testSetValue() {
    DynamicArray<int> array;
    array.insert(0, 10);
    array.insert(1, 20);
    array.set(0, -5);
    array.set(1, -5);
    CHECK(array.at(0) == -5);
    CHECK(array.at(1) == -5);

    array.set(0, 0);
    CHECK(array.at(0) == 0);
    CHECK(array.size() == 2);
}

// Проверяет удаление из середины, начала, конца и удаление последнего элемента.
void testRemove() {
    DynamicArray<int> array;
    for (int i = 0; i < 4; i++) {
        array.insert(array.size(), i * 10);
    }
    array.remove(1); // [0, 20, 30]
    CHECK(array.size() == 3);
    CHECK(array.at(0) == 0);
    CHECK(array.at(1) == 20);
    CHECK(array.at(2) == 30);

    array.remove(0); // [20, 30]
    array.remove(1); // [20]
    CHECK(array.size() == 1);
    CHECK(array.at(0) == 20);
    array.remove(0);
    CHECK(array.size() == 0);
}

// Проверяет расширение: добавление новых элементов не теряет старые.
void testGrowth() {
    DynamicArray<int> array;
    for (int i = 0; i < 20; i++) {
        array.insert(array.size(), i);
    }
    CHECK(array.size() == 20);
    CHECK(array.capacity() >= array.size());
    for (int i = 0; i < 20; i++) {
        CHECK(array.at(i) == i);
    }
}

// Проверяет отказ при неверных индексах и сохранение содержимого после ошибки.
void testInvalidIndex() {
    DynamicArray<int> array;
    CHECK_OUT_OF_RANGE(array.at(0));
    CHECK_OUT_OF_RANGE(array.set(0, 10));
    CHECK_OUT_OF_RANGE(array.remove(0));
    CHECK_OUT_OF_RANGE(array.insert(1, 10));

    array.insert(0, 10);
    CHECK_OUT_OF_RANGE(array.at(1));
    CHECK_OUT_OF_RANGE(array.set(1, 20));
    CHECK_OUT_OF_RANGE(array.remove(1));
    CHECK_OUT_OF_RANGE(array.insert(2, 20));
    CHECK(array.size() == 1);
    CHECK(array.at(0) == 10);
}

// Проверяет повторную очистку и возможность добавления после неё.
void testClear() {
    DynamicArray<int> array;
    array.insert(0, 10);
    array.clear();
    array.clear();
    CHECK(array.size() == 0);
    CHECK(array.capacity() == 0);

    array.insert(0, 50);
    CHECK(array.at(0) == 50);
}

// Проверяет, что копирование создаёт независимые массивы.
void testCopy() {
    DynamicArray<int> original;
    original.insert(0, 10);
    DynamicArray<int> copy = original;
    copy.set(0, 20);
    CHECK(original.at(0) == 10);

    DynamicArray<int> assigned;
    assigned = original;
    assigned.remove(0);
    CHECK(original.size() == 1);
}

// Запускает тесты динамического массива.
int main() {
    return runTests({
        {"empty array", testEmptyArray},
        {"insert and read", testInsertAndRead},
        {"set value", testSetValue},
        {"remove", testRemove},
        {"growth", testGrowth},
        {"invalid index", testInvalidIndex},
        {"clear", testClear},
        {"copy", testCopy}
    });
}
