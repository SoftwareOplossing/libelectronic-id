# SPDX-FileCopyrightText: Let's Peppol contributors
# SPDX-License-Identifier: MIT

set(ELECTRONIC_ID_BEID_MODULE_PATH "" CACHE STRING
    "Absolute private Belgian PKCS#11 DLL path (Windows only; empty uses system middleware)")

function(configure_beid_module target)
    if(ELECTRONIC_ID_BEID_MODULE_PATH STREQUAL "")
        return()
    endif()
    if(NOT WIN32)
        message(FATAL_ERROR "ELECTRONIC_ID_BEID_MODULE_PATH is supported only on Windows")
    endif()
    # This is a build-time setting, never a website, environment or registry override.
    # Restrict characters that cannot safely appear in a compiler definition.
    if(ELECTRONIC_ID_BEID_MODULE_PATH MATCHES "[\";#\n\r]")
        message(FATAL_ERROR "Invalid characters in ELECTRONIC_ID_BEID_MODULE_PATH")
    endif()
    string(REPLACE "\\" "/" module_path "${ELECTRONIC_ID_BEID_MODULE_PATH}")
    if(NOT module_path MATCHES "^[A-Za-z]:/" OR module_path MATCHES "(^|/)\\.\\.?(/|$)")
        message(FATAL_ERROR "ELECTRONIC_ID_BEID_MODULE_PATH must be an absolute local path without dot segments")
    endif()
    if(NOT module_path MATCHES "/beidpkcs11\\.dll$")
        message(FATAL_ERROR "ELECTRONIC_ID_BEID_MODULE_PATH must name beidpkcs11.dll")
    endif()
    # The manager is defined in a header; consumers must see the same definition.
    target_compile_definitions(${target} PUBLIC
        "ELECTRONIC_ID_BEID_MODULE_PATH=L\"${module_path}\"")
    if(MSVC)
        target_compile_options(${target} PUBLIC /utf-8)
    endif()
endfunction()
