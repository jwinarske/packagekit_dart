# ClangFormat.cmake — add format / format-check targets.

function(add_clang_format_targets)
    find_program(CLANG_FORMAT_EXE NAMES clang-format-19 clang-format)
    if(NOT CLANG_FORMAT_EXE)
        return()
    endif()

    file(GLOB_RECURSE ALL_CXX_SOURCES
        ${CMAKE_SOURCE_DIR}/include/*.h
        ${CMAKE_SOURCE_DIR}/src/*.cpp
        ${CMAKE_SOURCE_DIR}/src/*.c
        ${CMAKE_SOURCE_DIR}/test/*.cpp
    )

    add_custom_target(format
        COMMAND ${CLANG_FORMAT_EXE} -i ${ALL_CXX_SOURCES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running clang-format (in-place)"
    )

    add_custom_target(format-check
        COMMAND ${CLANG_FORMAT_EXE} --dry-run --Werror ${ALL_CXX_SOURCES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Checking clang-format"
    )
endfunction()
