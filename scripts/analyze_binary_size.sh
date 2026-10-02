#!/usr/bin/env bash
# ==============================================================================
# analyze_binary_size.sh - Analyzes ELF memory section sizes using 'size' utility
# ==============================================================================

set -euo pipefail

TARGET="${1:-main}"

if [ ! -f "$TARGET" ]; then
    echo "Usage: $0 <binary_or_object_file>"
    exit 1
fi

echo "=========================================================="
echo "          1. Section Size Summary (size utility)          "
echo "=========================================================="
size "$TARGET"

echo -e "\n=========================================================="
echo "          2. Detailed Berkeley vs System V Output         "
echo "=========================================================="
size -A "$TARGET" | grep -E "(\.text|\.rodata|\.data|\.bss|\.got|\.plt)"
