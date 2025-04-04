#include <stdio.h>

void ll_int_node_print(int x) {
	printf("%d", x);
}

int ll_int_cmp(int a, int b) {
	if (a < b) return -1;
	if (a > b) return 1;
	return 0;
}
