# Rejects `cmake .` run directly in the source tree, forcing a separate
# build directory. Adapted from cpp-best-practices/cpp_starter_project
# (lefticus), public domain (Unlicense):
# https://github.com/cpp-best-practices/cpp_starter_project
include_guard(GLOBAL)

function(assure_out_of_source_builds)
    get_filename_component(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
    get_filename_component(bindir "${CMAKE_BINARY_DIR}" REALPATH)

    if("${srcdir}" STREQUAL "${bindir}")
        message(FATAL_ERROR
                "In-source builds are disabled. Create a separate build "
                "directory and run cmake from there, e.g. "
                "`cmake -S . -B build`.")
    endif()
endfunction()

assure_out_of_source_builds()
