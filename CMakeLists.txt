cmake_minimum_required(VERSION 3.5..3.29)
project("Asynchronous Programming in C++")

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Find Boost
find_package(Boost 1.86.0 REQUIRED COMPONENTS thread system container)
if(NOT Boost_FOUND)
    message(FATAL_ERROR "Boost 1.86.0 is required but not found.")
endif()

# Include Boost directories
include_directories(${Boost_INCLUDE_DIRS})

# Find GoogleTest
enable_testing()
find_package(GTest REQUIRED)
if(NOT GTest_FOUND)
    message(FATAL_ERROR "GoogleTest library is required but not found.")
endif()
include(GoogleTest)

# Include GoogleTest directories
include_directories(${GTest_INCLUDE_DIRS})

# Add {fmt} library
find_package(fmt)
if(NOT fmt_FOUND)
    message(FATAL_ERROR "fmt library is required but not found.")
endif()

# Linker flags
if((CMAKE_CXX_COMPILER_ID MATCHES GNU) OR (CMAKE_CXX_COMPILER_ID MATCHES Clang))
    set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS} -O0 -g3 -Wall -Wextra -pedantic")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -O3 -DNDEBUG -Wall -Wextra -pedantic")
endif()

# Set the output directory for binaries
set(BINARY_DIR ${CMAKE_BINARY_DIR}/bin)

# Add source code
add_subdirectory(SourceCode)

# Convenience target that depends on every example executable, recursively
# collected from SourceCode's chapter subdirectories (same set the default
# "all" target already builds; this just gives it a discoverable name).
function(collect_buildsystem_targets dir out_var)
    get_property(targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
    get_property(subdirs DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)
    foreach(subdir ${subdirs})
        collect_buildsystem_targets(${subdir} sub_targets)
        list(APPEND targets ${sub_targets})
    endforeach()
    set(${out_var} ${targets} PARENT_SCOPE)
endfunction()

collect_buildsystem_targets(${CMAKE_SOURCE_DIR}/SourceCode ALL_EXAMPLE_TARGETS)
add_custom_target(build_all DEPENDS ${ALL_EXAMPLE_TARGETS})
