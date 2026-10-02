#!/usr/bin/env bash
# ==============================================================================
# inspect_elf.sh - Deep inspection tool for ELF binaries and relocatable objects
# ==============================================================================

set -euo pipefail

TARGET="${1:-main}"

if [ ! -f "$TARGET" ]; then
    echo "Error: Target '$TARGET' does not exist. Run 'make' first to compile." >&2
    exit 1
fi

echo "=========================================================="
echo "          1. ELF Header: Entry Point & Machine Type       "
echo "=========================================================="
readelf -h "$TARGET" | head -n 14

echo -e "\n=========================================================="
echo "          2. Program Headers (Segments for OS Loader)     "
echo "=========================================================="
readelf -l "$TARGET" | grep -A 2 -E "INTERP|LOAD"

echo -e "\n=========================================================="
echo "          3. Section Headers (.text, .rodata, .bss)       "
echo "=========================================================="
readelf -S "$TARGET" | head -n 25

echo -e "\n=========================================================="
echo "          4. Relocation Entries (if object file exists)   "
echo "=========================================================="
if [ -f "main.o" ]; then
    readelf -r main.o
else
    echo "main.o not found. Run 'make assemble' to generate."
fi

echo -e "\n=========================================================="
echo "          5. Dynamic Library Dependencies (ldd)           "
echo "=========================================================="
ldd "$TARGET" 2>/dev/null || echo "Static binary or not supported in current environment."
