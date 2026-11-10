# Uzel — Data Structure Visualizer

**Uzel** (Russian for *node*) is a desktop application that visualizes classic data structures step by step. It was built as a course project for the university course **Data Structures and Algorithms**.

Every operation is animated on screen and runs alongside its pseudocode: the current line is highlighted as the operation progresses, and an operation log records each step. The goal is to show *how* a structure works internally and *why* each operation has its time complexity.

## Features

- **Step-by-step execution.** Operations run one step at a time, synchronized with highlighted pseudocode.
- **Internal state on screen.** Array indices, capacity, `front`/`rear` pointers, `head`/`tail` links.
- **Complexity at a glance.** Each structure lists the time complexity of its operations.
- **Operation log.** A history of every operation and its result.
- **Stop at any time.** A running operation can be interrupted with the *Stop* button or `Esc`.

## Data structures

| Structure | Implementation | Operations | Status |
|---|---|---|---|
| Stack | Dynamic array with capacity doubling | push, pop, peek | ✅ Done |
| Queue | Circular buffer (ring) with growth | enqueue, dequeue, front | ✅ Done |
| Linked list | Singly linked list with a tail pointer | push front/back, insert/remove at index, get by index, find by value | ✅ Done |
| Binary search tree | — | insert, search, remove | 🚧 In progress |
| Heap | — | insert, extract | 🚧 Planned |
| Hash table | — | insert, search, remove | 🚧 Planned |
| Structure advisor | Decision tree of questions | recommends a structure for a task | 🚧 Planned |

## Tech stack

- **C++** for data structure implementations
- **Qt 6** (Qt Quick / QML) for the UI and animations
- **CMake** as the build system

## Architecture

The project separates the data structures themselves from their presentation:

```
DSVisualizer/
├── src/
│   ├── core/       # Data structures in plain C++, without Qt
│   └── model/      # QAbstractListModel adapters that expose structures to QML
├── qml/
│   ├── components/ # Reusable UI: page template, buttons, inputs
│   ├── Theme.qml   # Colors and fonts
│   └── *Page.qml   # One page per data structure
├── Main.qml        # Window with navigation
└── main.cpp
```

- **`src/core`** contains the data structures as templates with no dependency on Qt. This is the algorithmic part of the project.
- **`src/model`** wraps each structure in a `QAbstractListModel`, so QML views are notified about inserts and removals and can animate them.
- **`qml/components/StructurePage.qml`** is a shared page template: header, stage, controls, pseudocode inspector and log. It also runs operations step by step.

## Building

**Requirements:** Qt 6.10 or newer (Qt Quick module), CMake 3.16+, a C++ compiler (MinGW or MSVC on Windows).

### Qt Creator

1. Open `CMakeLists.txt` in Qt Creator.
2. Select a Desktop kit.
3. Build and run.

### Command line

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH=<path-to-Qt>/6.10.x/<compiler>
cmake --build build
```

## License

Educational project.
