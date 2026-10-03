# Output directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BINARY_DIR}/Chapter_11)

# Find spdlog
find_package(spdlog REQUIRED)
if(NOT spdlog_FOUND)
    message(FATAL_ERROR "spdlog library is required but not found.")
endif()

# Create executable for each cpp file
file(GLOB SOURCES "*.cpp")
foreach(SOURCE ${SOURCES})
    get_filename_component(EXECUTABLE_NAME ${SOURCE} NAME_WE)
    add_executable(${EXECUTABLE_NAME} ${SOURCE})
    target_link_libraries(${EXECUTABLE_NAME} ${Boost_LIBRARIES} fmt::fmt
                          spdlog::spdlog)
endforeach()
