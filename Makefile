CC ?= gcc
CFLAGS ?= -Wall -Wextra -Wpedantic -O0
SRC_DIR = src
SRC = $(SRC_DIR)/main.c

MULTI_SRCS = $(SRC_DIR)/demo_multi.c $(SRC_DIR)/math_utils.c
MULTI_OBJS = demo_multi.o math_utils.o

all: main

# Step 1: Preprocessing (-E)
preprocess: main.i
main.i: $(SRC)
	$(CC) -E $(SRC) -o $@

# Step 2: Compilation (-S)
compile: main.s
main.s: main.i
	$(CC) -S main.i -o $@

# Intel Syntax Compilation
compile-intel: main_intel.s
main_intel.s: $(SRC)
	$(CC) -S -masm=intel $(SRC) -o $@

# Step 3: Assembly (-c)
assemble: main.o
main.o: main.s
	$(CC) -c main.s -o $@

# Step 4: Linking
link: main
main: main.o
	$(CC) main.o -o $@

# Static Linking Target
static: main_static
main_static: main.o
	$(CC) -static main.o -o $@

# Multi-Object Linking Demo
multi: $(MULTI_OBJS)
	$(CC) $(MULTI_OBJS) -o main_multi

math_utils.o: $(SRC_DIR)/math_utils.c $(SRC_DIR)/math_utils.h
	$(CC) $(CFLAGS) -c $(SRC_DIR)/math_utils.c -o $@

demo_multi.o: $(SRC_DIR)/demo_multi.c $(SRC_DIR)/math_utils.h
	$(CC) $(CFLAGS) -c $(SRC_DIR)/demo_multi.c -o $@

# Inspection targets
disasm: main.o
	objdump -d main.o

disasm-intel: main.o
	objdump -d -M intel main.o

inspect-elf: main
	@bash scripts/inspect_elf.sh main

inspect-symbols: main.o
	@bash scripts/inspect_symbols.sh main.o

check-syntax:
	$(CC) $(CFLAGS) -fsyntax-only $(SRC_DIR)/*.c

run: main
	@./main

clean:
	rm -f main.i main.s main_intel.s main.o main main_static
	rm -f $(MULTI_OBJS) main_multi

.PHONY: all preprocess compile compile-intel assemble link static multi disasm disasm-intel inspect-elf inspect-symbols check-syntax run clean
