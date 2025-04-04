#include <stdio.h>

void vec_int_print_int(int v) {
	printf("%d", v);
}

int vec_int_cmp(int a, int b) {
	if (a < b) return -1;
	if (a > b) return 1;
	return 0;
}
