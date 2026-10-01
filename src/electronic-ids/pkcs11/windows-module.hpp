// SPDX-FileCopyrightText: Let's Peppol contributors
// SPDX-License-Identifier: MIT

#pragma once

#include <Windows.h>
#include <filesystem>

namespace electronic_id::windows_module
{

inline std::filesystem::path belgianPath(const std::filesystem::path& systemDirectory)
{
#ifdef ELECTRONIC_ID_BEID_MODULE_PATH
    (void)systemDirectory;
    return ELECTRONIC_ID_BEID_MODULE_PATH;
#else
    return systemDirectory / L"beidpkcs11.dll";
#endif
}

// The caller supplies a trusted, explicit path. Production deployment must protect
// this directory and its parents against writes by unprivileged users.
inline HMODULE loadPrivateLibrary(const std::filesystem::path& module)
{
    if (!module.is_absolute()) {
        SetLastError(ERROR_BAD_PATHNAME);
        return nullptr;
    }
    // Also constrain transitive imports: neither CWD nor PATH is searched.
    auto nativePath = module;
    nativePath.make_preferred();
    return LoadLibraryExW(nativePath.c_str(), nullptr,
                          LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR | LOAD_LIBRARY_SEARCH_SYSTEM32);
}

} // namespace electronic_id::windows_module
