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

#### Terminal Execution Screenshot:
![Step 1 - View Source Code](docs/assets/screenshots/01_step1_source_cat.png)

* **Observation**: Displays the initial C source code written by the programmer containing preprocessor directives (`#include`, `#define`) and standard library function calls.

---

### Step 2: Preprocessing
* **Objective**: Process directives like `#include` and macros to generate the preprocessed source code (`.i`).
* **Command**: `gcc -E main.c -o main.i then head -30 main.i`

#### Terminal Execution Screenshot:
![Step 2 - Preprocessing Output](docs/assets/screenshots/02_step2_preprocessing_gcc_E.png)

* **Observation**: The code expands to include standard library declarations, removing comments and resolving macros. Linemarkers preserve original file line locations.

---

### Step 3: Compilation (C to Assembly)
* **Objective**: Convert the preprocessed C code into assembly language (`.s`).
* **Command**: `gcc -S main.i -o main.s then head -30 main.s`

#### Terminal Execution Screenshot:
![Step 3 - Assembly Generation](docs/assets/screenshots/03_step3_compilation_gcc_S.png)

* **Observation**: The compiler translates the C syntax into low-level CPU-specific assembly instructions in AT&T syntax, setting up stack frames and adhering to the System V AMD64 ABI.

---

### Step 4: Assembly (Assembly to Relocatable Object)
* **Objective**: Convert the assembly instructions into machine-readable object code (`.o`) and inspect it.
* **Command**: `gcc -c main.s -o main.o then objdump -d main.o`

#### Terminal Execution Screenshot:
![Step 4 - Disassembly with objdump](docs/assets/screenshots/04_step4_assembly_objdump.png)

* **Observation**: The assembler creates binary machine code. The `objdump` tool allows us to view the raw hex format alongside assembly instructions and relocation placeholders.

---

### Step 5: Linking (Object Code to Dynamic Executable)
* **Objective**: Combine the object file with required libraries to create the final executable binary.
* **Command**: `gcc main.o -o main then file main`

#### Terminal Execution Screenshot:
![Step 5 - Binary Linking and File Identification](docs/assets/screenshots/05_step5_linking_file_info.png)

* **Observation**: The linker resolves external function calls (like `printf`), binds the dynamic interpreter `/lib64/ld-linux-x86-64.so.2`, and produces the final ready-to-run executable binary.

---

### Step 6: Execution
* **Objective**: Run the final executable program.
* **Command**: `./main`

#### Terminal Execution Screenshot:
![Step 6 - Program Execution Output](docs/assets/screenshots/06_step6_execution_output.png)

* **Observation**: The OS kernel loads the compiled binary via `execve()`, maps shared libraries, and produces the expected output: `Hello World!`.

---

## 🛠️ Advanced Build & Inspection Targets

```bash
make all              # Build dynamic executable
make static           # Build standalone static binary (-static)
make compile-intel    # Generate Intel syntax assembly (-masm=intel)
make disasm           # Disassemble object file in AT&T syntax
make disasm-intel     # Disassemble object file in Intel syntax
make inspect-elf      # Inspect ELF headers and interpreter
make inspect-symbols  # Inspect symbol tables via nm and readelf
make clean            # Remove all build artifacts
```

---

## 📚 Technical Documentation Directory
- [Stage 1: Preprocessor Mechanics](docs/01_preprocessing.md)
- [Stage 2: Assembly & ABI Calling Conventions](docs/02_compilation.md)
- [Stage 3: ELF Relocations & Machine Opcodes](docs/03_assembly.md)
- [Stage 4: Linking, PLT/GOT, and OS Binary Loading](docs/04_linking_and_execution.md)
- [Section 5: Intel vs. AT&T Assembly Syntax](docs/05_intel_vs_att_syntax.md)
- [Section 6: x86-64 Relocation Types in ELF](docs/06_relocation_types.md)
- [Section 7: C Runtime (CRT) Startup Internals](docs/07_crt_startup_internals.md)
- [Architecture Deep Dive: GCC Internals & Virtual Memory](docs/GCC_INTERNALS_GUIDE.md)

---

## 📄 License
Released under the [MIT License](LICENSE).
