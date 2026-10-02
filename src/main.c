#include <stdio.h>

#define GREETING_MSG "Hello World!\n"

/**
 * main - Program entry point
 * 
 * Demonstrates:
 * 1. Macro substitution during preprocessing (#define)
 * 2. Header expansion from standard library (<stdio.h>)
 * 3. Assembly instruction emission and stack alignment (System V AMD64 ABI)
 * 4. Relocatable object generation and external symbol resolution (printf)
 */
int main(void) {
    printf(GREETING_MSG);
    return 0;
}
