#include "vec2.h"
#include <stdio.h>

void ll_vec2_node_print(vec2 x) {
	printf("{x: %f, y: %f}", x.x, x.y);
}

int ll_vec2_cmp(vec2 a, vec2 b) {
	if (a.x < b.x && a.y < b.y) return -1;
	if (a.x > b.x && b.y > b.y) return 1;
	return 0;
}
