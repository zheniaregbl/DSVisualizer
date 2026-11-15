#pragma once
#include <cstddef>
#include <vector>

template<typename T>
class BinarySearchTree {
public:
    struct Node { T value; Node* left = nullptr; Node* right = nullptr; };
    BinarySearchTree() = default;
    ~BinarySearchTree() { clear(); }
    BinarySearchTree(const BinarySearchTree&) = delete;
    BinarySearchTree& operator=(const BinarySearchTree&) = delete;

    const Node* root() const { return m_root; }
    std::size_t size() const { return m_size; }
    bool empty() const { return m_size == 0; }
    const Node* find(const T& value) const {
        auto* node = m_root;
        while (node && node->value != value)
            node = value < node->value ? node->left : node->right;
        return node;
    }
    bool insert(const T& value) {
        Node** link = &m_root;
        while (*link) {
            if ((*link)->value == value) return false;
            link = value < (*link)->value ? &(*link)->left : &(*link)->right;
        }
        *link = new Node{value};
        ++m_size;
        return true;
    }
    bool remove(const T& value) {
        Node** link = &m_root;
        while (*link && (*link)->value != value)
            link = value < (*link)->value ? &(*link)->left : &(*link)->right;
        if (!*link) return false;
        Node* victim = *link;
        if (victim->left && victim->right) {
            Node** successor = &victim->right;
            while ((*successor)->left) successor = &(*successor)->left;
            victim->value = (*successor)->value;
            victim = *successor;
            *successor = victim->right;
        } else {
            *link = victim->left ? victim->left : victim->right;
        }
        delete victim;
        --m_size;
        return true;
    }
    std::vector<T> inorder() const {
        std::vector<T> result;
        std::vector<const Node*> stack;
        auto* node = root();
        while (node || !stack.empty()) {
            while (node) { stack.push_back(node); node = node->left; }
            node = stack.back(); stack.pop_back();
            result.push_back(node->value);
            node = node->right;
        }
        return result;
    }
    void clear() {
        while (m_root) {
            if (m_root->left) {
                Node* left = m_root->left;
                m_root->left = left->right;
                left->right = m_root;
                m_root = left;
            } else {
                Node* next = m_root->right;
                delete m_root;
                m_root = next;
            }
        }
        m_size = 0;
    }
private:
    Node* m_root = nullptr;
    std::size_t m_size = 0;
};
