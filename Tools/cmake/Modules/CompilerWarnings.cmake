# Defines set_project_warnings(<target>), applying a strict warning set for
# the detected compiler. Not called on anything yet (see the commented-out
# call site in the root CMakeLists.txt) -- intended to be enabled chapter by
# chapter as each one is cleaned up, not flipped on project-wide in one go.
# Adapted from cpp-best-practices/cpp_starter_project (lefticus), public
# domain (Unlicense): https://github.com/cpp-best-practices/cpp_starter_project
include_guard(GLOBAL)

function(set_project_warnings project_name)
    # Defaults to OFF here (upstream defaults this ON): turning on -Werror
    # before any chapter has been checked against this warning set would
    # just break the build. Flip to ON only once a given chapter's warnings
    # have actually been looked at, not as a blanket project-wide switch.
    option(WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)

    set(CLANG_WARNINGS
        -Wall
        -Wextra # reasonable and standard
        -Wshadow # warn the user if a variable declaration shadows one from a
                 # parent context
        -Wnon-virtual-dtor # warn if a class with virtual functions has a
                           # non-virtual destructor
        -Wold-style-cast # warn for c-style casts
        -Wcast-align # warn for potential performance problem casts
        -Wunused # warn on anything being unused
        -Woverloaded-virtual # warn if you overload (not override) a virtual
                              # function
        -Wpedantic # warn if non-standard C++ is used
        -Wconversion # warn on type conversions that may lose data
        -Wsign-conversion # warn on sign conversions
        -Wnull-dereference # warn if a null dereference is detected
        -Wdouble-promotion # warn if float is implicitly promoted to double
        -Wformat=2 # warn on security issues around functions that format
                   # output (ie printf)
        -Wimplicit-fallthrough # warn on statements that fallthrough without
                                # an explicit annotation
    )

    if(WARNINGS_AS_ERRORS)
        set(CLANG_WARNINGS ${CLANG_WARNINGS} -Werror)
    endif()

    set(GCC_WARNINGS
        ${CLANG_WARNINGS}
        -Wmisleading-indentation # warn if indentation implies blocks where
                                  # blocks do not exist
        -Wduplicated-cond # warn if if/else chain has duplicated conditions
        -Wduplicated-branches # warn if if/else branches have duplicated code
        -Wlogical-op # warn about logical operations being used where
                      # bitwise were probably wanted
        -Wuseless-cast # warn if you perform a cast to the same type
    )

    if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
        set(PROJECT_WARNINGS ${CLANG_WARNINGS})
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set(PROJECT_WARNINGS ${GCC_WARNINGS})
    else()
        log_warn(
            "No compiler warnings set for '${CMAKE_CXX_COMPILER_ID}' compiler."
        )
    endif()

    target_compile_options(${project_name} INTERFACE ${PROJECT_WARNINGS})
endfunction()
