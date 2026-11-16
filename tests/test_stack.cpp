#include "TestSupport.h"
#include "ArrayStack.h"

// Проверяет пустой стек и ошибки просмотра и удаления из него.
void testEmptyStack() {
    ArrayStack<int> stack;
    CHECK(stack.empty());
    CHECK(stack.size() == 0);
    CHECK(stack.capacity() == 0);
    CHECK_OUT_OF_RANGE(stack.top());
    CHECK_OUT_OF_RANGE(stack.pop());
}

// Проверяет добавление, просмотр вершины и чтение элементов по индексу.
void testPushAndTop() {
    ArrayStack<int> stack;
    stack.push(10);
    stack.push(-5);
    stack.push(-5);
    CHECK(!stack.empty());
    CHECK(stack.size() == 3);
    CHECK(stack.at(0) == 10);
    CHECK(stack.at(1) == -5);
    CHECK(stack.at(2) == -5);
    CHECK(stack.top() == -5);
    CHECK(stack.size() == 3); // Просмотр ничего не удалил.
}

// Проверяет LIFO: первым удаляется последний добавленный элемент.
void testPop() {
    ArrayStack<int> stack;
    stack.push(10);
    stack.push(20);
    CHECK(stack.pop() == 20);
    CHECK(stack.top() == 10);
    CHECK(stack.pop() == 10);
    CHECK(stack.empty());
    CHECK_OUT_OF_RANGE(stack.pop());
}

// Проверяет расширение буфера и сохранение порядка всех элементов.
void testGrowth() {
    ArrayStack<int> stack;
    for (int i = 0; i < 20; i++) {
        stack.push(i);
    }
    CHECK(stack.capacity() >= 20);
    for (int i = 0; i < 20; i++) {
        CHECK(stack.at(i) == i);
    }
    for (int i = 19; i >= 0; i--) {
        CHECK(stack.pop() == i);
    }
    CHECK(stack.empty());
}

// Проверяет очистку, сброс ёмкости и повторное использование стека.
void testClear() {
    ArrayStack<int> stack;
    stack.push(10);
    stack.clear();
    stack.clear();
    CHECK(stack.empty());
    CHECK(stack.size() == 0);
    CHECK(stack.capacity() == 0);

    stack.push(0);
    CHECK(stack.pop() == 0);
}

// Запускает тесты стека.
int main() {
    return runTests({
        {"empty stack", testEmptyStack},
        {"push and top", testPushAndTop},
        {"pop LIFO", testPop},
        {"growth", testGrowth},
        {"clear", testClear}
    });
}
