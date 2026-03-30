# Coverage.cmake — opt-in lcov coverage instrumentation.

option(ENABLE_COVERAGE "Enable code coverage instrumentation" OFF)

if(ENABLE_COVERAGE)
    add_compile_options(--coverage -fprofile-arcs -ftest-coverage)
    add_link_options(--coverage)
endif()

function(enable_coverage target)
    # Kept for backwards compatibility; global flags handle coverage now.
endfunction()
