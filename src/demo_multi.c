#include <stdio.h>
#include "math_utils.h"

int main(void) {
    int val = 7;
    int sq = calculate_square(val);
    printf("Demonstrating multi-object linking: square of %d is %d\n", val, sq);
    return 0;
}
