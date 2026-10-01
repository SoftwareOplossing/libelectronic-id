# SPDX-FileCopyrightText: Let's Peppol contributors
# SPDX-License-Identifier: MIT

function(check_path name path valid)
    execute_process(COMMAND "${CMAKE_COMMAND}" -S "${FIXTURE}" -B "${TEST_DIR}/${name}"
        -G "${GENERATOR}" "-DCMAKE_CXX_COMPILER=${COMPILER}" "-DCMAKE_MAKE_PROGRAM=${MAKE_PROGRAM}"
        "-DELECTRONIC_ID_BEID_MODULE_PATH=${path}"
        RESULT_VARIABLE result OUTPUT_VARIABLE output ERROR_VARIABLE error)
    if(valid AND NOT result EQUAL 0)
        message(FATAL_ERROR "Valid ${name} rejected: ${output}${error}")
    elseif(NOT valid AND result EQUAL 0)
        message(FATAL_ERROR "Invalid ${name} accepted")
    endif()
    if(valid)
        execute_process(COMMAND "${CMAKE_COMMAND}" --build "${TEST_DIR}/${name}" --config Release
            RESULT_VARIABLE result OUTPUT_VARIABLE output ERROR_VARIABLE error)
        if(NOT result EQUAL 0)
            message(FATAL_ERROR "Valid ${name} failed to compile: ${output}${error}")
        endif()
    endif()
endfunction()
check_path(default "" TRUE)
check_path(absolute "C:/Program Files/Let's Peppol/eID/beidpkcs11.dll" TRUE)
check_path(backslashes "C:\\Program Files\\Let's Peppol\\eID\\beidpkcs11.dll" TRUE)
check_path(relative "beidpkcs11.dll" FALSE)
check_path(drive-relative "C:beidpkcs11.dll" FALSE)
check_path(unc "//server/share/beidpkcs11.dll" FALSE)
check_path(traversal "C:/trusted/../beidpkcs11.dll" FALSE)
check_path(wrong-file "C:/trusted/other.dll" FALSE)
check_path(quote "C:/bad\"/beidpkcs11.dll" FALSE)
check_path(list "C:/bad;/beidpkcs11.dll" FALSE)
check_path(hash "C:/bad#/beidpkcs11.dll" FALSE)
