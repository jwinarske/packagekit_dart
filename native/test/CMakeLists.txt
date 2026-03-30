find_package(GTest REQUIRED)

add_executable(test_types test_types.cpp)
target_include_directories(test_types PRIVATE ${CMAKE_SOURCE_DIR}/include)
target_link_libraries(test_types PRIVATE GTest::gtest GTest::gtest_main)
add_test(NAME test_types COMMAND test_types)
