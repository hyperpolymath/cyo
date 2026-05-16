# Adventure: Git & Workflow

Git is the industry standard, but its CLI is notoriously complex, and many daily workflows (rebasing, conflict resolution, cherry-picking) are high-friction.

## Level 1: The Visual Clarity (Low Effort) — `delta` & `gh`
**The Friction:** Plain `git diff` is hard to parse, and context-switching to a browser for GitHub PRs is annoying.
**The Fix:** Use **[delta](https://github.com/dandavison/delta)** and **[gh](https://cli.github.com/)** (GitHub CLI).
- **Impact:** `delta` gives you syntax-highlighted diffs in your terminal. `gh` lets you manage PRs, issues, and releases without leaving your keyboard.

## Level 2: The Interactive Hub (Medium Effort) — `lazygit`
**The Friction:** Staging individual lines or chunks via the command line (`git add -p`) is tedious.
**The Fix:** Use **[lazygit](https://github.com/jesseduffield/lazygit)**.
- **Impact:** A fast, terminal UI for git. It makes staging, committing, and rebasing a visual, one-key experience.

## Level 3: The Version Control Rethink (High Effort) — `jj` (Jujutsu)
**The Friction:** Git's index and branch model can be confusing. Undoing mistakes is often a series of complex `git reset` commands.
**The Fix:** Use **[Jujutsu (jj)](https://github.com/martinvonz/jj)**.
- **Impact:** A Git-compatible VCS that is much more intuitive. It has built-in conflict resolution that stays in the file (no more merge conflict markers!) and every command is easily undoable.
