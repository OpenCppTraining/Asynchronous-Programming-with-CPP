# Output directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BINARY_DIR}/Chapter_05)

# Create executable for each cpp file
file(GLOB SOURCES "*.cpp")
foreach(SOURCE ${SOURCES})
    get_filename_component(EXECUTABLE_NAME ${SOURCE} NAME_WE)
    add_executable(${EXECUTABLE_NAME} ${SOURCE})
    target_link_libraries(${EXECUTABLE_NAME} ${Boost_LIBRARIES})
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        # libatomic backs non-lock-free std::atomic<T> on GCC/glibc; Clang/macOS
        # has no separate library for this (handled by compiler-rt).
        target_link_libraries(${EXECUTABLE_NAME} atomic)
    endif()
endforeach()
