# Stage 4 & 5: Linking and Operating System Execution (ld & ld.so)

The linker (`ld`) performs the final stage of compilation, combining relocatable object files (`.o`), static archives (`.a`), and dynamic shared objects (`.so`) into an executable ELF binary.

---

## 1. Terminal Execution & Output

### Step 5: Linking & Binary Identification
```bash
gcc main.o -o main
file main
```

![Stage 4 Linking and Binary File Verification](assets/screenshots/05_step5_linking_file_info.png)

### Step 6: Program Execution
```bash
./main
```

![Stage 5 Program Execution](assets/screenshots/06_step6_execution_output.png)

---

## 2. What the Linker Accomplishes

### A. Symbol Resolution
The object file `main.o` contains an undefined reference to `printf` (`U printf` in `nm` output). The linker searches standard libraries (primarily `libc.so.6`) to ensure every referenced symbol is defined.

### B. Relocation Patching
During assembly, the offsets for `printf` and `.LC0` were encoded as zeros (`00 00 00 00`). The linker patches these placeholders with the calculated relative address offsets:
$$\text{Offset} = \text{Target Address} - \text{PC of next instruction}$$

### C. Procedure Linkage Table (PLT) & Global Offset Table (GOT)
To enable shared libraries to be mapped at arbitrary virtual addresses (ASLR / PIC):
1. Code calls `printf@PLT`.
2. The PLT jumps indirectly through the corresponding GOT entry (`printf@GOT`).
3. On first execution, the GOT points back into the PLT, which invokes the dynamic linker (`ld-linux.so.2`) to look up `printf` in `libc.so.6`.
4. The resolved address is written into the GOT so future calls execute with zero resolution overhead.

### D. Entry Point and Runtime Crits
The true entry point of a Linux ELF executable is NOT `main()`, but `_start` (provided by `crt1.o`). `_start` collects command line arguments and environment variables from the stack, initializes the runtime, and passes control to `__libc_start_main`, which in turn calls `main()`.

---

## 3. Kernel Binary Loading & Execution Lifecycle

```
[User runs ./main]
       │
       ▼
 [syscall: execve] ───► Kernel validates ELF magic number (0x7F 'E' 'L' 'F')
       │
       ▼
 [Virtual Memory Setup] Maps .text (RX), .data (RW), .rodata (R), initializes Stack & Heap
       │
       ▼
 [Dynamic Linker: ld-linux.so] Loads /lib64/ld-linux-x86-64.so.2 to map libc.so.6 dependencies
       │
       ▼
 [Entry Point: _start] Runs initialization constructors via crti.o
       │
       ▼
 [__libc_start_main] Invokes user main(argc, argv, envp)
       │
       ▼
 [main() executes] Outputs "Hello World!" via write(1, ...)
       │
       ▼
 [Exit Syscall] exit_group(0) terminates process and reclaims pages
```
