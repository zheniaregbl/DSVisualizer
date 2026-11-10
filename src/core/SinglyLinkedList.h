#pragma once
#include <cstddef>
#include <stdexcept>
#include <utility>

template <typename T>
class SinglyLinkedList {
    struct Node {
        T value;
        Node* next;
    };

public:
    SinglyLinkedList() = default;
    ~SinglyLinkedList() { clear(); }
    SinglyLinkedList(const SinglyLinkedList&) = delete;
    SinglyLinkedList& operator=(const SinglyLinkedList&) = delete;

    void pushFront(const T& v) {
        m_head = new Node{v, m_head};
        if (!m_tail) m_tail = m_head;
        ++m_size;
    }
    void pushBack(const T& v) {
        Node* n = new Node{v, nullptr};
        if (m_tail) m_tail->next = n; else m_head = n;
        m_tail = n;
        ++m_size;
    }
    void insertAt(std::size_t i, const T& v) {
        if (i > m_size) throw std::out_of_range("insertAt: bad index");
        if (i == 0)      { pushFront(v); return; }
        if (i == m_size) { pushBack(v);  return; }
        Node* prev = nodeAt(i - 1);
        prev->next = new Node{v, prev->next};
        ++m_size;
    }
    T removeAt(std::size_t i) {
        if (i >= m_size) throw std::out_of_range("removeAt: bad index");
        Node* victim;
        if (i == 0) {
            victim = m_head;
            m_head = victim->next;
            if (!m_head) m_tail = nullptr;
        } else {
            Node* prev = nodeAt(i - 1);
            victim = prev->next;
            prev->next = victim->next;
            if (victim == m_tail) m_tail = prev;
        }
        T v = std::move(victim->value);
        delete victim;
        --m_size;
        return v;
    }
    long long find(const T& v) const {
        long long i = 0;
        for (Node* n = m_head; n; n = n->next, ++i)
            if (n->value == v) return i;
        return -1;
    }
    const T& at(std::size_t i) const { return nodeAt(i)->value; }
    std::size_t size() const { return m_size; }
    bool empty() const { return m_size == 0; }
    void clear() {
        while (m_head) {
            Node* next = m_head->next;
            delete m_head;
            m_head = next;
        }
        m_tail = nullptr;
        m_size = 0;
    }

private:
    Node* nodeAt(std::size_t i) const {
        Node* n = m_head;
        while (i--) n = n->next;
        return n;
    }
    Node* m_head = nullptr;
    Node* m_tail = nullptr;
    std::size_t m_size = 0;
};