# LAB 1: GCC Compilation Pipeline (Step-by-Step Engineering Guide)

[![Standard](https://img.shields.io/badge/C-C99%20%7C%20C11%20%7C%20C17-blue.svg)]()
[![Architecture](https://img.shields.io/badge/architecture-x86--64-orange.svg)]()
[![Binary Format](https://img.shields.io/badge/format-ELF64%20(SYSV)-red.svg)]()
[![Course](https://img.shields.io/badge/Course-ST5039CMD%20Programming%20%26%20OS-brightgreen.svg)]()
[![Documentation: PDF](https://img.shields.io/badge/Documentation-PDF%20Guide-red.svg)](GCC_Compilation_Process_Step_by_Step_Guide.pdf)
[![Documentation: HTML](https://img.shields.io/badge/Documentation-HTML%20Report-blue.svg)](LAB_1_GCC_Compilation_Pipeline_Documentation.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A rigorous, production-grade systems reference dissecting the **four fundamental phases of GCC compilation**: **Preprocessing**, **Compilation**, **Assembly**, and **Linking**, concluding with OS runtime binary execution.

---

## 📑 Lab Documentation Quick Links
* **Official PDF Guide:** [GCC_Compilation_Process_Step_by_Step_Guide.pdf](GCC_Compilation_Process_Step_by_Step_Guide.pdf)
* **Comprehensive Web Report:** [LAB_1_GCC_Compilation_Pipeline_Documentation.html](LAB_1_GCC_Compilation_Pipeline_Documentation.html)
* **Technical Markdown Documentation:** [LAB_1_GCC_Compilation_Pipeline_Documentation.md](LAB_1_GCC_Compilation_Pipeline_Documentation.md)

---

## 📌 Executive Summary & Lab Summarization (LAB 1)

### 1. Lab Purpose & High-Level Summary
The primary objective of **LAB 1** is to understand that a C compiler does not translate source code into an executable in a single monolithic step. Instead, the **GNU Compiler Collection (GCC)** drives a modular 4-stage pipeline: **Preprocessing (`cpp`)**, **Compilation (`cc1`)**, **Assembly (`as`)**, and **Linking (`ld`)**. By isolating each stage using specific compiler flags (`-E`, `-S`, `-c`), systems programmers gain visibility into header expansion, assembly mnemonic generation, machine code encoding, symbol table management, and executable linking.

### 2. The 4 Compilation Stages at a Glance

| Stage # | Stage Name | Internal Tool | GCC Command / Flag | Input File | Output File | Representation | Primary Responsibility |
|---|---|---|---|---|---|---|---|
| **0** | **Source Code** | Editor | `cat main.c` | — | `main.c` | High-level C text | Human-readable program logic written in C. |
| **1** | **Preprocessing** | Preprocessor (`cpp`) | `gcc -E main.c -o main.i` | `main.c` | `main.i` | Expanded C text | Expands `#include`, substitutes `#define` macros, removes comments, inserts linemarkers. |
| **2** | **Compilation** | Compiler (`cc1`) | `gcc -S main.i -o main.s` | `main.i` | `main.s` | x86-64 Assembly text | Parses C syntax, builds AST, optimizes logic, emits target assembly mnemonics. |
| **3** | **Assembly** | Assembler (`as`) | `gcc -c main.s -o main.o` | `main.s` | `main.o` | ELF Relocatable Object (Binary) | Encodes mnemonics into binary CPU opcodes; generates relocation & symbol tables. |
| **4** | **Linking** | Linker (`ld` / `collect2`) | `gcc main.o -o main` | `main.o` | `main` | ELF Executable (Binary) | Resolves external symbols (`printf`), binds dynamic loader (`ld-linux`), assigns virtual memory addresses. |
| **5** | **Execution** | OS Kernel (`execve`) | `./main` | `main` | stdout | Runtime Output | OS kernel loads binary into RAM, sets up stack/heap, executes entry point `_start -> main`. |

### 3. Summary of Core Technical Concepts
* **Preprocessing Stage (`.i`)**: Replaces preprocessor directives before compilation begins. `#include <stdio.h>` pulls in thousands of lines of libc headers, stripping all comments (`//` and `/* */`) and inserting `# line "filename"` linemarkers to allow runtime debuggers to trace back to original lines.
* **Compilation Stage (`.s`)**: Transforms high-level language structures into target processor assembly instructions (AT&T syntax on Linux x86-64). Manages stack frame allocations (`pushq %rbp`, `movq %rsp, %rbp`), registers (`%rax`, `%rdi`), and calling conventions according to the System V AMD64 ABI.
* **Assembly Stage (`.o`)**: Converts symbolic assembly into binary machine code (0s and 1s) packaged within an **ELF (Executable and Linkable Format)** relocatable file. Because external memory addresses (such as `printf`) are unknown at this stage, placeholder addresses `0x00` are inserted, recorded alongside relocation entries.
* **Linking Stage (Executable)**: Combines multiple relocatable object files and shared libraries (`libc.so`). Resolves relocation records, calculates relative Program Counter (`PC32`) and Procedure Linkage Table (`PLT32`) offsets, and outputs a self-contained ELF64 executable.
* **Standard Inspection Utilities**:
  - `head -n 30 main.i`: Inspect preprocessor header expansion and linemarkers.
  - `cat main.s`: Inspect generated x86-64 assembly instructions and directives.
  - `objdump -d main.o`: Disassemble binary machine opcodes and inspect relocation placeholders.
  - `readelf -h main` / `file main`: Verify ELF header architecture, entry point address, and dynamic interpreter.
  - `size main`: Quantify byte footprints of `.text`, `.data`, and `.bss` sections.

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
* **Command**: `cat src/main.c`
* **Terminal Screenshot**:

![Step 1 - Original C Source Code](docs/assets/screenshots/01_step1_source_cat.png)

* **Observation**: Displays the initial C source code written by the programmer (`#include <stdio.h>` with a `main()` function returning 0).

---

### Step 2: Preprocessing
* **Objective**: Process directives like `#include` and macros to generate the preprocessed source code (`.i`).
* **Command**: `gcc -E src/main.c -o stages/01_preprocess/sample_preprocessed_output.i`
* **Terminal Screenshot**:

![Step 2 - Preprocessing Output](docs/assets/screenshots/02_step2_preprocessing_gcc_E.png)

* **Observation**: The code expands to include standard library declarations, removing comments and resolving macros. Linemarkers indicate original source file boundaries.

---

### Step 3: Compilation
* **Objective**: Convert the preprocessed C code into assembly language (`.s`).
* **Command**: `gcc -S stages/01_preprocess/sample_preprocessed_output.i -o stages/02_compile/main.s`
* **Terminal Screenshot**:

![Step 3 - Assembly Translation](docs/assets/screenshots/03_step3_compilation_gcc_S.png)

* **Observation**: The compiler translates the C syntax into low-level CPU-specific assembly instructions (AT&T syntax for x86-64), allocating stack frames and calling conventions.

---

### Step 4: Assembly
* **Objective**: Convert assembly instructions into machine-readable object code (`.o`) and inspect it.
* **Command**: `gcc -c stages/02_compile/main.s -o main.o then objdump -d main.o`
* **Terminal Screenshot**:

![Step 4 - Machine Code Disassembly](docs/assets/screenshots/04_step4_assembly_objdump.png)

* **Observation**: The assembler creates binary machine code. The `objdump` tool allows viewing raw hex opcodes alongside disassembled mnemonics. Notice external function calls like `printf` have placeholder addresses.

---

### Step 5: Linking
* **Objective**: Combine object files with required libraries (`libc.so`) to create the final executable binary.
* **Command**: `gcc main.o -o main then file main`
* **Terminal Screenshot**:

![Step 5 - Linking and Binary Format](docs/assets/screenshots/05_step5_linking_file_info.png)

* **Observation**: The linker resolves external function calls, binds the dynamic linker `/lib64/ld-linux-x86-64.so.2`, and produces an executable ELF64 binary.

---

### Step 6: Execution
* **Objective**: Run the final executable program.
* **Command**: `./main`
* **Terminal Screenshot**:

![Step 6 - Binary Execution](docs/assets/screenshots/06_step6_execution_output.png)

* **Observation**: The OS kernel loads the compiled binary into memory via `execve`, executes machine instructions, and outputs "Hello World!" to `stdout`.

---

## 🛠️ Build and Automation Commands

```bash
# Run full automated pipeline across all 4 stages
chmod +x scripts/run_pipeline.sh
./scripts/run_pipeline.sh

# Build all intermediate artifacts using Makefile
make all

# Inspect binary ELF headers and segments
chmod +x scripts/inspect_elf.sh
./scripts/inspect_elf.sh

# Analyze ELF section sizes (.text, .data, .bss)
chmod +x scripts/analyze_binary_size.sh
./scripts/analyze_binary_size.sh

# Clean all generated pipeline artifacts
make clean
```

---

## 📄 License
Released under the [MIT License](LICENSE).
