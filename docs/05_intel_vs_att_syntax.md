# Section 5: Assembly Syntax: Intel vs. AT&T Format

GCC defaults to **AT&T syntax** when targeting x86-64, but also supports **Intel syntax** via the `-masm=intel` flag.

---

## 1. Syntax Comparison Table

| Attribute | AT&T Syntax (GCC Default) | Intel Syntax (MASM / NASM / Windows) |
|---|---|---|
| **Operand Order** | `instruction source, destination` | `instruction destination, source` |
| **Example MOV** | `movl $1, %eax` | `mov eax, 1` |
| **Register Prefix** | Prefix `%` required (e.g. `%rax`, `%rdi`) | No prefix (e.g. `rax`, `rdi`) |
| **Immediate Values** | Prefix `$` required (e.g. `$42`, `$0x10`) | No prefix (e.g. `42`, `0x10`) |
| **Memory Dereference** | `segment:displacement(base, index, scale)` | `[base + index*scale + displacement]` |
| **Example LEA** | `leaq .LC0(%rip), %rax` | `lea rax, [rip + .LC0]` |
| **Size Suffixes** | Explicit suffix (`b`, `w`, `l`, `q`) | Operand size directive (`BYTE PTR`, `DWORD PTR`, `QWORD PTR`) |

---

## 2. Generating Intel Syntax via GCC

```bash
gcc -S -masm=intel src/main.c -o main_intel.s
```
