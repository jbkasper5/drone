cmake_minimum_required(VERSION 3.13)

set(PICO_SDK_PATH ${CMAKE_SOURCE_DIR}/packages/pico-sdk)
if(NOT EXISTS ${PICO_SDK_PATH}/external/pico_sdk_import.cmake)
    message(FATAL_ERROR "Pico SDK missing: run `git submodule update --init` in packages/pico-sdk")
endif()

set(PICO_BOARD pico2)
include(${PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(drone C CXX ASM)
pico_sdk_init()

# Equivalent of rpos's `find $(SRC_DIR) -name '*.c'`: every .c/.S under src/,
# at any depth. CONFIGURE_DEPENDS re-runs the glob each build, so new files
# and directories are picked up automatically.
file(GLOB_RECURSE SRCS CONFIGURE_DEPENDS
    ${CMAKE_SOURCE_DIR}/src/*.c
    ${CMAKE_SOURCE_DIR}/src/*.S
)

add_executable(drone ${SRCS})
target_include_directories(drone PRIVATE ${CMAKE_SOURCE_DIR}/include)
target_link_libraries(drone pico_stdlib)

pico_enable_stdio_usb(drone 1)
pico_enable_stdio_uart(drone 0)
pico_add_extra_outputs(drone)
