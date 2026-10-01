# SPDX-FileCopyrightText: Let's Peppol contributors
# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.22)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    project(windows-module-tests LANGUAGES CXX)
    enable_testing()
endif()
if(NOT WIN32)
    message(FATAL_ERROR "These tests require Windows")
endif()

add_library(module-test-dependency SHARED dependency.cpp)
add_library(module-test-library SHARED library.cpp)
target_link_libraries(module-test-library PRIVATE module-test-dependency)
foreach(target module-test-library module-test-dependency)
    set_target_properties(${target} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/private"
        PREFIX "")
endforeach()

foreach(mode system private)
    add_executable(windows-module-test-${mode} test.cpp)
    target_compile_features(windows-module-test-${mode} PRIVATE cxx_std_17)
    target_include_directories(windows-module-test-${mode} PRIVATE ../../src/electronic-ids/pkcs11)
    add_dependencies(windows-module-test-${mode} module-test-library)
    if(mode STREQUAL "private")
        target_compile_definitions(windows-module-test-${mode} PRIVATE
            "ELECTRONIC_ID_BEID_MODULE_PATH=L\"C:/Program Files/Let's Peppol/eID/beidpkcs11.dll\"")
    endif()
    add_test(NAME windows-module-${mode}
        COMMAND windows-module-test-${mode} $<TARGET_FILE:module-test-library>)
endforeach()

add_test(NAME windows-module-search-isolation
    COMMAND ${CMAKE_COMMAND}
        -DTEST_EXE=$<TARGET_FILE:windows-module-test-system>
        -DMODULE=$<TARGET_FILE:module-test-library>
        -DDEPENDENCY=$<TARGET_FILE:module-test-dependency>
        -DTEST_DIR=${CMAKE_CURRENT_BINARY_DIR}/search-isolation
        -P ${CMAKE_CURRENT_SOURCE_DIR}/search-isolation.cmake)

add_test(NAME windows-module-configuration
    COMMAND ${CMAKE_COMMAND}
        -DFIXTURE=${CMAKE_CURRENT_SOURCE_DIR}/configuration
        -DTEST_DIR=${CMAKE_CURRENT_BINARY_DIR}/configuration-tests
        -DGENERATOR=${CMAKE_GENERATOR}
        -DCOMPILER=${CMAKE_CXX_COMPILER}
        -DMAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
        -P ${CMAKE_CURRENT_SOURCE_DIR}/configuration.cmake)
