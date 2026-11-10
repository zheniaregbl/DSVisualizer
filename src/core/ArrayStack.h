#pragma once
#include <cstddef>
#include <stdexcept>
#include <utility>

template <typename T>
class ArrayStack {
public:
    ArrayStack() = default;
    ~ArrayStack() { delete[] m_data; }
    ArrayStack(const ArrayStack&) = delete;
    ArrayStack& operator=(const ArrayStack&) = delete;

    void push(const T& v) {
        if (m_size == m_cap) grow();
        m_data[m_size++] = v;
    }
    T pop() {
        if (empty()) throw std::out_of_range("pop from empty stack");
        return std::move(m_data[--m_size]);
    }
    const T& top() const {
        if (empty()) throw std::out_of_range("top of empty stack");
        return m_data[m_size - 1];
    }
    const T& at(std::size_t i) const { return m_data[i]; }
    std::size_t size() const { return m_size; }
    std::size_t capacity() const { return m_cap; }
    bool empty() const { return m_size == 0; }
    void clear() { delete[] m_data; m_data = nullptr; m_size = 0; m_cap = 0; }

private:
    void grow() {
        std::size_t newCap = m_cap ? m_cap * 2 : 4;
        T* nd = new T[newCap];
        for (std::size_t i = 0; i < m_size; ++i) nd[i] = std::move(m_data[i]);
        delete[] m_data;
        m_data = nd;
        m_cap = newCap;
    }
    T* m_data = nullptr;
    std::size_t m_size = 0;
    std::size_t m_cap = 0;
};