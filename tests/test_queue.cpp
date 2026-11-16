#include "TestSupport.h"
#include "ArrayQueue.h"

// Проверяет пустую очередь и ошибки просмотра и извлечения из неё.
void testEmptyQueue() {
    ArrayQueue<int> queue;
    CHECK(queue.empty());
    CHECK(queue.size() == 0);
    CHECK(queue.capacity() == 0);
    CHECK(queue.frontIndex() == 0);
    CHECK_OUT_OF_RANGE(queue.front());
    CHECK_OUT_OF_RANGE(queue.dequeue());
}

// Проверяет добавление, чтение начала и извлечение в порядке FIFO.
void testEnqueueAndDequeue() {
    ArrayQueue<int> queue;
    queue.enqueue(10);
    queue.enqueue(-5);
    queue.enqueue(-5);
    CHECK(!queue.empty());
    CHECK(queue.size() == 3);
    CHECK(queue.at(0) == 10);
    CHECK(queue.at(1) == -5);
    CHECK(queue.at(2) == -5);
    CHECK(queue.front() == 10);
    CHECK(queue.size() == 3);

    CHECK(queue.dequeue() == 10);
    CHECK(queue.dequeue() == -5);
    CHECK(queue.dequeue() == -5);
    CHECK(queue.empty());
}

// Проверяет оборачивание индексов и рост уже обёрнутого кольцевого буфера.
void testWrapAndGrowth() {
    ArrayQueue<int> queue;
    for (int i = 0; i < 4; i++) {
        queue.enqueue(i);
    }
    CHECK(queue.dequeue() == 0);
    CHECK(queue.dequeue() == 1);
    queue.enqueue(4);
    queue.enqueue(5); // Логический порядок: [2, 3, 4, 5].

    CHECK(queue.frontIndex() == 2);
    CHECK(queue.slotOf(0) == 2);
    CHECK(queue.slotOf(2) == 0);
    for (int i = 0; i < 4; i++) {
        CHECK(queue.at(i) == i + 2);
    }

    queue.enqueue(6); // Буфер заполнен, требуется расширение.
    CHECK(queue.capacity() >= 5);
    CHECK(queue.frontIndex() == 0);
    for (int i = 0; i < 5; i++) {
        CHECK(queue.slotOf(i) == i);
        CHECK(queue.at(i) == i + 2);
    }
    for (int i = 0; i < 5; i++) {
        CHECK(queue.dequeue() == i + 2);
    }
    CHECK(queue.empty());
}

// Проверяет очистку и новое добавление после очистки и после опустошения.
void testClearAndReuse() {
    ArrayQueue<int> queue;
    queue.enqueue(10);
    queue.clear();
    queue.clear();
    CHECK(queue.empty());
    CHECK(queue.size() == 0);
    CHECK(queue.capacity() == 0);
    CHECK(queue.frontIndex() == 0);

    queue.enqueue(0);
    CHECK(queue.dequeue() == 0);
    queue.enqueue(20);
    CHECK(queue.front() == 20);
}

// Запускает тесты очереди.
int main() {
    return runTests({
        {"empty queue", testEmptyQueue},
        {"enqueue and dequeue FIFO", testEnqueueAndDequeue},
        {"wrap and growth", testWrapAndGrowth},
        {"clear and reuse", testClearAndReuse}
    });
}
