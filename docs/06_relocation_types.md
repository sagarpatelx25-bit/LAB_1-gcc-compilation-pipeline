# Section 6: x86-64 Relocation Types in ELF Object Files

Relocations are the mechanism by which the assembler flags unresolved symbol addresses for the linker to compute and patch during stage 4.

---

## 1. Common x86-64 Relocation Types

| Relocation Macro | Field Calculation | Description |
|---|---|---|
| `R_X86_64_64` | `S + A` | Direct 64-bit absolute address calculation (used for pointers in data segment). |
| `R_X86_64_PC32` | `S + A - P` | 32-bit signed PC-relative displacement (used for RIP-relative addressing of `.rodata`). |
| `R_X86_64_PLT32` | `L + A - P` | 32-bit displacement to Procedure Linkage Table (used for function calls like `printf`). |
| `R_X86_64_GOTPCREL` | `G + GOT + A - P` | 32-bit signed displacement to Global Offset Table entry. |

*Where: `S` = Symbol value, `A` = Addend, `P` = Place of instruction pointer offset, `L` = PLT entry address.*

---

## 2. Inspecting Relocation Records

```bash
readelf -r main.o
```
Emits:
```
Relocation section '.rela.text' at offset 0x1c8 contains 2 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
00000000000b  000300000002 R_X86_64_PC32     0000000000000000 .rodata - 4
000000000018  000500000004 R_X86_64_PLT32    0000000000000000 printf - 4
```
