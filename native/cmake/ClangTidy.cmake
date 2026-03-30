# ClangTidy.cmake — opt-in clang-tidy integration.

option(ENABLE_CLANG_TIDY "Enable clang-tidy static analysis" OFF)

function(apply_clang_tidy target)
    if(NOT ENABLE_CLANG_TIDY)
        return()
    endif()
    find_program(CLANG_TIDY_EXE NAMES clang-tidy-19 clang-tidy)
    if(NOT CLANG_TIDY_EXE)
        message(WARNING "clang-tidy not found, skipping")
        return()
    endif()
    set_target_properties(${target} PROPERTIES
        CXX_CLANG_TIDY "${CLANG_TIDY_EXE}"
    )
endfunction()
