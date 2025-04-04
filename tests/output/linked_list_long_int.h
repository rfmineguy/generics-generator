#ifndef LL_long_int
#define LL_long_int
#include "stdint.h"

typedef struct ll_node_long_int {
	long int val;
	struct ll_node_long_int *next, *prev;
} ll_node_long_int;

typedef struct {
	int size;
	struct ll_node_long_int *head, *tail;
} ll_long_int;

ll_long_int ll_long_int_new();
void ll_long_int_free(ll_long_int*);
void ll_long_int_pushback(ll_long_int*, long int);
void ll_long_int_pushfront(ll_long_int*, long int);
void ll_long_int_popback(ll_long_int*, long int);
void ll_long_int_popfront(ll_long_int*, long int);
void ll_long_int_print(ll_long_int*);

#endif
