CC ?= gcc
CFLAGS ?= -Wall -Wextra -O0
SRC_DIR = src
SRC = $(SRC_DIR)/main.c

# Multi-file sources
MULTI_SRCS = $(SRC_DIR)/demo_multi.c $(SRC_DIR)/math_utils.c
MULTI_OBJS = demo_multi.o math_utils.o

# Default target
all: main

# ==============================================================================
# Single-File Pipeline Stages (PDF Guide Walkthrough)
# ==============================================================================

# Step 1: Preprocessing (-E)
preprocess: main.i
main.i: $(SRC)
	$(CC) -E $(SRC) -o $@

# Step 2: Compilation (-S)
compile: main.s
main.s: main.i
	$(CC) -S main.i -o $@

# Step 3: Assembly (-c)
assemble: main.o
main.o: main.s
	$(CC) -c main.s -o $@

# Step 4: Linking
link: main
main: main.o
	$(CC) main.o -o $@

# ==============================================================================
# Multi-Object Compilation & Linking Demo
# ==============================================================================
multi: $(MULTI_OBJS)
	$(CC) $(MULTI_OBJS) -o main_multi

math_utils.o: $(SRC_DIR)/math_utils.c $(SRC_DIR)/math_utils.h
	$(CC) $(CFLAGS) -c $(SRC_DIR)/math_utils.c -o $@

demo_multi.o: $(SRC_DIR)/demo_multi.c $(SRC_DIR)/math_utils.h
	$(CC) $(CFLAGS) -c $(SRC_DIR)/demo_multi.c -o $@

# ==============================================================================
# Inspection & Diagnostics
# ==============================================================================
disasm: main.o
	@echo "--- Disassembly (AT&T syntax) ---"
	objdump -d main.o

disasm-intel: main.o
	@echo "--- Disassembly (Intel syntax) ---"
	objdump -d -M intel main.o

inspect-elf: main
	@bash scripts/inspect_elf.sh main

run: main
	@echo "Executing single-file binary:"
	@./main

run-multi: multi
	@echo "Executing multi-module binary:"
	@./main_multi

clean:
	rm -f main.i main.s main.o main
	rm -f $(MULTI_OBJS) main_multi

.PHONY: all preprocess compile assemble link multi disasm disasm-intel inspect-elf run run-multi clean
