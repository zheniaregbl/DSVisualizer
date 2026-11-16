#pragma once
#include <initializer_list>
#include <iostream>
#include <stdexcept>
#include <string>

// Если условие неверно, тест завершается с сообщением о строке ошибки.
// В отличие от assert, эта проверка работает и в Release.
#define CHECK(condition) \
    if (!(condition)) throw std::runtime_error( \
        std::string("Line ") + std::to_string(__LINE__) + ": " + #condition)

// Проверяет, что действие отклоняется исключением out_of_range.
// Например: CHECK_OUT_OF_RANGE(array.at(100)).
#define CHECK_OUT_OF_RANGE(action) \
    do { \
        bool exceptionReceived = false; \
        try { action; } \
        catch (const std::out_of_range&) { exceptionReceived = true; } \
        CHECK(exceptionReceived); \
    } while (false)

// Один тест состоит из названия и указателя на обычную функцию без параметров.
struct TestCase {
    const char* name;
    void (*function)();
};

// Запускает все тесты файла и возвращает ненулевой код, если есть ошибка.
inline int runTests(std::initializer_list<TestCase> tests) {
    int failed = 0;

    for (const TestCase& test : tests) {
        try {
            test.function();
            std::cout << "[PASS] " << test.name << '\n';
        } catch (const std::exception& error) {
            failed++;
            std::cout << "[FAIL] " << test.name << ": " << error.what() << '\n';
        }
    }

    std::cout << tests.size() - failed << "/" << tests.size() << " tests passed\n";
    return failed == 0 ? 0 : 1;
}
