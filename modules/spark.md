# Adventure: High-Integrity Systems (SPARK & Rust)

When "memory safety" isn't enough, and you need "mathematical proof" that your code is correct. This is the realm of safety-critical systems (aerospace, medical, automotive).

## Level 1: The Modern Baseline (Low Effort) — Rust
**The Friction:** C and C++ are memory-unsafe by default. Managing pointers is a manual, error-prone nightmare.
**The Fix:** Switch to **[Rust](https://www.rust-lang.org/)**.
- **Impact:** The borrow checker enforces memory safety at compile-time. You eliminate a whole class of bugs (buffer overflows, use-after-free) without a garbage collector.

## Level 2: The Formal Proof (Medium Effort) — SPARK Ada
**The Friction:** Even safe code can have logic errors (integer overflows, out-of-bounds indexing, deadlocks). You need 100% certainty.
**The Fix:** Use **[SPARK Ada](https://www.adacore.com/about-spark)**.
- **How:** Install via **[Alire](https://alire.ada.dev/)** (`alr install spark_lemon`).
- **Impact:** A subset of Ada that allows you to formally *prove* the absence of runtime errors. It's not just "safe"; it's mathematically verified.

## Level 3: The Industrial Standard (High Effort) — Ferrocene
**The Friction:** You need to certify your Rust code for ISO 26262 (Automotive) or DO-178C (Aerospace).
**The Fix:** Use **[Ferrocene](https://ferrous-systems.com/ferrocene/)**.
- **Impact:** A safety-qualified Rust toolchain. It provides the legal and technical "assurance" needed for regulated industries.

## Level 4: The High-Integrity Hybrid (Diplomat) — The SPARK Core
**The Friction:** SPARK is great for logic but has a smaller ecosystem for modern tasks. You want the library support of Python, Go, or Java without losing formal proof of your core logic.
**The Strategy:** Build a **SPARK Core** as a shared library.
- **The Workflow:**
    1.  **Logic:** Write the safety-critical "brain" in **SPARK**.
    2.  **Export:** Use `pragma Export (C, ...)` to create a C-compatible interface.
    3.  **Bridge:** 
        - **Rust:** Use `bindgen` or `cxx`.
        - **C / C++:** Call directly as a C function.
        - **Java:** Use **GNAT-AJIS** or JNI.
        - **Python:** Use `ctypes` or `GNATPython`.
        - **Go:** Use `cgo`.
- **Impact:** You get mathematical proof that your "brain" is correct, while your "shell" (UI, API, etc.) can be written in whatever language is fastest for the job.
