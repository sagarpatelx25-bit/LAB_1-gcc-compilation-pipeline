# Stage 2: The Compiler (cc1 / gcc -S)

The compilation phase takes the preprocessed `.i` stream, performs semantic analysis, parses it into an Abstract Syntax Tree (AST), lowers it to intermediate representations (GIMPLE and RTL), and emits target assembly language (`.s`).

---

## Terminal Execution & Output
```bash
gcc -S main.i -o main.s
head -n 30 main.s
```

![Stage 2 Assembly Generation](assets/screenshots/03_step3_compilation_gcc_S.png)

---

## Line-by-Line Instruction Dissection

| Assembly Directive / Mnemonic | Purpose & Systems Context |
|---|---|
| `.section .rodata` | Directs the assembler to place string literal `"Hello World!\n"` in the Read-Only Data section. |
| `.globl main` | Exports `main` into the global symbol table so external linkers can locate it. |
| `endbr64` | Intel CET (Control-flow Enforcement Technology) marker to mitigate ROP/JOP attacks on x86-64. |
| `pushq %rbp` | Pushes the caller's base pointer onto the runtime stack. |
| `movq %rsp, %rbp` | Establishes the new stack frame base for `main`. |
| `leaq .LC0(%rip), %rax` | Computes the runtime address of `.LC0` relative to the current Instruction Pointer (`%rip`). This enables Position-Independent Executables (PIE). |
| `movq %rax, %rdi` | According to the **System V AMD64 ABI**, the 1st integer/pointer argument to any function must reside in `%rdi`. |
| `movl $0, %eax` | For variadic functions like `printf`, the `%al` (low byte of `%rax`) register denotes the number of vector/SSE registers used (0 here). |
| `call printf@PLT` | Calls the `printf` stub inside the Procedure Linkage Table for dynamic resolution. |
| `movl $0, %eax` | Sets the return value of `main` (`return 0;`) in the accumulator register `%rax`. |
| `popq %rbp` | Restores the caller's frame pointer. |
| `ret` | Pops the return address off the stack and jumps back to the caller (`__libc_start_main`). |

---

## System V AMD64 Calling Convention Reference
- **Integer/Pointer Arguments**: `%rdi` (1st), `%rsi` (2nd), `%rdx` (3rd), `%rcx` (4th), `%r8` (5th), `%r9` (6th).
- **Return Value**: `%rax` (low 64 bits), `%rdx` (high 64 bits if 128-bit struct).
- **Callee-saved Registers**: `%rbx`, `%rsp`, `%rbp`, `%r12`, `%r13`, `%r14`, `%r15`.
- **Caller-saved Registers**: `%rax`, `%rdi`, `%rsi`, `%rdx`, `%rcx`, `%r8`, `%r9`, `%r10`, `%r11`.
