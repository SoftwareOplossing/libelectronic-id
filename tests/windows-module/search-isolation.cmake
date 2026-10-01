# SPDX-FileCopyrightText: Let's Peppol contributors
# SPDX-License-Identifier: MIT

# Put the dependency only in CWD/PATH, not next to the requested module.
file(MAKE_DIRECTORY "${TEST_DIR}/private" "${TEST_DIR}/untrusted")
file(COPY "${MODULE}" DESTINATION "${TEST_DIR}/private")
file(COPY "${DEPENDENCY}" DESTINATION "${TEST_DIR}/untrusted")
get_filename_component(module_name "${MODULE}" NAME)
set(ENV{PATH} "${TEST_DIR}/untrusted;$ENV{PATH}")
execute_process(COMMAND "${TEST_EXE}" "${TEST_DIR}/private/${module_name}" expect-failure
    WORKING_DIRECTORY "${TEST_DIR}/untrusted" RESULT_VARIABLE result)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "Dependency search isolation failed: ${result}")
endif()
