# Алгоритмические тесты не зависят от Qt и не запускают графический интерфейс.
set(CORE_TEST_NAMES array stack queue list tree heap hash)
set(CORE_TEST_TARGETS "")
foreach(name IN LISTS CORE_TEST_NAMES)
    add_executable(test_${name} test_${name}.cpp)
    target_compile_features(test_${name} PRIVATE cxx_std_17)
    # Включаем библиотеки MinGW внутрь тестового exe.
    # Тогда запуск из обычного CMD не требует DLL компилятора в PATH.
    if(MINGW)
        target_link_options(test_${name} PRIVATE -static)
    endif()
    target_include_directories(test_${name} PRIVATE ${PROJECT_SOURCE_DIR}/src/core)
    # Qt включает автоматическую обработку moc для проекта; ядру она не нужна.
    set_target_properties(test_${name} PROPERTIES AUTOMOC OFF AUTOUIC OFF AUTORCC OFF)
    add_test(NAME core.${name} COMMAND test_${name})
    set_tests_properties(core.${name} PROPERTIES LABELS "unit;core" TIMEOUT 30)
    list(APPEND CORE_TEST_TARGETS test_${name})
endforeach()
add_custom_target(core_tests DEPENDS ${CORE_TEST_TARGETS})
