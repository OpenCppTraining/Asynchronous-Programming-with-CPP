# Opt-in static analysis via -D<option>=ON; none of these run by default, so
# including this module doesn't change the default build. clang-tidy wires
# up the project's existing .clang-tidy (still being reviewed/tuned, see
# that file). Adapted from cpp-best-practices/cpp_starter_project
# (lefticus), public domain (Unlicense):
# https://github.com/cpp-best-practices/cpp_starter_project
include_guard(GLOBAL)

option(ENABLE_CPPCHECK "Enable static analysis with cppcheck" OFF)
if(ENABLE_CPPCHECK)
    find_program(CPPCHECK cppcheck)
    if(CPPCHECK)
        set(CMAKE_CXX_CPPCHECK ${CPPCHECK} --suppress=missingInclude
                                --enable=all --inline-suppr --inconclusive)
    else()
        log_error("cppcheck requested but executable not found")
    endif()
endif()

option(ENABLE_CLANG_TIDY "Enable static analysis with clang-tidy" OFF)
if(ENABLE_CLANG_TIDY)
    find_program(CLANGTIDY clang-tidy)
    if(CLANGTIDY)
        set(CMAKE_CXX_CLANG_TIDY ${CLANGTIDY}
                                 -extra-arg=-Wno-unknown-warning-option)
    else()
        log_error("clang-tidy requested but executable not found")
    endif()
endif()

option(ENABLE_INCLUDE_WHAT_YOU_USE
       "Enable static analysis with include-what-you-use" OFF)
if(ENABLE_INCLUDE_WHAT_YOU_USE)
    find_program(INCLUDE_WHAT_YOU_USE include-what-you-use)
    if(INCLUDE_WHAT_YOU_USE)
        set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${INCLUDE_WHAT_YOU_USE})
    else()
        log_error("include-what-you-use requested but executable not found")
    endif()
endif()
