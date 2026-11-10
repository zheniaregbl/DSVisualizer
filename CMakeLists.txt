cmake_minimum_required(VERSION 3.16)

project(DSVisualizer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)
set(QML_IMPORT_PATH ${CMAKE_BINARY_DIR} CACHE STRING "Qt Creator QML import path" FORCE)

# Content of downloaded design from Figma to Qt or similar
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/importedcontent/CMakeLists.txt")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/importedcontent)
endif()

qt_add_executable(appDSVisualizer
    main.cpp
)

set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(appDSVisualizer
    URI DSVisualizer
    VERSION 1.0
    QML_FILES
        Main.qml
        qml/Theme.qml
        qml/components/DsButton.qml
        qml/components/DsInput.qml
        qml/components/StructurePage.qml
        qml/StackPage.qml
        qml/QueuePage.qml
        qml/LinkedListPage.qml
    SOURCES
        src/core/ArrayStack.h
        src/core/ArrayQueue.h
        src/core/SinglyLinkedList.h
        src/model/StackModel.h
        src/model/StackModel.cpp
        src/model/QueueModel.h
        src/model/QueueModel.cpp
        src/model/LinkedListModel.h
        src/model/LinkedListModel.cpp
)

qt_add_resources(appDSVisualizer "controls_conf"
    PREFIX "/"
    FILES qtquickcontrols2.conf
)

target_include_directories(appDSVisualizer PRIVATE src/core src/model)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appDSVisualizer PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appDSVisualizer
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appDSVisualizer
    PRIVATE Qt6::Quick
)

install(TARGETS appDSVisualizer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
