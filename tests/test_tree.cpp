#include "TestSupport.h"
#include "BinarySearchTree.h"

// Проверяет новое дерево, поиск и удаление отсутствующего ключа.
void testEmptyTree() {
    BinarySearchTree<int> tree;
    CHECK(tree.empty());
    CHECK(tree.size() == 0);
    CHECK(tree.root() == nullptr);
    CHECK(tree.find(10) == nullptr);
    CHECK(!tree.remove(10));
    CHECK(tree.inorder().empty());
}

// Проверяет вставку, положение детей, поиск и запрет повторного ключа.
void testInsertAndFind() {
    BinarySearchTree<int> tree;
    CHECK(tree.insert(20));
    CHECK(tree.insert(10));
    CHECK(tree.insert(30));
    CHECK(!tree.insert(10));

    CHECK(tree.size() == 3);
    CHECK(!tree.empty());
    CHECK(tree.root() != nullptr);
    CHECK(tree.root()->value == 20);
    CHECK(tree.root()->left != nullptr);
    CHECK(tree.root()->right != nullptr);
    CHECK(tree.root()->left->value == 10);
    CHECK(tree.root()->right->value == 30);
    CHECK(tree.find(30) != nullptr);
    CHECK(tree.find(30)->value == 30);
    CHECK(tree.find(99) == nullptr);
}

// Проверяет, что симметричный обход возвращает ключи в порядке возрастания.
void testInorder() {
    BinarySearchTree<int> tree;
    tree.insert(20);
    tree.insert(30);
    tree.insert(-5);
    tree.insert(0);
    std::vector<int> values = tree.inorder();

    CHECK(values.size() == 4);
    CHECK(values[0] == -5);
    CHECK(values[1] == 0);
    CHECK(values[2] == 20);
    CHECK(values[3] == 30);
}

// Проверяет удаление листа и узлов с одним левым или правым ребёнком.
void testRemoveLeafAndOneChild() {
    BinarySearchTree<int> tree;
    tree.insert(20);
    tree.insert(10);
    tree.insert(5);
    tree.insert(30);
    tree.insert(35);

    CHECK(tree.remove(5)); // Лист.
    CHECK(tree.find(5) == nullptr);
    CHECK(tree.remove(30)); // Единственный правый ребёнок 35.
    CHECK(tree.root()->right->value == 35);
    tree.insert(3);
    CHECK(tree.remove(10)); // Единственный левый ребёнок 3.
    CHECK(tree.root()->left->value == 3);
    CHECK(tree.size() == 3);
    CHECK(!tree.remove(99));
    CHECK(tree.size() == 3);
}

// Проверяет удаление корня с двумя детьми и сохранение правого ребёнка преемника.
void testRemoveTwoChildren() {
    BinarySearchTree<int> tree;
    for (int value : {50, 30, 80, 60, 90, 55, 57}) {
        tree.insert(value);
    }
    CHECK(tree.remove(50));
    CHECK(tree.root()->value == 55);
    CHECK(tree.find(50) == nullptr);

    std::vector<int> expected = {30, 55, 57, 60, 80, 90};
    CHECK(tree.inorder() == expected);
    CHECK(tree.size() == 6);

    BinarySearchTree<int> smallTree;
    smallTree.insert(2);
    smallTree.insert(1);
    smallTree.insert(3);
    CHECK(smallTree.remove(2)); // Преемник — прямой правый ребёнок.
    CHECK(smallTree.root()->value == 3);
    CHECK(smallTree.root()->left->value == 1);
}

// Проверяет удаление корня с одним ребёнком и последнего узла дерева.
void testRemoveRoot() {
    BinarySearchTree<int> tree;
    tree.insert(20);
    tree.insert(10);
    CHECK(tree.remove(20));
    CHECK(tree.root()->value == 10);
    CHECK(tree.remove(10));
    CHECK(tree.root() == nullptr);
    CHECK(tree.empty());

    tree.insert(10);
    tree.insert(20);
    CHECK(tree.remove(10));
    CHECK(tree.root()->value == 20);
}

// Проверяет очистку вытянутого дерева и повторное использование.
void testClear() {
    BinarySearchTree<int> tree;
    for (int i = 0; i < 20; i++) {
        tree.insert(i);
    }
    CHECK(tree.inorder().size() == 20);
    tree.clear();
    tree.clear();
    CHECK(tree.empty());
    CHECK(tree.size() == 0);
    CHECK(tree.root() == nullptr);
    CHECK(tree.inorder().empty());

    CHECK(tree.insert(5));
    CHECK(tree.find(5) != nullptr);
}

// Запускает тесты дерева поиска.
int main() {
    return runTests({
        {"empty tree", testEmptyTree},
        {"insert and find", testInsertAndFind},
        {"inorder", testInorder},
        {"remove leaf and one child", testRemoveLeafAndOneChild},
        {"remove two children", testRemoveTwoChildren},
        {"remove root", testRemoveRoot},
        {"clear", testClear}
    });
}
