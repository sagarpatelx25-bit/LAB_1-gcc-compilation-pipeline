#include <stdio.h>

#define MULTIPLY(x, y) ((x) * (y))
#define SYSTEM_VERSION "2.4.0-linux"

#ifdef DEBUG
    #define LOG_DEBUG(msg) printf("[DEBUG] %s\n", msg)
#else
    #define LOG_DEBUG(msg) do {} while(0)
#endif

int main(void) {
    LOG_DEBUG("Preprocessor macro test initializing...");
    printf("Version: %s\n", SYSTEM_VERSION);
    printf("Computed Macro: 6 * 7 = %d\n", MULTIPLY(6, 7));
    return 0;
}
