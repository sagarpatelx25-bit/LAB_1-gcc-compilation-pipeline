# LAB 1: GCC Compilation Pipeline: Step-by-Step Guide
## Comprehensive Technical Report & Systems Documentation

**Course:** ST5039CMD Programming and Operating System  
**Module:** C-Programming Basics / Integration and Process Concept (Lecture 2 & Lab 1)  
**Author:** Sagar Patel  
**Documentation Artifacts:** [PDF Guide](GCC_Compilation_Process_Step_by_Step_Guide.pdf) | [HTML Report](LAB_1_GCC_Compilation_Pipeline_Documentation.html)

---

## 📌 Executive Summary & Lab Summarization (LAB 1)

### 1. Lab Purpose & Overview
The execution of high-level C programs is underpinned by a systematic multi-phase compilation architecture. The **GNU Compiler Collection (GCC)** executes four sequential, specialized stages: **Preprocessing (`cpp`)**, **Compilation (`cc1`)**, **Assembly (`as`)**, and **Linking (`ld`)**. This laboratory dissects each individual stage, isolating the intermediate representations (`.i`, `.s`, `.o`) to examine how human-written abstractions are transformed into machine-executable ELF binaries executed by the Linux kernel.

### 2. Comprehensive Compilation Pipeline Matrix

| Stage | Sub-tool | GCC Flag | Input Extension | Output Extension | Output Nature | Core System Functionality |
|---|---|---|---|---|---|---|
| **0. Source Code** | Editor | — | — | `.c` | Plain Text | Author high-level program logic with functions, directives, and types. |
| **1. Preprocessing** | `cpp` (C Preprocessor) | `-E` | `.c` | `.i` | Text (Expanded C) | Strips comments, expands `#define` macros, inlines header files (`#include`), emits line markers. |
| **2. Compilation** | `cc1` (C Compiler Core) | `-S` | `.i` | `.s` | Text (x86-64 Assembly) | Lexical analysis, AST generation, semantic checks, register allocation, System V AMD64 ABI stack frames. |
| **3. Assembly** | `as` (GNU Assembler) | `-c` | `.s` | `.o` | Binary (ELF Relocatable) | Translates assembly mnemonics into CPU opcodes; creates symbol tables and relocation placeholders. |
| **4. Linking** | `ld` / `collect2` (GNU Linker) | `-o <name>` | `.o` | Executable (ELF64) | Binary (ELF Executable) | Merges object files, resolves external symbol references (`printf`), binds dynamic loader (`ld-linux`), sets `PT_LOAD`. |
| **5. Execution** | OS Kernel (`execve`) | `./<name>` | Executable | stdout | Terminal Stream | Kernel loads binary into virtual RAM, invokes dynamic linker, transfers control to `_start -> __libc_start_main -> main`. |

### 3. Key Concepts & System Takeaways
1. **Preprocessing (`.i`)**: Does not perform type checking or syntax validation. It is purely text-manipulation based on directives prefixed with `#`. Comments (`//` and `/* */`) are eliminated, headers like `stdio.h` are recursively expanded, and `# line "file"` linemarkers are added for gdb symbol mapping.
2. **Compilation (`.s`)**: Translates high-level language grammar into processor-specific assembly instructions (AT&T syntax default). Function prologues allocate stack frames (`pushq %rbp`, `movq %rsp, %rbp`), arguments are passed via registers (`%rdi`, `%rsi`, `%rdx`), and caller/callee-saved registers are managed.
3. **Assembly (`.o`)**: Emits binary machine instructions. Crucially, function calls to external libraries (`printf`) do not yet have resolved physical or virtual memory addresses; the assembler writes dummy offsets (`0x00000000`) and records relocation entries (`R_X86_64_PLT32`) in the object file.
4. **Linking (Executable)**: Solves the external reference problem. The linker matches unresolved symbols against libc, creates Procedure Linkage Table (PLT) and Global Offset Table (GOT) stubs for dynamic loading, and stamps the ELF executable header with the entry point address.
5. **Inspection Toolchain**:
   - `cat` / `head -n 30`: Inspect original `.c` and expanded `.i` source text.
   - `cat main.s`: Inspect generated AT&T x86-64 assembly instructions.
   - `objdump -d main.o`: Disassemble binary machine opcodes and inspect relocation entries.
   - `readelf -h main` / `readelf -l main`: Inspect ELF header and memory segment mapping headers.
   - `file main`: Validate file type (ELF 64-bit LSB pie executable, x86-64, dynamically linked).
   - `size main`: Inspect byte sizes allocated to `.text`, `.data`, and `.bss`.

---

## I. Executive Introduction & Learning Objectives

The compilation of a high-level C program into a machine-executable binary is a foundational concept in systems programming and computer architecture. A computer CPU cannot directly parse or execute human-readable C statements; it understands only binary machine code (0s and 1s) formatted according to the target instruction set architecture (ISA).

The **GNU Compiler Collection (GCC)** orchestrates this transformation through four distinct, sequential stages:
1. **Preprocessing** (`cpp` / `gcc -E`): Macro resolution, header inclusion, comment stripping, and linemarker generation.
2. **Compilation** (`cc1` / `gcc -S`): Semantic parsing, AST lowering, optimization, and target assembly language emission.
3. **Assembly** (`as` / `gcc -c`): Translation of assembly mnemonics into relocatable machine object code (ELF format).
4. **Linking** (`ld` / `collect2`): Symbol resolution against standard dynamic libraries (`libc`), PLT/GOT setup, and final executable binding.

This documentation provides a comprehensive, step-by-step practical demonstration of each phase, mapping directly to **Lecture 2** and **Lab 1**.

