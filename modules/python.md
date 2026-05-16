# Adventure: Python

Python is infamous for its "dependency hell," clunky virtual environments, and slow package resolution. PEP 668 made it even more frustrating for many.

## Level 1: The Safety Rail (Low Effort) — `pipx`
**The Friction:** Installing Python apps globally breaks your system's "engine" (PEP 668).
**The Fix:** Use **[pipx](https://github.com/pypa/pipx)**.
- **How:** `sudo apt install pipx && pipx ensurepath`.
- **Impact:** Automatically creates isolated virtual environments for every app you install. No more system conflicts.

## Level 2: The Modern Monolith (Medium Effort) — `uv`
**The Friction:** `pip` is slow, and managing `.venv` folders manually is a chore.
**The Fix:** Use **[uv](https://github.com/astral-sh/uv)**.
- **How:** `curl -LsSf https://astral.sh/uv/install.sh | sh`.
- **Impact:** A Rust-powered powerhouse. 10-100x faster than pip. Replaces pip, pipx, and venv in one binary.

## Level 3: The Full Manager (High Effort) — `rye` / `mise`
**The Friction:** You have to manage Python versions (`pyenv`), package versions, and global settings separately.
**The Fix:** Use **[mise](https://mise.jdx.dev/)** or **[rye](https://rye-up.com/)**.
- **Impact:** Unified environment management. Switch project versions automatically just by `cd`-ing into a directory.
