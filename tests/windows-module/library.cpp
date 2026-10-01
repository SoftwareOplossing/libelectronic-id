// SPDX-FileCopyrightText: Let's Peppol contributors
// SPDX-License-Identifier: MIT
extern "C" __declspec(dllimport) int moduleDependency();
extern "C" __declspec(dllexport) int moduleValue() { return moduleDependency(); }
