#include <stdio.h>

int bt_int_compare(int a, int b) {
	if (a == b) return 0;
	else if (a < b) return -1;
	else return 1;
}

void bt_int_node_print(int x) {
	printf("%d", x);
}
