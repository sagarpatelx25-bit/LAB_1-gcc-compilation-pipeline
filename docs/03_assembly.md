# Stage 3: The Assembler (as / gcc -c)

The assembler takes the human-readable assembly instructions (`.s`) and converts them into machine code, packaging the result into an ELF (Executable and Linkable Format) Relocatable Object File (`.o`).

---

## Terminal Execution & Output
```bash
gcc -c main.s -o main.o
objdump -d main.o
```

![Stage 3 Assembly & Disassembly Output](assets/screenshots/04_step4_assembly_objdump.png)

---

## Machine Code Opcode Anatomy

| Offset | Raw Machine Bytes | Mnemonic Instruction | Technical Explanation |
|---|---|---|---|
| `00` | `f3 0f 1e fa` | `endbr64` | 4-byte instruction enforcing indirect branch tracking on Intel CPUs. |
| `04` | `55` | `push %rbp` | 1-byte opcode decrementing `%rsp` by 8 and storing the caller's frame pointer. |
| `05` | `48 89 e5` | `mov %rsp,%rbp` | `48` is the REX.W prefix (64-bit operand size), `89` is MOV opcode, `e5` is the ModR/M byte. |
| `08` | `48 8d 05 00 00 00 00` | `lea 0x0(%rip),%rax` | Notice the four zero bytes (`00 00 00 00`). The address of string literal `.LC0` is not yet bound. The assembler emits a relocation entry (`R_X86_64_PC32`). |
| `0f` | `48 89 c7` | `mov %rax,%rdi` | Moves string pointer into first argument register (`%rdi`). |
| `12` | `b8 00 00 00 00` | `mov $0x0,%eax` | Immediate 32-bit zero loaded into `%eax`. |
| `17` | `e8 00 00 00 00` | `call 1c <main+0x1c>` | `e8` is near relative CALL. The `00 00 00 00` is a relocation placeholder (`R_X86_64_PLT32`) for `printf`. |
| `1c` | `b8 00 00 00 00` | `mov $0x0,%eax` | Sets return value to `0`. |
| `21` | `5d` | `pop %rbp` | 1-byte opcode restoring the caller frame pointer. |
| `22` | `c3` | `ret` | 1-byte opcode popping return address into `%rip`. |

---

## Relocation Entries in Relocatable Objects
Inspecting relocations using `readelf -r main.o`:
```
Relocation section '.rela.text' at offset 0x1c8 contains 2 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
00000000000b  000300000002 R_X86_64_PC32     0000000000000000 .rodata - 4
000000000018  000500000004 R_X86_64_PLT32    0000000000000000 printf - 4
```
The linker uses these entries to patch the zeroed offsets into exact relative jumps.
