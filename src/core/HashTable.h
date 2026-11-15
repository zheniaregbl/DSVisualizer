#pragma once
#include <array>
#include <cstddef>
#include <type_traits>
#include <vector>

template<typename T>
class HashTable {
    static_assert(std::is_integral<T>::value, "HashTable requires integer keys");
    struct Node {
        T value;
        Node* next = nullptr;
    };
public:
    static constexpr int BucketCount = 7;
    HashTable() = default;
    ~HashTable() { clear(); }
    HashTable(const HashTable&) = delete;
    HashTable& operator=(const HashTable&) = delete;

    std::size_t size() const { return m_size; }
    bool empty() const { return m_size == 0; }

    int bucketIndex(T value) const {
        int remainder = int(value % BucketCount);
        return remainder < 0 ? remainder + BucketCount : remainder;
    }

    bool contains(T value) const {
        Node* current = m_buckets[bucketIndex(value)];
        while (current) {
            if (current->value == value) return true;
            current = current->next;
        }
        return false;
    }

    bool insert(T value) {
        int index = bucketIndex(value);
        Node* current = m_buckets[index];
        Node* previous = nullptr;

        while (current) {
            if (current->value == value) return false;
            previous = current;
            current = current->next;
        }
        Node* node = new Node{value};
        if (previous) previous->next = node;
        else m_buckets[index] = node;
        ++m_size;
        return true;
    }

    bool remove(T value) {
        int index = bucketIndex(value);
        Node* current = m_buckets[index];
        Node* previous = nullptr;

        while (current && current->value != value) {
            previous = current;
            current = current->next;
        }
        if (!current) return false;

        if (previous) previous->next = current->next;
        else m_buckets[index] = current->next;
        delete current;
        --m_size;
        return true;
    }

    std::vector<T> bucketValues(int index) const {
        std::vector<T> result;
        for (Node* current = m_buckets.at(index); current; current = current->next)
            result.push_back(current->value);
        return result;
    }

    void clear() {
        for (Node*& head : m_buckets) {
            while (head) {
                Node* next = head->next;
                delete head;
                head = next;
            }
        }
        m_size = 0;
    }

private:
    std::array<Node*, BucketCount> m_buckets{};
    std::size_t m_size = 0;
};
