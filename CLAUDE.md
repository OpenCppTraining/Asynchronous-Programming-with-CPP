# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Code repository for the Packt book *Asynchronous Programming with C++* (Javier Reguera-Salgado, Juan Antonio Rufes). Each `SourceCode/Chapter_NN/` directory holds standalone `.cpp` example files for that chapter — numbered `NxNN-description.cpp` (e.g. `SourceCode/Chapter_03/3x01-threads_creation.cpp`). Every example is independent; there is no shared library code except a couple of local headers in `Chapter_04` (`mutex_queue.h`, `semaphore_queue.h`) and the portability shims under `SourceCode/compat/` (see below).

## Build

CMake-based, one executable target per `.cpp` file (target name = filename without extension, via `file(GLOB SOURCES "*.cpp")` in each chapter's `CMakeLists.txt`). The root `CMakeLists.txt` delegates to `SourceCode/CMakeLists.txt`, which lists the chapters.

```bash
cmake -S . -B build
cmake --build build --target build_all
```

`build_all` is a convenience target depending on every example executable, recursively collected from `SourceCode/`'s chapter subdirectories — equivalent to the default `all` target, just discoverable by name. Binaries land in `build/bin/Chapter_NN/<target_name>`. Build a single example by name, e.g.:

```bash
cmake --build build --target 3x01-threads_creation
```

Run the GTest-based tests (Chapter_12 only) via `ctest --output-on-failure` from inside `build/`.

### CMake presets

`CMakePresets.json` offers `<os>-<compiler>-<debug|release>` presets (e.g. `macos-clang-debug`, `linux-gcc-release`), each using Ninja and binary dir `build/<presetName>`:

```bash
cmake --preset macos-clang-debug
cmake --build --preset macos-clang-debug
ctest --preset macos-clang-debug
```

Presets are conditioned on `hostSystemName`, so `cmake --list-presets` only shows the ones valid for the current OS. `macos-gcc-*` expects Homebrew GCC (`gcc-15`/`g++-15`) — Apple's own `gcc` is a Clang alias.

### Build tooling (`Tools/cmake/Modules/`)

Adapted from `cpp-best-practices/cpp_starter_project` (lefticus), public domain. Included via `BuildTools.cmake` near the top of the root `CMakeLists.txt` (before `FetchContent`), except `StaticAnalyzers.cmake`, which is included separately right before `add_subdirectory(SourceCode)` — deliberately placed *after* the FetchContent calls so an opt-in `-DENABLE_CLANG_TIDY=ON` (etc.) only lints this project's own code, not the fetched Boost/GoogleTest/fmt/spdlog/benchmark sources.

- `PreventInSourceBuilds.cmake`: rejects `cmake .` run directly in the source tree.
- `StandardProjectSettings.cmake`: defaults `CMAKE_BUILD_TYPE` to `RelWithDebInfo` if unset, turns on `CMAKE_EXPORT_COMPILE_COMMANDS` (needed for clangd/editor tooling to see real compiler flags), colored diagnostics, opt-in LTO (`-DENABLE_IPO=ON`).
- `CCache.cmake`: uses `ccache` as `CMAKE_CXX_COMPILER_LAUNCHER` if found (`-DENABLE_CACHE=OFF` to disable) — meaningfully speeds up repeat builds now that FetchContent recompiles the vendored dependencies from source (~4x faster on a second clean build in testing).
- `StaticAnalyzers.cmake`: `-DENABLE_CLANG_TIDY=ON` wires up this project's `.clang-tidy` (see Code style below); `-DENABLE_CPPCHECK=ON` / `-DENABLE_INCLUDE_WHAT_YOU_USE=ON` are also available. All OFF by default.
- Not adopted from the source template, deliberately: `CompilerWarnings.cmake` (its `WARNINGS_AS_ERRORS` default would almost certainly break the existing examples, which weren't written against `-Wconversion -Wold-style-cast` etc.), `Sanitizers.cmake` (redundant with Chapter_12's existing per-target, per-example sanitizer logic), `CPM.cmake`/`Fetch*.cmake` (would duplicate/conflict with this project's own `FetchContent` setup), `CodeCoverage.cmake`/`Doxygen.cmake` (disproportionate for a book-examples repo with no API to document and a 12-test suite).

### Dependencies

All third-party dependencies (Boost, GoogleTest, `fmt`, `spdlog`, `benchmark`) are fetched and built from source via CMake's `FetchContent` — nothing needs to be installed system-wide first. The only prerequisites are a C++20 compiler, CMake, and git/network access on first configure (sources are cached under `build/_deps/` afterward). This replaced relying on system package managers because Ubuntu's apt Boost is older than this project's minimum and Homebrew's bottle doesn't build Boost.Cobalt at all — building from source sidesteps both.

- Boost is fetched from the official `boost-<version>-cmake.tar.xz` release asset (modular per-library CMake build). `BOOST_INCLUDE_LIBRARIES` in the root `CMakeLists.txt` limits the build to the components actually used (`thread`, `system`, `container`, `asio`, `cobalt`) instead of all ~160 Boost libraries.
- Link against modern per-component targets (`Boost::thread`, `Boost::system`, `Boost::container`, `Boost::asio`, `Boost::cobalt`), not the old `${Boost_LIBRARIES}` variable — FetchContent doesn't populate that variable (that's a `find_package`-only mechanism). `Boost::asio` is header-only but still needs to be explicitly linked for its include path to propagate, since modular Boost targets don't share one umbrella include directory the way a traditional system install does.
- GoogleTest and `fmt` are fetched at the project root (used by multiple chapters). `spdlog` is fetched inside `Chapter_11/CMakeLists.txt` (`SPDLOG_FMT_EXTERNAL ON`, so it reuses the root's `fmt::fmt` instead of its own bundled copy) and `benchmark` inside `Chapter_13/CMakeLists.txt` — both single-chapter dependencies, declared where they're used rather than at the root.
- GoogleTest fetched this way only exports the modern lowercase targets (`GTest::gtest`, `GTest::gtest_main`, `GTest::gmock_main`), not the legacy `GTest::GTest`/`GTest::Main` aliases that `find_package(GTest)`'s compatibility module adds.
- All FetchContent declarations pin an exact commit SHA with a `# frozen: vX.Y.Z` comment, not a mutable tag/branch.

## Chapter-specific build behavior

- **Chapter_12**: defaults `USE_CLANG=ON` and hardcodes the compiler to `/usr/bin/clang++` for its own subdirectory (override with `-DUSE_CLANG=OFF` to use the project-wide compiler). Per-target sanitizer flags are auto-applied by matching the target name: `*ASAN*`, `*TSAN*`, `*UBSAN*` get the matching `-fsanitize=` compile/link flags; `*LSAN*`/`*MSAN*` do too except on macOS/arm64, where both are unsupported (the target still builds, just without the sanitizer, with a `message(WARNING ...)`); targets matching `*test*` get linked against `GTest::gtest GTest::gtest_main GTest::gmock_main` and registered via `gtest_discover_tests`.
- **Chapter_13**: forces `-O3 -DNDEBUG -march=native` unconditionally (ignores `CMAKE_BUILD_TYPE`) and links every target against `benchmark::benchmark` instead of Boost.
- **Chapter_10**: only chapter requiring `Boost::cobalt`; re-declares C++20 locally.
- **Chapter_05**: links `atomic` explicitly, but only under GCC (`CMAKE_CXX_COMPILER_ID STREQUAL "GNU"`) — Clang/macOS has no separate library for this (handled by compiler-rt).
- **Chapter_11**: links `fmt::fmt`/`spdlog::spdlog` in addition to Boost.
- Adding a new chapter: create `SourceCode/Chapter_NN/`, add a `CMakeLists.txt` following the existing GLOB-per-cpp pattern, and add `add_subdirectory(Chapter_NN)` to `SourceCode/CMakeLists.txt`.

## Portability shims (`SourceCode/compat/`)

Apple's libc++ (and, as of this writing, upstream LLVM's libc++ too) is missing some C++20/23 standard library pieces this book uses. Each call site picks between the real header and the shim via a preprocessor conditional, not a silent unconditional include — e.g.:

```cpp
#if defined(__cpp_lib_syncbuf)
#include <syncstream>
#else
#include "osyncstream_compat.h"  // Apple's libc++ ships <syncstream> without implementing std::osyncstream.
#endif
```

- `osyncstream_compat.h`: `std::osyncstream` fallback, gated on `__cpp_lib_syncbuf`.
- `generator_compat.h`: minimal single-pass `std::generator<T>` fallback (coroutine-based), gated on `__has_include(<generator>)`.
- `affinity_compat.h`: cross-platform `set_affinity(int core)` for Chapter_13's benchmarks — `pthread_setaffinity_np`/`cpu_set_t` on Linux, `thread_policy_set` (a scheduler hint, not a hard pin) on macOS via `__APPLE__`, no-op elsewhere. This one branches on OS, not a library feature test, since CPU affinity is an OS API difference, not a standard-library gap.

`SourceCode/CMakeLists.txt` adds `SourceCode/compat/` to the include path project-wide.

## Code style

- `.clang-format`: plain `LLVM` style (2-space indent).
- `.cmake-format`: `tab_size: 4`, `line_width: 80` for `CMakeLists.txt` files.
- `.clang-tidy`: a starting checks list (bugprone/cert/clang-analyzer/concurrency/cppcoreguidelines/modernize/performance/portability/readability) — not yet enforced in CI, still being reviewed/tuned.
- `.pre-commit-config.yaml` runs clang-format, cmake-format, shellcheck, yamllint, gitleaks, and generic hygiene hooks (private-key detection, merge-conflict markers, end-of-file/trailing-whitespace fixers).

## CI

`.github/workflows/tests.yml` builds `build_all` and runs `ctest` on `ubuntu-latest` across a `{gcc, clang}` matrix — no dependency installation step, CMake's `FetchContent` handles everything. `.github/workflows/quality.yml` runs the clang-format/cmake-format checks from `.pre-commit-config.yaml` in CI.

## Editor/debug config

`.vscode/tasks.json` and `launch.json` build/debug the *currently open file only* via a raw `g++` invocation (not through CMake) — paths in there are Linux-specific (`/usr/bin/g++`, `/usr/include/boost/`, `gdb`) and won't work as-is on macOS, and don't account for the Boost include paths FetchContent uses (`build/_deps/boost-src/libs/*/include`). `.vscode/extensions.json` recommends `clangd` over `ms-vscode.cpptools` (actively discouraged via `unwantedRecommendations`) — clangd reads `compile_commands.json` (now generated via `StandardProjectSettings.cmake`) and respects `.clang-format`/`.clang-tidy` directly, so it doesn't need `c_cpp_properties.json` at all.
