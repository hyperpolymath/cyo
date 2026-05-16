<!--
SPDX-License-Identifier: MPL-2.0
SPDX-FileCopyrightText: 2024-2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
-->

# Security Policy

`cyo` is documentation plus two small POSIX shell scripts (`cyo.sh`,
`welcome.sh`). The realistic attack surface is the scripts and any commands a
chapter instructs a reader to run.

## Reporting

Report suspected vulnerabilities privately to **j.d.a.jewell@open.ac.uk**, or via
GitHub's private vulnerability reporting on this repository. Please do not open a
public issue for a security report.

You can expect an acknowledgement within a few days and an honest assessment of
scope and fix timeline.

## Scope

In scope:

- Command injection or unsafe argument handling in `cyo.sh` / `welcome.sh`.
- A chapter recommending a command that is unsafe as written.

Out of scope:

- Vulnerabilities in the third-party tools the chapters describe — report those
  upstream. `cyo` only points at them.

## Supported versions

`cyo` is rolling; only the current `main` is supported.
