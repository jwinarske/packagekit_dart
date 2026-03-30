cmake_minimum_required(VERSION 3.22)
project(packagekit_nc CXX C)

set(CMAKE_CXX_STANDARD  23)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ── sdbus-cpp v2 as submodule (matches jwinarske/sdbus-cpp-examples) ──────────
# This avoids the system sdbus-cpp version lottery across distributions.
set(BUILD_SHARED_LIBS OFF)
add_subdirectory(third_party/sdbus-cpp EXCLUDE_FROM_ALL)

# ── CMake modules ─────────────────────────────────────────────────────────────
include(cmake/Sanitizers.cmake)
include(cmake/ClangTidy.cmake)
include(cmake/ClangFormat.cmake)
include(cmake/Coverage.cmake)

# ── dart_api_dl — compile as plain C ─────────────────────────────────────────
add_library(dart_api_dl OBJECT src/dart_api_dl.c)
target_include_directories(dart_api_dl PUBLIC include)

# ── Main shared library ───────────────────────────────────────────────────────
add_library(packagekit_nc SHARED
    src/pk_bridge.cpp
    src/pk_manager.cpp
    src/pk_transaction.cpp
    $<TARGET_OBJECTS:dart_api_dl>
)

target_include_directories(packagekit_nc
    PRIVATE
        include
        generated         # sdbus-c++-xml2cpp output headers
        ${SDBUS_CPP_INCLUDE_DIR}
)

target_link_libraries(packagekit_nc
    PRIVATE
        sdbus-c++           # sdbus-cpp v2 static (from submodule)
        pthread
)

set_target_properties(packagekit_nc PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    POSITION_INDEPENDENT_CODE ON
    OUTPUT_NAME "packagekit_nc"
)

apply_sanitizers(packagekit_nc)
apply_clang_tidy(packagekit_nc)

if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(test)
endif()

if(ENABLE_COVERAGE)
    enable_coverage(packagekit_nc)
endif()

add_clang_format_targets()
