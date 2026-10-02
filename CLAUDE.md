# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Code repository for the Packt book *Asynchronous Programming with C++* (Javier Reguera-Salgado, Juan Antonio Rufes). Each `Chapter_NN/` directory holds standalone `.cpp` example files for that chapter — numbered `NxNN-description.cpp` (e.g. `Chapter_03/3x01-threads_creation.cpp`). Every example is independent; there is no shared library code except a couple of local headers in `Chapter_04` (`mutex_queue.h`, `semaphore_queue.h`).

## Build

CMake-based, one executable target per `.cpp` file (target name = filename without extension, via `file(GLOB SOURCES "*.cpp")` in each chapter's `CMakeLists.txt`).

```bash
cmake -S . -B build
cmake --build build
```

Binaries land in `build/bin/Chapter_NN/<target_name>`. Build a single example by name, e.g.:

```bash
cmake --build build --target 3x01-threads_creation
```

Requirements (enforced via `find_package(... REQUIRED)` in the root `CMakeLists.txt`, build fails without them):
- C++20 (Chapter_08 bumps itself to C++23 for its own subdirectory)
- Boost >= 1.86 (`thread system container`; Chapter_10 additionally needs the `cobalt` component)
- GoogleTest (root `enable_testing()` + `find_package(GTest REQUIRED)` — required project-wide even though only Chapter_12 has tests)
- `fmt`
- Chapter_13 additionally requires `benchmark` (Google Benchmark)

macOS: install deps via Homebrew (`boost`, `fmt`, `googletest`, `google-benchmark`). Linux (Ubuntu): `scripts/install_compilers.sh` installs multiple GCC versions (10–14), Clang/LLVM tools, CMake, GTest/GMock, and builds+installs Google Benchmark from source.

## Chapter-specific build behavior

- **Chapter_12**: defaults `USE_CLANG=ON` and hardcodes the compiler to `/usr/bin/clang++` for its own subdirectory (override with `-DUSE_CLANG=OFF` to use the project-wide compiler). Per-target sanitizer flags are auto-applied by matching the target name: `*ASAN*`, `*LSAN*`, `*MSAN*`, `*TSAN*`, `*UBSAN*` get the matching `-fsanitize=` compile/link flags; targets matching `*test*` get linked against `GTest::GTest GTest::Main GTest::gmock_main` and registered via `gtest_discover_tests`.
- **Chapter_13**: forces `-O3 -DNDEBUG -march=native` unconditionally (ignores `CMAKE_BUILD_TYPE`) and links every target against `benchmark::benchmark` instead of Boost.
- **Chapter_10**: only chapter requiring the Boost `cobalt` component; re-declares C++20 locally.
- **Chapter_05**: links `atomic` explicitly in addition to Boost.
- **Chapter_11**: links `fmt::fmt` in addition to Boost.
- Adding a new chapter: create `Chapter_NN/`, add a `CMakeLists.txt` following the existing GLOB-per-cpp pattern, and add `add_subdirectory(Chapter_NN)` to the root `CMakeLists.txt`.

## Code style

`.clang-format`: Google base style, 4-space indent, 120 column limit.

## Editor/debug config

`.vscode/tasks.json` and `launch.json` build/debug the *currently open file only* via a raw `g++` invocation (not through CMake) — paths in there are Linux-specific (`/usr/bin/g++`, `/usr/include/boost/`, `gdb`) and won't work as-is on macOS.
