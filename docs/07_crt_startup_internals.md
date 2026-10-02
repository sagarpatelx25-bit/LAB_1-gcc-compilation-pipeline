# Section 7: C Runtime (CRT) Startup Internals

Before `main()` receives control, the operating system kernel and dynamic linker initialize the C runtime environment through a series of object modules.

---

## 1. Startup Module Pipeline

```
  Linux Kernel (execve)
         │
         ▼
  Dynamic Linker (/lib64/ld-linux-x86-64.so.2)
         │
         ▼
  Entry Point: _start (from crt1.o)
         │
         ▼
  libc Initializer: __libc_start_main()
         │
         ├─── Runs Global Constructors (crti.o & .init_array)
         │
         ▼
  User Code: main(argc, argv, envp)
         │
         ▼
  libc Terminator: exit()
         │
         ├─── Runs Destructors (.fini_array & crtn.o)
         │
         ▼
  Syscall: exit_group()
```

---

## 2. CRT Modules Responsibility

* **`crt1.o`**: Defines the `_start` symbol and sets up stack parameters.
* **`crti.o`**: Provides function prologues for the `.init` and `.fini` sections.
* **`crtbegin.o` / `crtend.o`**: Helper modules managing C++ exception unwinding frames and global constructors.
* **`crtn.o`**: Provides function epilogues for `.init` and `.fini`.
