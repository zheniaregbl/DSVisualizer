#pragma once
#include <vector>
#include <stdexcept>

// Непрерывное хранилище; size — число элементов, capacity — число выделенных мест.
template<typename T>
class DynamicArray {
public:
    std::size_t size() const { return m_data.size(); }
    std::size_t capacity() const { return m_data.capacity(); }
    const T& at(std::size_t i) const { return m_data.at(i); }
    void set(std::size_t i, const T& value) { m_data.at(i) = value; }
    void insert(std::size_t index, const T& value) {
        if (index > size()) throw std::out_of_range("insert index");
        if (size() == capacity()) m_data.reserve(capacity() ? capacity() * 2 : 4);
        m_data.push_back(value);
        // Сдвигаем справа налево, чтобы не затереть ещё не скопированные элементы.
        for (std::size_t i = size() - 1; i > index; --i) m_data[i] = m_data[i - 1];
        m_data[index] = value;
    }
    void remove(std::size_t index) {
        if (index >= size()) throw std::out_of_range("remove index");
        // Закрываем промежуток: каждый следующий элемент сдвигается влево.
        for (std::size_t i = index; i + 1 < size(); ++i) m_data[i] = m_data[i + 1];
        m_data.pop_back();
    }
    void clear() { std::vector<T>().swap(m_data); }
private:
    std::vector<T> m_data;
};
