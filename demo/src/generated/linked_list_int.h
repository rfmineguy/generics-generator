#ifndef LL_int
#define LL_int
#include "stdint.h"

typedef struct ll_node_int {
	int val;
	struct ll_node_int *next, *prev;
} ll_node_int;

typedef struct {
	int size;
	struct ll_node_int *head, *tail;
} ll_int;

ll_int ll_int_new();
void ll_int_free(ll_int*);
void ll_int_pushback(ll_int*, int);
void ll_int_pushfront(ll_int*, int);
void ll_int_popback(ll_int*, int);
void ll_int_popfront(ll_int*, int);
void ll_int_delete(ll_int*, int);
void ll_int_print(ll_int*);

#endif
