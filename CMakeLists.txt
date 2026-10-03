cmake_minimum_required(VERSION 3.5..3.29)
project("Asynchronous Programming in C++")

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

include(FetchContent)

# Boost, built from source instead of relying on a system package manager:
# Ubuntu's apt Boost is older than this project's minimum, and Homebrew's bottle
# doesn't build Boost.Cobalt at all. Only the components the examples actually
# use are configured/built (BOOST_INCLUDE_LIBRARIES trims the rest of Boost's
# ~160 libraries out of the build).
set(BOOST_INCLUDE_LIBRARIES thread system container asio cobalt)
set(BOOST_ENABLE_CMAKE ON)
FetchContent_Declare(
    Boost
    URL https://github.com/boostorg/boost/releases/download/boost-1.88.0/boost-1.88.0-cmake.tar.xz
    URL_HASH
        SHA256=f48b48390380cfb94a629872346e3a81370dc498896f16019ade727ab72eb1ec
    DOWNLOAD_EXTRACT_TIMESTAMP ON)
FetchContent_MakeAvailable(Boost)

# GoogleTest
enable_testing()
set(INSTALL_GTEST
    OFF
    CACHE BOOL "" FORCE)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG 063de7e9578f82b369302001269680b4b1553359 # frozen: v1.18.0
)
FetchContent_MakeAvailable(googletest)
include(GoogleTest)

# {fmt}
FetchContent_Declare(
    fmt
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git
    GIT_TAG 1be298e1bd68957e4cd352e1f676f00e07dcfb57 # frozen: 12.2.0
)
FetchContent_MakeAvailable(fmt)

# Linker flags
if((CMAKE_CXX_COMPILER_ID MATCHES GNU) OR (CMAKE_CXX_COMPILER_ID MATCHES Clang))
    set(CMAKE_CXX_FLAGS_DEBUG
        "${CMAKE_CXX_FLAGS} -O0 -g3 -Wall -Wextra -pedantic")
    set(CMAKE_CXX_FLAGS_RELEASE
        "${CMAKE_CXX_FLAGS} -O3 -DNDEBUG -Wall -Wextra -pedantic")
endif()

# Set the output directory for binaries
set(BINARY_DIR ${CMAKE_BINARY_DIR}/bin)

# Add source code
add_subdirectory(SourceCode)

# Convenience target that depends on every example executable, recursively
# collected from SourceCode's chapter subdirectories (same set the default "all"
# target already builds; this just gives it a discoverable name).
function(collect_buildsystem_targets dir out_var)
    get_property(
        targets
        DIRECTORY ${dir}
        PROPERTY BUILDSYSTEM_TARGETS)
    get_property(
        subdirs
        DIRECTORY ${dir}
        PROPERTY SUBDIRECTORIES)
    foreach(subdir ${subdirs})
        collect_buildsystem_targets(${subdir} sub_targets)
        list(APPEND targets ${sub_targets})
    endforeach()
    set(${out_var}
        ${targets}
        PARENT_SCOPE)
endfunction()

collect_buildsystem_targets(${CMAKE_SOURCE_DIR}/SourceCode ALL_EXAMPLE_TARGETS)
add_custom_target(build_all DEPENDS ${ALL_EXAMPLE_TARGETS})
