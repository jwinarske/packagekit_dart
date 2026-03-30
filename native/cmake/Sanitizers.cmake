# Sanitizers.cmake — opt-in ASAN + UBSan for debug builds.

option(ENABLE_ASAN   "Enable AddressSanitizer"          OFF)
option(ENABLE_UBSAN  "Enable UndefinedBehaviorSanitizer" OFF)

function(apply_sanitizers target)
    set(_flags "")
    if(ENABLE_ASAN)
        list(APPEND _flags -fsanitize=address -fno-omit-frame-pointer)
    endif()
    if(ENABLE_UBSAN)
        list(APPEND _flags -fsanitize=undefined)
    endif()
    if(_flags)
        target_compile_options(${target} PRIVATE ${_flags})
        target_link_options(${target}    PRIVATE ${_flags})
    endif()
endfunction()