---

## II. C Program Structure & Compilation Flow

### 1. Standard C File Structure
A standard C source file adheres to a structured organizational hierarchy:

```
  ┌────────────────────────────────────────────────────────┐
  │ 1. Documentation Section   (/* Program description */) │
  ├────────────────────────────────────────────────────────┤
  │ 2. Preprocessing Section   (#include, #define)         │
  ├────────────────────────────────────────────────────────┤
  │ 3. Definition Section      (Global variables, types)   │
  ├────────────────────────────────────────────────────────┤
  │ 4. Main Function Body      (int main(void) { ... })    │
  ├────────────────────────────────────────────────────────┤
  │ 5. Subprogram / Helper     (void helper_func(void))    │
  └────────────────────────────────────────────────────────┘
```

### 2. High-Level Compilation Pipeline

```
  [ Source Code: main.c ]
            │
            │  Stage 1: Preprocessing (gcc -E)
            ▼
  [ Preprocessed File: main.i ]
            │
            │  Stage 2: Compilation (gcc -S)
            ▼
  [ Assembly File: main.s ]
            │
            │  Stage 3: Assembly (gcc -c)
            ▼
  [ Relocatable Object: main.o ]
            │
            │  Stage 4: Linking (gcc / ld)
            ▼
  [ Dynamic Executable: main ]
            │
            │  Execution: Kernel execve + ld-linux.so
            ▼
       [ Terminal stdout: "Hello World!" ]
```

---

## III. Step-by-Step Practical Demonstration

### Step 1: Original C Program
* **Objective**: View the original source code.
* **Command**: `cat src/main.c`
* **Artifact**: `src/main.c`

![Step 1 - Original C Program](docs/assets/screenshots/01_step1_source_cat.png)

* **Technical Analysis**:
  - Contains `#include <stdio.h>` preprocessor directive.
  - The `main()` entry point returns integer status code `0` to the operating system upon successful completion.

---

### Step 2: Preprocessing
* **Objective**: Process directives like `#include` and macros to generate the preprocessed source code (`.i`).
* **Command**: `gcc -E src/main.c -o stages/01_preprocess/sample_preprocessed_output.i`
* **Inspection**: `head -n 30 stages/01_preprocess/sample_preprocessed_output.i`

![Step 2 - Preprocessing](docs/assets/screenshots/02_step2_preprocessing_gcc_E.png)

* **Technical Analysis**:
  - The C Preprocessor recursively inlines all declarations and prototypes from `<stdio.h>`.
  - All source code comments are deleted.
  - Linemarkers in format `# line "filename" flags` are inserted to preserve debugging line correlation.

---

### Step 3: Compilation
* **Objective**: Convert the preprocessed C code into assembly language (`.s`).
* **Command**: `gcc -S stages/01_preprocess/sample_preprocessed_output.i -o stages/02_compile/main.s`
* **Inspection**: `cat stages/02_compile/main.s`

![Step 3 - Compilation](docs/assets/screenshots/03_step3_compilation_gcc_S.png)

* **Technical Analysis**:
  - The compiler parses C syntax and converts it into AT&T x86-64 assembly mnemonics.
  - Generates stack frame allocation (`pushq %rbp`, `movq %rsp, %rbp`).
  - Sets up the `.string` literal in the `.rodata` section.

---

### Step 4: Assembly
* **Objective**: Convert assembly instructions into machine-readable object code (`.o`) and inspect it.
* **Command**: `gcc -c stages/02_compile/main.s -o stages/03_assemble/main.o`
* **Inspection**: `objdump -d stages/03_assemble/main.o`

![Step 4 - Assembly](docs/assets/screenshots/04_step4_assembly_objdump.png)

* **Technical Analysis**:
  - The assembler converts symbolic mnemonics into hexadecimal machine bytes.
  - External call target for `puts`/`printf` is represented with zero offset `0x00000000` because the destination address is unknown until link time.

---

### Step 5: Linking
* **Objective**: Combine object files with required libraries to create the final executable binary.
* **Command**: `gcc stages/03_assemble/main.o -o main`
* **Inspection**: `file main`

![Step 5 - Linking](docs/assets/screenshots/05_step5_linking_file_info.png)

* **Technical Analysis**:
  - Linker resolves external relocations against standard GNU C Library (`libc.so.6`).
  - Emits an ELF 64-bit LSB PIE executable with resolved PLT and GOT offsets.

---

### Step 6: Execution
* **Objective**: Run the final executable program.
* **Command**: `./main`

![Step 6 - Execution](docs/assets/screenshots/06_step6_execution_output.png)

* **Technical Analysis**:
  - The OS loads the program segments into virtual memory via the `execve` system call and executes machine instructions, emitting `Hello World!` to `stdout`.

---

## IV. Lecture 2 Integration: Architecture Knowledge Test

1. **What are the four phases of GCC compilation?**
   * *Answer*: Preprocessing (`cpp`), Compilation (`cc1`), Assembly (`as`), and Linking (`ld`).
2. **What does the `-E` flag in GCC do?**
   * *Answer*: Stops after the preprocessing stage; outputs expanded source code without compiling.
3. **What is an ELF relocatable file (`.o`) vs an ELF executable?**
   * *Answer*: An object file (`.o`) has unresolved external symbols and relocation records; an executable has fully resolved symbols and an executable entry point.
4. **Why is dynamic linking preferred over static linking by default?**
   * *Answer*: Conserves RAM and disk storage by sharing standard library code across multiple running processes.
5. **How does the OS know where to start executing a binary?**
   * *Answer*: The ELF header specifies the entry point address (typically `_start`), which initializes libc runtime and calls `main()`.
