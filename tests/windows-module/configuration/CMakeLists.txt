# SPDX-FileCopyrightText: Let's Peppol contributors
# SPDX-License-Identifier: MIT
cmake_minimum_required(VERSION 3.22)
project(configuration-test LANGUAGES CXX)
include(../../../cmake/BeidModule.cmake)
add_library(configuration-target STATIC ../test.cpp)
target_compile_features(configuration-target PRIVATE cxx_std_17)
target_include_directories(configuration-target PRIVATE ../../../src/electronic-ids/pkcs11)
configure_beid_module(configuration-target)
