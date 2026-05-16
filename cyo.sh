#!/bin/bash

# cyo.sh - Choose Your Own Adventure (Modern Tooling)
# A simple terminal-first guide explorer.

MODULES_DIR="./modules"
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

function show_usage() {
    echo -e "${BOLD}Usage:${NC} ./cyo.sh <language>"
    echo -e "${BOLD}Available Adventures:${NC}"
    ls $MODULES_DIR | sed 's/\.md//' | awk '{print "  - " $1}'
}

if [ -z "$1" ]; then
    show_usage
    exit 1
fi

LANG_FILE="$MODULES_DIR/$1.md"

if [ ! -f "$LANG_FILE" ]; then
    echo -e "${RED}Error:${NC} Adventure for '$1' not found."
    show_usage
    exit 1
fi

# If 'bat' is installed, use it for beautiful rendering
if command -v bat &> /dev/null; then
    bat --style=plain --language=markdown "$LANG_FILE"
elif command -v batcat &> /dev/null; then
    batcat --style=plain --language=markdown "$LANG_FILE"
else
    # Fallback to plain cat with some basic bolding for headers
    cat "$LANG_FILE"
fi
