CC ?= gcc
CFLAGS ?= -Wall -Wextra -O0
SRC_DIR = src
SRC = $(SRC_DIR)/main.c

# Final target
all: main

# Step 1: Preprocessing (-E)
# Expands #include, evaluates #define macros, strips comments, inserts linemarkers
preprocess: main.i

main.i: $(SRC)
	$(CC) -E $(SRC) -o $@

# Step 2: Compilation to Assembly (-S)
# Translates preprocessed C tokens into x86-64 assembly in AT&T syntax
compile: main.s

main.s: main.i
	$(CC) -S main.i -o $@

# Step 3: Assembler to Relocatable Object (-c)
# Converts assembly mnemonics into ELF64 machine code object file
assemble: main.o

main.o: main.s
	$(CC) -c main.s -o $@

# Step 4: Linking into Final Executable
# Resolves external symbols (printf via libc.so.6) and binds dynamic interpreter
link: main

main: main.o
	$(CC) main.o -o $@

# Inspection targets
disasm: main.o
	@echo "--- Disassembly (AT&T syntax) ---"
	objdump -d main.o

disasm-intel: main.o
	@echo "--- Disassembly (Intel syntax) ---"
	objdump -d -M intel main.o

inspect-elf: main
	@echo "=== ELF Header ==="
	readelf -h main | head -n 15
	@echo "\n=== Program Interpreter ==="
	readelf -l main | grep -E "interpreter|INTERP"

run: main
	@echo "Executing ./main:"
	@./main

clean:
	rm -f main.i main.s main.o main

.PHONY: all preprocess compile assemble link disasm disasm-intel inspect-elf run clean
