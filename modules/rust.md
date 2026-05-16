# Adventure: Rust Ecosystem

Even Rust has "friction." Large builds can be slow, testing can be fragmented, and installing tools can clutter your path.

## Level 1: The Quality of Life (Low Effort) — `binstall` & `nextest`
**The Friction:** `cargo install` compiles everything from source (slow!), and `cargo test` output can be hard to read in large projects.
**The Fix:** Use **[cargo-binstall](https://github.com/cargo-bins/cargo-binstall)** and **[cargo-nextest](https://nexte.st/)**.
- **Impact:** `binstall` downloads pre-compiled binaries instantly. `nextest` is a much faster, beautiful test runner.

## Level 2: The Speed Demon (Medium Effort) — `mold` / `sold`
**The Friction:** The default linker is the bottleneck of Rust compile times. You're waiting 10 seconds for a 1-line change.
**The Fix:** Use **[mold](https://github.com/rui314/mold)** (Linux) or **sold** (macOS).
- **How:** Add `[target.x86_64-unknown-linux-gnu] linker = "clang"; rustflags = ["-C", "link-arg=-fuse-ld=mold"]` to your `.cargo/config.toml`.
- **Impact:** Linking becomes nearly instantaneous. Your "edit-compile-run" loop feels like a dynamic language.

## Level 3: The Project Orchestrator (High Effort) — `mise`
**The Friction:** Managing different Rust toolchains and global dependencies per project is a manual chore.
**The Fix:** Use **[mise](https://mise.jdx.dev/)**.
- **Impact:** Automatic tool switching. As soon as you `cd` into a repo, `mise` ensures you have the right version of `rustc`, `node`, and `python` ready to go.

## Level 4: The Diplomat (Future-Proof) — `cxx`
**The Friction:** Calling C++ from Rust is "unsafe" and full of memory-safety traps.
**The Fix:** Use **[cxx](https://cxx.rs/)**.
- **Impact:** It provides safe interop between Rust and C++. It generates the "glue" code that ensures memory safety across the language boundary.
