#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# SPDX-FileCopyrightText: 2024-2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# cyo.sh — Choose Your Own. A terminal reader for the route chapters.
set -euo pipefail

MODULES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/modules"

RED=$'\033[0;31m'; BOLD=$'\033[1m'; NC=$'\033[0m'

show_usage() {
    printf '%sUsage:%s ./cyo.sh <route>\n' "$BOLD" "$NC"
    printf '%sRoutes:%s\n' "$BOLD" "$NC"
    for f in "$MODULES_DIR"/*.adoc; do
        printf '  - %s\n' "$(basename "$f" .adoc)"
    done
}

if [ $# -eq 0 ] || [ -z "${1:-}" ]; then
    show_usage
    exit 1
fi

ROUTE_FILE="$MODULES_DIR/$1.adoc"

if [ ! -f "$ROUTE_FILE" ]; then
    printf '%sNo such route:%s %s\n\n' "$RED" "$NC" "$1"
    show_usage
    exit 1
fi

# Prefer a real AsciiDoc renderer; degrade gracefully.
if command -v asciidoctor >/dev/null 2>&1 && command -v less >/dev/null 2>&1; then
    asciidoctor -b manpage -o - "$ROUTE_FILE" 2>/dev/null | man -l - 2>/dev/null && exit 0
fi
if command -v bat >/dev/null 2>&1; then
    bat --style=plain --language=asciidoc "$ROUTE_FILE"
elif command -v batcat >/dev/null 2>&1; then
    batcat --style=plain --language=asciidoc "$ROUTE_FILE"
else
    cat "$ROUTE_FILE"
fi
