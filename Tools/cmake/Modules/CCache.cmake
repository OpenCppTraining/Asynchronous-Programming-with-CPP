# Speeds up repeated builds, which matters here since FetchContent rebuilds
# Boost/GoogleTest/fmt/spdlog/benchmark from source on every clean build dir.
# Adapted from cpp-best-practices/cpp_starter_project (lefticus), public
# domain (Unlicense): https://github.com/cpp-best-practices/cpp_starter_project
include_guard(GLOBAL)

option(ENABLE_CACHE "Enable cache if available" ON)
if(NOT ENABLE_CACHE)
    return()
endif()

set(CACHE_OPTION
    "ccache"
    CACHE STRING "Compiler cache to be used")
set(CACHE_OPTION_VALUES "ccache" "sccache")
set_property(CACHE CACHE_OPTION PROPERTY STRINGS ${CACHE_OPTION_VALUES})

find_program(CACHE_BINARY ${CACHE_OPTION})
if(CACHE_BINARY)
    log_info("${CACHE_OPTION} found and enabled")
    set(CMAKE_CXX_COMPILER_LAUNCHER ${CACHE_BINARY})
else()
    log_warn("${CACHE_OPTION} is enabled but was not found. Not using it")
endif()
