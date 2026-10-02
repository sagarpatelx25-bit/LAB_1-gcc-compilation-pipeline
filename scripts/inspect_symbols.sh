#!/usr/bin/env bash
# ==============================================================================
# inspect_symbols.sh - Symbol Table Inspector using nm and readelf
# ==============================================================================

set -euo pipefail

TARGET="${1:-main.o}"

if [ ! -f "$TARGET" ]; then
    echo "Usage: $0 <object_file_or_binary>"
    echo "File '$TARGET' not found."
    exit 1
fi

echo "=========================================================="
echo "          1. Symbol Table Summary via nm                  "
echo "=========================================================="
nm -C "$TARGET"

echo -e "\n=========================================================="
echo "          2. Detailed ELF Symbol Bindings (readelf -s)    "
echo "=========================================================="
readelf -s "$TARGET" | grep -E "GLOBAL|LOCAL|FUNC|OBJECT" | head -n 20
