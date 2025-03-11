#include <stdio.h>
#include "vec2.h"

int bt_vec2_compare(vec2 a, vec2 b) {
	if (a.x == b.x && a.y == b.y) return 0;
	else if (a.x < b.x && a.y < b.y) return -1;
	else return 1;
}

void bt_vec2_node_print(vec2 x) {
	printf("(%f, %f)", x.x, x.y);
}
