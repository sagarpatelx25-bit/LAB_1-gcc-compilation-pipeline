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
```c
#include <stdio.h>

#define GREETING_MSG "Hello World!\n"

int main(void) {
    printf(GREETING_MSG);
    return 0;
}
```
**Observation**: Clean high-level C code containing preprocessor directives (`#include`, `#define`) and standard function calls.

---

### Step 2: Preprocessing
```bash
gcc -E src/main.c -o main.i
head -n 30 main.i
```
**Sample Output**:
```
# 0 "src/main.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "src/main.c"
# 1 "/usr/include/stdio.h" 1 3 4
# 28 "/usr/include/stdio.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/libc-header-start.h" 1 3 4
```
**Observation**: Standard library declarations are inlined (~800+ lines), comments are removed, and macros are resolved into direct literals. Linemarkers (`# linenum filename flags`) preserve original file mapping.

---

### Step 3: Compilation (C to Assembly)
```bash
gcc -S main.i -o main.s
cat main.s
```
**Generated x86-64 Assembly (AT&T Syntax)**:
```assembly
	.file	"main.c"
	.text
	.section	.rodata
.LC0:
	.string	"Hello World!\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	leaq	.LC0(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 15.2.0-16ubuntu1) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
```
**Observation**: The compiler parses the code, applies optimization passes, and emits low-level assembly. It follows the **System V AMD64 ABI** (`%rdi` for the first argument, `%rax` for return values, `%rbp` frame pointer chain).

---

### Step 4: Assembly (Assembly to Relocatable Object)
```bash
gcc -c main.s -o main.o
objdump -d main.o
```
**Disassembly & Machine Opcodes**:
```
main.o:     file format elf64-x86-64

Disassembly of section .text:

0000000000000000 <main>:
   0:	f3 0f 1e fa          	endbr64
   4:	55                   	push   %rbp
   5:	48 89 e5             	mov    %rsp,%rbp
   8:	48 8d 05 00 00 00 00 	lea    0x0(%rip),%rax        # f <main+0xf>
   f:	48 89 c7             	mov    %rax,%rdi
  12:	b8 00 00 00 00       	mov    $0x0,%eax
  17:	e8 00 00 00 00       	call   1c <main+0x1c>
  1c:	b8 00 00 00 00       	mov    $0x0,%eax
  21:	5d                   	pop    %rbp
  22:	c3                   	ret
```
**Observation**: The assembler encodes instructions into binary opcodes. The placeholders (`00 00 00 00` at offsets `0x8` and `0x17`) indicate unresolved relocation entries (`R_X86_64_PC32` and `R_X86_64_PLT32`) waiting for the linker.

---

### Step 5: Linking (Object Code to Dynamic Executable)
```bash
gcc main.o -o main
file main
```
**Output**:
```
main: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=21234bf3707979b6c1dd8453896f7122d222ab6a, for GNU/Linux 3.2.0, not stripped
```
**Observation**: The linker resolves symbol references (`printf` mapped to `libc.so.6`), injects the runtime start code (`_start` in `crt1.o`), and specifies the dynamic loader interpreter (`/lib64/ld-linux-x86-64.so.2`).

---

### Step 6: Execution
```bash
./main
```
**Output**:
```
Hello World!
```
**Observation**: The OS kernel loads the ELF segments via `execve()`, maps the shared library dependencies, and transfers execution control to `_start` $\rightarrow$ `main()`.

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
