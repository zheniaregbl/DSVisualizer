#pragma once
#include <cstddef>
#include <stdexcept>
#include <utility>

template <typename T>
class ArrayQueue {
public:
    ArrayQueue() = default;
    ~ArrayQueue() { delete[] m_data; }
    ArrayQueue(const ArrayQueue&) = delete;
    ArrayQueue& operator=(const ArrayQueue&) = delete;

    void enqueue(const T& v) {
        if (m_size == m_cap) grow();
        m_data[(m_head + m_size) % m_cap] = v;
        ++m_size;
    }
    T dequeue() {
        if (empty()) throw std::out_of_range("dequeue from empty queue");
        T v = std::move(m_data[m_head]);
        m_head = (m_head + 1) % m_cap;
        --m_size;
        return v;
    }
    const T& front() const {
        if (empty()) throw std::out_of_range("front of empty queue");
        return m_data[m_head];
    }
    const T& at(std::size_t i) const { return m_data[(m_head + i) % m_cap]; }
    std::size_t slotOf(std::size_t i) const { return (m_head + i) % m_cap; }
    std::size_t frontIndex() const { return m_head; }
    std::size_t capacity() const { return m_cap; }
    std::size_t size() const { return m_size; }
    bool empty() const { return m_size == 0; }
    void clear() { delete[] m_data; m_data = nullptr; m_head = 0; m_size = 0; m_cap = 0; }

private:
    void grow() {
        std::size_t newCap = m_cap ? m_cap * 2 : 4;
        T* nd = new T[newCap];
        for (std::size_t i = 0; i < m_size; ++i)
            nd[i] = std::move(m_data[(m_head + i) % m_cap]);
        delete[] m_data;
        m_data = nd;
        m_cap = newCap;
        m_head = 0;
    }
    T* m_data = nullptr;
    std::size_t m_head = 0;
    std::size_t m_size = 0;
    std::size_t m_cap = 0;
};