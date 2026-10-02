#!/usr/bin/env bash
# ==============================================================================
# GCC Compilation Pipeline: Live Walkthrough Script
# Demonstrates Preprocessing -> Compilation -> Assembly -> Linking -> Execution
# ==============================================================================

set -euo pipefail

# ANSI Color Codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists gcc; then
    echo -e "${YELLOW}Error: gcc compiler not found in PATH.${NC}" >&2
    exit 1
fi

echo -e "\n${BOLD}${CYAN}======================================================================${NC}"
echo -e "${BOLD}${CYAN}            GCC 4-Stage Compilation Pipeline Walkthrough              ${NC}"
echo -e "${BOLD}${CYAN}======================================================================${NC}\n"

# Step 1: Source code
echo -e "${BOLD}${BLUE}[Step 1] Original C Program:${NC}"
echo -e "${YELLOW}$ cat src/main.c${NC}"
cat src/main.c
echo -e "\n"

# Step 2: Preprocessing
echo -e "${BOLD}${BLUE}[Step 2] Preprocessing (gcc -E):${NC}"
echo -e "${YELLOW}$ gcc -E src/main.c -o main.i${NC}"
gcc -E src/main.c -o main.i
echo -e "${YELLOW}$ head -n 25 main.i${NC}"
head -n 25 main.i
echo -e "${GREEN}... [Standard library headers expanded, macros resolved] ...${NC}\n"

# Step 3: Compilation
echo -e "${BOLD}${BLUE}[Step 3] Compilation (gcc -S):${NC}"
echo -e "${YELLOW}$ gcc -S main.i -o main.s${NC}"
gcc -S main.i -o main.s
echo -e "${YELLOW}$ cat main.s${NC}"
cat main.s
echo -e "${GREEN}... [C parsed into x86-64 assembly in AT&T syntax] ...${NC}\n"

# Step 4: Assembly
echo -e "${BOLD}${BLUE}[Step 4] Assembly (gcc -c):${NC}"
echo -e "${YELLOW}$ gcc -c main.s -o main.o${NC}"
gcc -c main.s -o main.o
echo -e "${YELLOW}$ objdump -d main.o${NC}"
objdump -d main.o
echo -e "${GREEN}... [Assembly translated into ELF relocatable machine opcodes] ...${NC}\n"

# Step 5: Linking
echo -e "${BOLD}${BLUE}[Step 5] Linking (gcc main.o -o main):${NC}"
echo -e "${YELLOW}$ gcc main.o -o main${NC}"
gcc main.o -o main
echo -e "${YELLOW}$ file main${NC}"
file main
echo -e "${GREEN}... [External symbols resolved, dynamic interpreter attached] ...${NC}\n"

# Step 6: Execution
echo -e "${BOLD}${BLUE}[Step 6] Execution (./main):${NC}"
echo -e "${YELLOW}$ ./main${NC}"
./main
echo -e "\n${BOLD}${GREEN}✔ All compilation pipeline stages completed successfully.${NC}\n"
