# Sane defaults: a build type if none was given, compile_commands.json for
# clangd/editor tooling, colored diagnostics, and an opt-in LTO switch. Adapted
# from cpp-best-practices/cpp_starter_project (lefticus), public domain
# (Unlicense): https://github.com/cpp-best-practices/cpp_starter_project
include_guard(GLOBAL)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    log_info("Setting build type to 'RelWithDebInfo' as none was specified.")
    set(CMAKE_BUILD_TYPE
        RelWithDebInfo
        CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
                                                 "MinSizeRel" "RelWithDebInfo")
endif()

# Lets clangd and other LLVM-based tooling see the real compiler flags (include
# paths, -std=, etc.) instead of guessing.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(ENABLE_IPO
       "Enable Interprocedural Optimization, aka Link Time Optimization (LTO)"
       OFF)
if(ENABLE_IPO)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT result OUTPUT output)
    if(result)
        log_info("IPO is supported")
    else()
        log_error("IPO is not supported: '${output}'")
    endif()
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    add_compile_options(-fcolor-diagnostics)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_compile_options(-fdiagnostics-color=always)
endif()
