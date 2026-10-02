# GCC Compilation Pipeline: Step-by-Step Engineering Guide

[![Standard](https://img.shields.io/badge/C-C99%20%7C%20C11%20%7C%20C17-blue.svg)]()
[![Architecture](https://img.shields.io/badge/architecture-x86--64-orange.svg)]()
[![Binary Format](https://img.shields.io/badge/format-ELF64%20(SYSV)-red.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A rigorous, production-grade systems reference dissecting the **four fundamental phases of GCC compilation**: **Preprocessing**, **Compilation**, **Assembly**, and **Linking**, concluding with OS runtime binary execution.

---

## 🏗️ Architecture Overview

```
                      [src/main.c]
                           │
                           │  Step 1: Preprocessor (gcc -E / cpp)
                           ▼
                      [main.i]
              (Header expansion, macro substitution, linemarkers)
                           │
                           │  Step 2: Compiler (gcc -S / cc1)
                           ▼
                      [main.s]
              (x86-64 AT&T Assembly, stack frame allocation, System V ABI)
                           │
                           │  Step 3: Assembler (gcc -c / as)
                           ▼
                      [main.o]
              (Relocatable ELF64 machine opcodes with relocation tables)
                           │
                           │  Step 4: Linker (gcc / ld)
                           ▼
                      [main]
              (Fully resolved ELF64 dynamic executable with PLT/GOT)
                           │
                           │  Step 5 & 6: OS Kernel Loader (execve -> ld.so)
                           ▼
                   [Output: "Hello World!"]
```

---

## 📋 Quick Command Cheat Sheet

| Phase | Input | Output | Primary GCC Command | Inspection Utility |
|---|---|---|---|---|
| **1. Source** | — | `main.c` | `cat src/main.c` | Editor / `cat` |
| **2. Preprocessing** | `main.c` | `main.i` | `gcc -E src/main.c -o main.i` | `head -n 30 main.i` |
| **3. Compilation** | `main.i` | `main.s` | `gcc -S main.i -o main.s` | `cat main.s` |
| **4. Assembly** | `main.s` | `main.o` | `gcc -c main.s -o main.o` | `objdump -d main.o` |
| **5. Linking** | `main.o` | `main` | `gcc main.o -o main` | `file main` / `readelf -h main` |
| **6. Execution** | `main` | `stdout` | `./main` | `strace ./main` |

---

## 🔬 Practical Phase-by-Phase Walkthrough

### Step 1: Original C Source Code
* **Objective**: View the original source code.
* **Command**: `cat main.c`

```c
#include <stdio.h>

#define GREETING_MSG "Hello World!\n"

int main(void) {
    printf(GREETING_MSG);
    return 0;
}
```

#### Terminal Execution Screenshot:
![Step 1 - View Source Code](docs/assets/screenshots/01_step1_source_cat.png)

* **Observation**: Displays the initial C source code written by the programmer containing preprocessor directives (`#include`, `#define`) and standard library function calls.

---

### Step 2: Preprocessing
* **Objective**: Process directives like `#include` and macros to generate the preprocessed source code (`.i`).
* **Command**: `gcc -E src/main.c -o main.i then head -30 main.i`

```bash
gcc -E src/main.c -o main.i
head -n 30 main.i
```

#### Terminal Execution Screenshot:
![Step 2 - Preprocessing Output](docs/assets/screenshots/02_step2_preprocessing_gcc_E.png)

* **Observation**: The code expands to include standard library declarations (`stdio.h`, `features.h`, `sys/cdefs.h`), removing comments and resolving macros. Linemarkers (`# linenum filename flags`) preserve original file mapping.

---

### Step 3: Compilation (C to Assembly)
* **Objective**: Convert the preprocessed C code into assembly language (`.s`).
* **Command**: `gcc -S main.i -o main.s then head -30 main.s`

```bash
gcc -S main.i -o main.s
cat main.s
```

#### Terminal Execution Screenshot:
![Step 3 - Assembly Generation](docs/assets/screenshots/03_step3_compilation_gcc_S.png)

* **Observation**: The compiler translates the C syntax into low-level CPU-specific assembly instructions in AT&T syntax. It allocates stack frames, adheres to the **System V AMD64 ABI** (`%rdi` for first argument, `%rax` for return values), and inserts Intel CET (`endbr64`) instructions.

---

### Step 4: Assembly (Assembly to Relocatable Object)
* **Objective**: Convert the assembly instructions into machine-readable object code (`.o`) and inspect it.
* **Command**: `gcc -c main.s -o main.o then objdump -d main.o`

```bash
gcc -c main.s -o main.o
objdump -d main.o
```

#### Terminal Execution Screenshot:
![Step 4 - Disassembly with objdump](docs/assets/screenshots/04_step4_assembly_objdump.png)

* **Observation**: The assembler creates binary machine code. The `objdump` tool allows us to view the raw hex format (`f3 0f 1e fa`, `55`, `48 89 e5`) alongside assembly. The placeholder zero bytes (`00 00 00 00` at offsets `0x8` and `0x17`) represent unresolved relocations (`R_X86_64_PC32` and `R_X86_64_PLT32`) for the linker.

---

### Step 5: Linking (Object Code to Dynamic Executable)
* **Objective**: Combine the object file with required libraries to create the final executable binary.
* **Command**: `gcc main.o -o main then file main`

```bash
gcc main.o -o main
file main
```

#### Terminal Execution Screenshot:
![Step 5 - Binary Linking and File Identification](docs/assets/screenshots/05_step5_linking_file_info.png)

* **Observation**: The linker resolves external function calls (like `printf` in `libc.so.6`), injects runtime entry code (`_start`), and creates the final ready-to-run ELF 64-bit dynamically linked executable with dynamic interpreter `/lib64/ld-linux-x86-64.so.2`.

---

### Step 6: Execution
* **Objective**: Run the final executable program.
* **Command**: `./main`

```bash
./main
```

#### Terminal Execution Screenshot:
![Step 6 - Program Execution Output](docs/assets/screenshots/06_step6_execution_output.png)

* **Observation**: The OS kernel loads the compiled binary via `execve()`, maps shared library dependencies, transfers execution to `_start` $\rightarrow$ `main()`, producing the expected output `Hello World!`.

---

## 🛠️ Build & Inspection Instructions

### Using GNU Make
```bash
make all           # Build complete executable
make preprocess    # Run Stage 1 (generates main.i)
make compile       # Run Stage 2 (generates main.s)
make assemble      # Run Stage 3 (generates main.o)
make link          # Run Stage 4 (generates main)
make disasm        # Disassemble object file in AT&T syntax
make disasm-intel  # Disassemble object file in Intel syntax
make inspect-elf   # Inspect ELF headers and interpreter
make run           # Run the compiled program
make clean         # Remove all intermediate and final binaries
```

### Multi-File Linking Demonstration
```bash
make multi         # Compiles demo_multi.c + math_utils.c and links them
make run-multi     # Executes the multi-module binary
```

### Automated Live Walkthrough
```bash
chmod +x scripts/run_pipeline.sh
./scripts/run_pipeline.sh
```

---

## 📚 Technical Documentation Directory
- [Stage 1: Preprocessor Mechanics](docs/01_preprocessing.md)
- [Stage 2: Assembly & ABI Calling Conventions](docs/02_compilation.md)
- [Stage 3: ELF Relocations & Machine Opcodes](docs/03_assembly.md)
- [Stage 4: Linking, PLT/GOT, and OS Binary Loading](docs/04_linking_and_execution.md)
- [Architecture Deep Dive: GCC Internals & Virtual Memory](docs/GCC_INTERNALS_GUIDE.md)

---

## 📄 License
Released under the [MIT License](LICENSE).
