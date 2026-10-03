# Leveled, colored message() wrapper used by the other modules in this
# directory. Adapted from cpp-best-practices/cpp_starter_project (lefticus),
# public domain (Unlicense):
# https://github.com/cpp-best-practices/cpp_starter_project
include_guard(GLOBAL)

if(NOT WIN32)
    string(ASCII 27 Esc)
    set(ColourReset "${Esc}[m")
    set(Green "${Esc}[32m")
    set(Cyan "${Esc}[36m")
    set(BoldYellow "${Esc}[1;33m")
    set(BoldRed "${Esc}[1;31m")
endif()

set(CMAKE_LOG_LEVEL_TRACE 2)
set(CMAKE_LOG_LEVEL_DEBUG 3)
set(CMAKE_LOG_LEVEL_INFO 4)
set(CMAKE_LOG_LEVEL_WARNING 5)
set(CMAKE_LOG_LEVEL_ERROR 6)
set(CMAKE_LOG_LEVEL_FATAL 7)

option(CMAKE_CURRENT_LOG_LEVEL "Set CMake current log level"
       ${CMAKE_LOG_LEVEL_INFO})

if(CMAKE_CURRENT_LOG_LEVEL STREQUAL "OFF")
    set(CMAKE_CURRENT_LOG_LEVEL ${CMAKE_LOG_LEVEL_INFO})
endif()

function(log_message msg log_level)
    if(NOT ${log_level} LESS CMAKE_CURRENT_LOG_LEVEL)
        message(${msg})
    endif()
endfunction()

function(log_trace msg)
    log_message("[TRACE] ${msg}" ${CMAKE_LOG_LEVEL_TRACE})
endfunction()

function(log_debug msg)
    log_message("${Cyan}[DEBUG]${ColourReset} ${msg}" ${CMAKE_LOG_LEVEL_DEBUG})
endfunction()

function(log_info msg)
    log_message("${Green}[INFO]${ColourReset} ${msg}" ${CMAKE_LOG_LEVEL_INFO})
endfunction()

function(log_warn msg)
    log_message("${BoldYellow}[WARNING]${ColourReset} ${msg}"
                ${CMAKE_LOG_LEVEL_WARNING})
endfunction()

function(log_error msg)
    message(SEND_ERROR "${BoldRed}[ERROR]${ColourReset} ${msg}")
endfunction()

function(log_fatal msg)
    message(FATAL_ERROR "${BoldRed}[FATAL]${ColourReset} ${msg}")
endfunction()
