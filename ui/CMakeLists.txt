cmake_minimum_required(VERSION 3.29)
project(ui)

set(CMAKE_CXX_STANDARD 14)

add_executable(ui main.c)

set(LV_CONF_PATH
        ${CMAKE_CURRENT_SOURCE_DIR}/lv_conf.h
        CACHE STRING "" FORCE)

add_subdirectory(${PROJECT_SOURCE_DIR}/lvgl EXCLUDE_FROM_ALL)

target_link_libraries(ui PRIVATE lvgl)
