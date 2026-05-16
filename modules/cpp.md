# Adventure: C / C++ / C# (The System Guard)

The "Old Guard" of languages (C, C++, C#) is the default choice for 90% of software, but they carry massive "Legacy Friction": complex build systems, memory unsafe defaults, or heavy runtime dependencies.

## Level 1: The Quality of Life (Low Effort) — `delta` & `clangd`
**The Friction:** Reading diffs and getting IDE support for legacy code is painful.
**The Fix:** Use **[delta](https://github.com/dandavison/delta)** for diffs and **[clangd](https://clangd.llvm.org/)** for LSP.

## Level 2: The "Best C Compiler" (Medium Effort) — `Zig cc`
**The Friction:** You're stuck in a C/C++ project and cross-compiling is a nightmare.
**The Fix:** Use **[Zig](https://ziglang.org/)** just as your compiler.
- **Action:** Replace `gcc` or `clang` with `zig cc`.
- **Impact:** You get zero-config cross-compilation for any OS/Architecture. This is the "Trojan Horse" to get Zig into your workflow without rewriting a single line of code.

## Level 3: The Build System Rethink — `build.zig`
**The Friction:** `CMake` and `MSBuild` are complex, slow, and hard to maintain.
**The Fix:** Use **Zig** as your build system for C/C++ projects.
- **Impact:** You write your build logic in a real programming language (Zig) instead of a clunky DSL. It's faster and more reliable than CMake.

## Level 4: The Paradigm Shift (High Effort) — Pure Zig
**The Friction:** You're starting a new project and "defaulting" to C++ or C# out of habit.
**The Fix:** Use **[Zig](https://ziglang.org/)**.
- **Why?**
    - **vs C:** Zig is "C but better." No hidden control flow, no preprocessor mess, and built-in safety.
    - **vs C++:** No complex templates or "spooky action at a distance." Just data and functions.
    - **vs C#:** No Garbage Collector, no VM, no 100MB runtime. You get a single, tiny binary that runs anywhere.
- **Impact:** You stop fighting your tools and start writing high-performance, maintainable code.
