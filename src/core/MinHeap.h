#pragma once
#include <vector>
#include <functional>
#include <stdexcept>
#include <utility>

template<typename T>
class MinHeap {
public:
    enum Step { Append, CompareParent, SwapUp, ReplaceRoot, CompareChild, SwapDown };
    using Observer = std::function<void(Step, std::size_t, std::size_t)>;

    std::size_t size() const { return m_values.size(); }
    bool empty() const { return m_values.empty(); }
    const T& at(std::size_t index) const { return m_values.at(index); }
    const std::vector<T>& values() const { return m_values; }
    void clear() { m_values.clear(); }

    const T& minimum() const {
        if (empty()) throw std::out_of_range("minimum: heap is empty");
        return m_values.front();
    }

    void insert(const T& value, const Observer& observe = {}) {
        m_values.push_back(value);
        std::size_t child = size() - 1;
        if (observe) observe(Append, child, child);

        while (child > 0) {
            std::size_t parent = (child - 1) / 2;
            if (observe) observe(CompareParent, child, parent);
            if (!(m_values[child] < m_values[parent])) break;

            std::swap(m_values[child], m_values[parent]);
            if (observe) observe(SwapUp, child, parent);
            child = parent;
        }
    }

    T extractMin(const Observer& observe = {}) {
        if (empty()) throw std::out_of_range("extractMin: heap is empty");
        T result = m_values.front();
        m_values.front() = m_values.back();
        m_values.pop_back();
        if (observe) observe(ReplaceRoot, 0, 0);

        std::size_t parent = 0;
        while (2 * parent + 1 < size()) {
            std::size_t left = 2 * parent + 1;
            std::size_t right = left + 1;
            std::size_t smallerChild = left;

            if (right < size() && m_values[right] < m_values[left])
                smallerChild = right;

            if (observe) observe(CompareChild, parent, smallerChild);
            if (!(m_values[smallerChild] < m_values[parent])) break;

            std::swap(m_values[parent], m_values[smallerChild]);
            if (observe) observe(SwapDown, parent, smallerChild);
            parent = smallerChild;
        }
        return result;
    }
private:
    std::vector<T> m_values;
};
