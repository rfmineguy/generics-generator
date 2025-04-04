#ifndef VECintOR_int_H
#define VECintOR_int_H
#include "stdint.h"

typedef struct vec_int {
	int *data;
	int capacity, size;
} vec_int;

vec_int vec_int_create();
void vec_int_reserve  (vec_int*, int);
void vec_int_pushback (vec_int*, int);
void vec_int_pushfront(vec_int*, int);
void vec_int_popback  (vec_int*);
void vec_int_popfront (vec_int*);
int 	 vec_int_peekfront(vec_int*);
int 	 vec_int_peekback (vec_int*);
void vec_int_print    (vec_int*);
int*   vec_int_get 			(vec_int*, int);

#endif
