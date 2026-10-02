# Stage 1: The Preprocessor (cpp / gcc -E)

The preprocessor is the initial pass in the GCC compilation pipeline. It functions purely as a textual stream transformer before any semantic parsing or syntax validation occurs.

---

## Terminal Execution & Output
```bash
gcc -E src/main.c -o main.i
head -n 30 main.i
```

![Stage 1 Preprocessing Output](assets/screenshots/02_step2_preprocessing_gcc_E.png)

---

## Key Transformations

1. **Header Inclusion (`#include`)**
   - Directives like `#include <stdio.h>` are recursively expanded by physically pasting the entire contents of the header into the stream.
   - Angle brackets (`<...>`) search standard system include directories (e.g., `/usr/include`).
   - Quotes (`"..."`) search the local directory relative to the current file before system paths.

2. **Macro Expansion (`#define`)**
   - Identifiers defined as macros are lexically replaced.
   - For example, `#define GREETING_MSG "Hello World!\n"` causes `printf(GREETING_MSG);` to be emitted as `printf("Hello World!\n");`.

3. **Comment Stripping**
   - All C-style (`/* ... */`) and C++-style (`// ...`) comments are completely discarded and replaced with a single space.

4. **Linemarker Generation**
   - Lines starting with `#` inside `.i` files are **linemarkers**:
     ```
     # linenum filename flags
     ```
   - Flags signify:
     - `1`: Start of a new file.
     - `2`: Returning to a file after an inclusion has concluded.
     - `3`: The following text comes from a system header file.
     - `4`: The following text should be treated as wrapped in an implicit `extern "C"` block.
