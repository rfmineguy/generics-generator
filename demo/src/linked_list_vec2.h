#ifndef LL_vec2
#define LL_vec2
#include "vec2.h"

typedef struct ll_node_vec2 {
	vec2 val;
	struct ll_node_vec2 *next, *prev;
} ll_node_vec2;

typedef struct {
	int size;
	struct ll_node_vec2 *head, *tail;
} ll_vec2;

ll_vec2 ll_vec2_new();
void ll_vec2_free(ll_vec2*);
void ll_vec2_pushback(ll_vec2*, vec2);
void ll_vec2_pushfront(ll_vec2*, vec2);
void ll_vec2_popback(ll_vec2*, vec2);
void ll_vec2_popfront(ll_vec2*, vec2);
void ll_vec2_print(ll_vec2*);

#endif
