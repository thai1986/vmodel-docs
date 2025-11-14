cmake_minimum_required(VERSION 3.14)
project(VModelAuth VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(GTest CONFIG REQUIRED)

# Include directories
include_directories(${CMAKE_SOURCE_DIR})

# Create the authentication library
add_library(authentication_module
    src/authentication_module.cpp
    src/authentication_module.h
)

# Create the test executable
add_executable(test_authentication
    tests/test_authentication_module.cpp
)

# Link libraries
target_link_libraries(test_authentication
    authentication_module
    GTest::gtest
    GTest::gtest_main
)

# Enable testing
enable_testing()
add_test(NAME AuthenticationTests COMMAND test_authentication)

# Compiler flags for better error reporting
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    target_compile_options(authentication_module PRIVATE /W4)
    target_compile_options(test_authentication PRIVATE /W4)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    target_compile_options(authentication_module PRIVATE -Wall -Wextra -Wpedantic)
    target_compile_options(test_authentication PRIVATE -Wall -Wextra -Wpedantic)
endif()

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)