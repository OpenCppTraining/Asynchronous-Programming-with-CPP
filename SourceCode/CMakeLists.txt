# Portability shims for standard library gaps (e.g. missing std::osyncstream or
# <generator> on Apple's libc++) and small platform-specific helpers.
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/compat)

# Add chapters
add_subdirectory(Chapter_03)
add_subdirectory(Chapter_04)
add_subdirectory(Chapter_05)
add_subdirectory(Chapter_06)
add_subdirectory(Chapter_07)
add_subdirectory(Chapter_08)
add_subdirectory(Chapter_09)
add_subdirectory(Chapter_10)
add_subdirectory(Chapter_11)
add_subdirectory(Chapter_12)
add_subdirectory(Chapter_13)
