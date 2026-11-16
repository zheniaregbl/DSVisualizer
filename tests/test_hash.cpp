#include "TestSupport.h"
#include "HashTable.h"

// Проверяет пустую таблицу, отсутствие ключа и недопустимые номера корзин.
void testEmptyTable() {
    HashTable<int> table;
    CHECK(table.empty());
    CHECK(table.size() == 0);
    CHECK(table.BucketCount == 7);
    CHECK(!table.contains(10));
    CHECK(!table.remove(10));

    for (int bucket = 0; bucket < 7; bucket++) {
        CHECK(table.bucketValues(bucket).empty());
    }
    CHECK_OUT_OF_RANGE(table.bucketValues(-1));
    CHECK_OUT_OF_RANGE(table.bucketValues(7));
}

// Проверяет вычисление корзины для положительных, отрицательных ключей и нуля.
void testBucketIndex() {
    HashTable<int> table;
    CHECK(table.bucketIndex(0) == 0);
    CHECK(table.bucketIndex(7) == 0);
    CHECK(table.bucketIndex(8) == 1);
    CHECK(table.bucketIndex(-1) == 6);
    CHECK(table.bucketIndex(-6) == 1);
    CHECK(table.bucketIndex(-7) == 0);
}

// Проверяет вставку, поиск и отказ при повторной вставке ключа.
void testInsertAndContains() {
    HashTable<int> table;
    CHECK(table.insert(10));
    CHECK(table.insert(-5));
    CHECK(table.insert(0));
    CHECK(!table.empty());
    CHECK(table.size() == 3);
    CHECK(table.contains(10));
    CHECK(table.contains(-5));
    CHECK(table.contains(0));
    CHECK(!table.contains(99));

    CHECK(!table.insert(10));
    CHECK(table.size() == 3);
}

// Проверяет, что разные ключи с одним хешем сохраняются в общей цепочке.
void testCollisions() {
    HashTable<int> table;
    table.insert(1);
    table.insert(8);
    table.insert(15);
    table.insert(-6);
    std::vector<int> chain = table.bucketValues(1);

    CHECK(chain.size() == 4);
    CHECK(chain[0] == 1);
    CHECK(chain[1] == 8);
    CHECK(chain[2] == 15);
    CHECK(chain[3] == -6);
    CHECK(table.contains(15));
    CHECK(table.contains(-6));
}

// Проверяет удаление середины, головы, хвоста и единственного узла цепочки.
void testRemove() {
    HashTable<int> table;
    for (int value : {1, 8, 15, -6}) {
        table.insert(value);
    }
    CHECK(table.remove(8));
    std::vector<int> chain = table.bucketValues(1);
    CHECK(chain.size() == 3);
    CHECK(chain[0] == 1);
    CHECK(chain[1] == 15);
    CHECK(chain[2] == -6);

    CHECK(table.remove(1));
    CHECK(table.bucketValues(1)[0] == 15);
    CHECK(table.remove(-6));
    CHECK(table.bucketValues(1).size() == 1);
    CHECK(table.remove(15));
    CHECK(table.empty());
    CHECK(table.size() == 0);
    CHECK(!table.remove(15));
    CHECK(!table.contains(15));
}

// Проверяет заполнение всех корзин, очистку и повторное использование.
void testClear() {
    HashTable<int> table;
    for (int i = 0; i < 14; i++) {
        table.insert(i);
    }
    for (int bucket = 0; bucket < 7; bucket++) {
        CHECK(table.bucketValues(bucket).size() == 2);
    }

    table.clear();
    table.clear();
    CHECK(table.empty());
    CHECK(table.size() == 0);
    for (int bucket = 0; bucket < 7; bucket++) {
        CHECK(table.bucketValues(bucket).empty());
    }

    CHECK(table.insert(10));
    CHECK(table.contains(10));
}

// Запускает тесты хеш-таблицы.
int main() {
    return runTests({
        {"empty table", testEmptyTable},
        {"bucket index", testBucketIndex},
        {"insert and contains", testInsertAndContains},
        {"collisions", testCollisions},
        {"remove", testRemove},
        {"clear", testClear}
    });
}
