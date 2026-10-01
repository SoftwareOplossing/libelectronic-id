// SPDX-FileCopyrightText: Let's Peppol contributors
// SPDX-License-Identifier: MIT

#include "windows-module.hpp"
#include <iostream>
#include <stdexcept>

using namespace electronic_id::windows_module;
namespace fs = std::filesystem;

void require(bool condition, const char* message)
{
    if (!condition) {
        throw std::runtime_error(message);
    }
}

int main(int argc, char** argv)
{
    try {
        require(argc >= 2, "Missing fixture DLL path");
        const fs::path module = fs::u8path(argv[1]);
        if (argc == 3) {
            auto handle = loadPrivateLibrary(module);
            if (handle) FreeLibrary(handle);
            require(!handle, "Loaded a dependency from an untrusted search directory");
            return 0;
        }
#ifdef ELECTRONIC_ID_BEID_MODULE_PATH
        require(belgianPath(L"C:/Windows/System32") ==
                    fs::path(L"C:/Program Files/Let's Peppol/eID/beidpkcs11.dll"),
                "Private path was not selected");
        require(belgianPath({}).make_preferred() == belgianPath({}),
                "Preferred separators changed path equality used by the loader");
        require(belgianPath(L"D:/OtherSystem") == belgianPath({}),
                "System directory changed the private path");
#else
        require(belgianPath(L"C:/Windows/System32") ==
                    fs::path(L"C:/Windows/System32/beidpkcs11.dll"),
                "Default system path changed");
#endif
        require(!loadPrivateLibrary(module.filename()), "Accepted a relative path");
        require(GetLastError() == ERROR_BAD_PATHNAME, "Missing relative-path diagnostic");
        require(!loadPrivateLibrary(L"C:beidpkcs11.dll"), "Accepted a drive-relative path");
        require(!loadPrivateLibrary(module.parent_path() / L"missing.dll"),
                "Missing explicit DLL unexpectedly loaded");
        auto handle = loadPrivateLibrary(module);
        if (!handle) std::cerr << "Win32 load error: " << GetLastError() << '\n';
        require(handle != nullptr, "Private DLL or sibling dependency did not load");
        auto value = reinterpret_cast<int (*)()>(GetProcAddress(handle, "moduleValue"));
        const bool valid = value && value() == 42;
        FreeLibrary(handle);
        require(valid, "Wrong module or dependency loaded");
        std::cout << "Module path and load checks passed\n";
        return 0;
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
