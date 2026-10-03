# Wires together the modules in this directory, except StaticAnalyzers: include
# that separately, after fetching third-party dependencies, so an opt-in
# -DENABLE_CLANG_TIDY=ON etc. only lints this project's own code, not the
# fetched Boost/GoogleTest/fmt/spdlog/benchmark sources.
include_guard(GLOBAL)

include(Logger)
include(PreventInSourceBuilds)
include(StandardProjectSettings)
include(CCache)
include(CompilerWarnings)
