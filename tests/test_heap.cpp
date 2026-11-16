#include "TestSupport.h"
#include "MinHeap.h"

// Проверяет новую кучу и ошибки просмотра и извлечения из пустой кучи.
void testEmptyHeap() {
    MinHeap<int> heap;
    CHECK(heap.empty());
    CHECK(heap.size() == 0);
    CHECK(heap.values().empty());
    CHECK_OUT_OF_RANGE(heap.minimum());
    CHECK_OUT_OF_RANGE(heap.extractMin());
    CHECK_OUT_OF_RANGE(heap.at(0));
}

// Проверяет вставку, подъём нового минимума и чтение массива кучи.
void testInsertAndMinimum() {
    MinHeap<int> heap;
    heap.insert(20);
    heap.insert(5);
    heap.insert(15);
    heap.insert(3);

    CHECK(!heap.empty());
    CHECK(heap.size() == 4);
    CHECK(heap.minimum() == 3);
    CHECK(heap.size() == 4);
    CHECK(heap.at(0) == 3);
    CHECK(heap.at(1) == 5);
    CHECK(heap.at(2) == 15);
    CHECK(heap.at(3) == 20);
    CHECK(heap.values()[0] == heap.at(0));
    CHECK_OUT_OF_RANGE(heap.at(4));
}

// Проверяет извлечение в возрастающем порядке и спуск через меньшего правого ребёнка.
void testExtractMinimum() {
    MinHeap<int> heap;
    for (int value : {1, 5, 2, 9, 7, 3}) {
        heap.insert(value);
    }

    int expected[] = {1, 2, 3, 5, 7, 9};
    for (int value : expected) {
        CHECK(heap.minimum() == value);
        CHECK(heap.extractMin() == value);

        // После каждого удаления проверяем всех существующих родителей и детей.
        for (std::size_t i = 1; i < heap.size(); i++) {
            std::size_t parent = (i - 1) / 2;
            CHECK(heap.at(parent) <= heap.at(i));
        }
    }
    CHECK(heap.empty());
}

// Проверяет одинаковые, отрицательные и нулевые значения.
void testRepeatedValues() {
    MinHeap<int> heap;
    heap.insert(0);
    heap.insert(-5);
    heap.insert(-5);
    CHECK(heap.extractMin() == -5);
    CHECK(heap.extractMin() == -5);
    CHECK(heap.extractMin() == 0);
    CHECK(heap.empty());
}

// Проверяет сообщения наблюдателя: добавление, сравнения, обмены и перенос корня.
void testObserver() {
    MinHeap<int> heap;
    bool received[6] = {}; // По одному признаку на каждый элемент enum Step.

    auto observer = [&](MinHeap<int>::Step step, std::size_t first, std::size_t second) {
        received[step] = true;
        if (step == MinHeap<int>::ReplaceRoot) {
            CHECK(first == 0);
            CHECK(second == 0);
        } else {
            CHECK(first < heap.size());
            CHECK(second < heap.size());
        }
    };

    for (int value : {9, 7, 5, 3, 1}) {
        heap.insert(value, observer);
    }
    while (!heap.empty()) {
        heap.extractMin(observer);
    }

    CHECK(received[MinHeap<int>::Append]);
    CHECK(received[MinHeap<int>::CompareParent]);
    CHECK(received[MinHeap<int>::SwapUp]);
    CHECK(received[MinHeap<int>::ReplaceRoot]);
    CHECK(received[MinHeap<int>::CompareChild]);
    CHECK(received[MinHeap<int>::SwapDown]);
}

// Проверяет очистку и независимость копии от исходной кучи.
void testClearAndCopy() {
    MinHeap<int> heap;
    heap.insert(10);
    MinHeap<int> copy = heap;
    copy.insert(5);
    CHECK(heap.minimum() == 10);
    CHECK(copy.minimum() == 5);

    MinHeap<int> assigned;
    assigned = heap;
    assigned.extractMin();
    CHECK(heap.size() == 1);

    heap.clear();
    heap.clear();
    CHECK(heap.empty());
    CHECK(heap.size() == 0);
    heap.insert(20);
    CHECK(heap.extractMin() == 20);
}

// Запускает тесты min-кучи.
int main() {
    return runTests({
        {"empty heap", testEmptyHeap},
        {"insert and minimum", testInsertAndMinimum},
        {"extract minimum", testExtractMinimum},
        {"repeated values", testRepeatedValues},
        {"observer", testObserver},
        {"clear and copy", testClearAndCopy}
    });
}
