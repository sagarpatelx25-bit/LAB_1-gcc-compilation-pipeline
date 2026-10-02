# Deep Dive: GCC Internals, ELF Architecture, and Linux Runtime Execution

This technical reference details the underlying compiler driver architecture, intermediate representations, and binary execution mechanics of the GNU Compiler Collection (GCC) on modern 64-bit Linux systems (`x86-64`).

---

## 1. GCC as a Compiler Driver

The command `gcc` is not itself the compiler. It acts as an **orchestration driver** that invokes dedicated subsystem tools:

```
                  ┌───────────────────────────────┐
                  │      gcc (Compiler Driver)    │
                  └──────────────┬────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
         ▼                       ▼                       ▼
  cpp / cc1 -E             cc1 (Compiler)            as (Assembler)
  (Preprocessor)     (C -> GIMPLE -> RTL -> ASM)  (ASM -> ELF Object)
                                                         │
                                                         ▼
                                                collect2 / ld (Linker)
                                                (Object Files -> ELF Binary)
```

You can view the exact internal invocations by passing the verbose flag:
```bash
gcc -v src/main.c -o main
```

---

## 2. GCC Intermediate Representations (IR)

Before emitting assembly, GCC transforms the input code through multiple distinct abstraction layers:

1. **AST & GENERIC**: The parser builds an Abstract Syntax Tree representing C language grammar constructs.
2. **GIMPLE**: A 3-address language representation where complex expressions are broken into simple operations with at most three operands.
3. **Static Single Assignment (SSA)**: Every variable in GIMPLE is assigned exactly once. Optimizations like Dead Code Elimination (DCE), Constant Propagation, and Loop Invariant Code Motion occur here.
4. **Register Transfer Language (RTL)**: A hardware-near pseudo-assembly representation inspired by LISP S-expressions. Register allocation, instruction scheduling, and peephole optimizations occur in the RTL pipeline.

---

## 3. Linux Virtual Address Space Layout (x86-64)

When the Linux kernel loads an ELF executable into memory via the `execve()` system call, it constructs the following virtual memory map:

```
  0x00007FFFFFFFFFFF ┌─────────────────────────────────────────┐
                     │ Stack (grows downwards towards lower addr)│
                     ├─────────────────────────────────────────┤
                     │                   ▼                     │
                     │                                         │
                     │                   ▲                     │
                     ├─────────────────────────────────────────┤
                     │ Memory Mapping Region (mmap)            │
                     │ (Shared libraries: libc.so, ld-linux.so)│
                     ├─────────────────────────────────────────┤
                     │                   ▲                     │
                     │ Heap (grows upwards via brk / sbrk)     │
                     ├─────────────────────────────────────────┤
                     │ .bss (Uninitialized global/static data) │
                     ├─────────────────────────────────────────┤
                     │ .data (Initialized global/static data)  │
                     ├─────────────────────────────────────────┤
                     │ .rodata (Read-only data / string consts)│
                     ├─────────────────────────────────────────┤
                     │ .text (Executable machine instructions) │
  0x0000000000000000 └─────────────────────────────────────────┘
```

---

## 4. Symbol Resolution and Binding Mechanics

In the relocatable object file (`main.o`), symbols possess specific binding attributes visible via `readelf -s main.o`:

- **`STB_LOCAL`**: Visible only within the current compilation unit (e.g., static functions/variables).
- **`STB_GLOBAL`**: Exported to other modules (e.g., `main`, `calculate_square`).
- **`STB_WEAK`**: Global symbols that can be overridden by a non-weak symbol without causing a linker conflict.
- **`SHN_UNDEF`**: Undefined symbols referenced by this object file but implemented elsewhere (e.g., `printf`).
