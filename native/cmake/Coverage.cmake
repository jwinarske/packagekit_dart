# Coverage.cmake — opt-in lcov coverage instrumentation.

option(ENABLE_COVERAGE "Enable code coverage instrumentation" OFF)

function(enable_coverage target)
    if(NOT ENABLE_COVERAGE)
        return()
    endif()
    target_compile_options(${target} PRIVATE --coverage -fprofile-arcs -ftest-coverage)
    target_link_options(${target}    PRIVATE --coverage)
endfunction()
