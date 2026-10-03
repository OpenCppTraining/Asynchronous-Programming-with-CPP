# Output directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BINARY_DIR}/Chapter_11)

# spdlog (reuses the fmt::fmt target already fetched at the project root instead
# of building spdlog's own bundled copy of fmt)
set(SPDLOG_FMT_EXTERNAL
    ON
    CACHE BOOL "" FORCE)
FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG 79524ddd08a4ec981b7fea76afd08ee05f83755d # frozen: v1.17.0
)
FetchContent_MakeAvailable(spdlog)

# Create executable for each cpp file
file(GLOB SOURCES "*.cpp")
foreach(SOURCE ${SOURCES})
    get_filename_component(EXECUTABLE_NAME ${SOURCE} NAME_WE)
    add_executable(${EXECUTABLE_NAME} ${SOURCE})
    target_link_libraries(
        ${EXECUTABLE_NAME}
        Boost::thread
        Boost::system
        Boost::container
        Boost::asio
        fmt::fmt
        spdlog::spdlog)
endforeach()
