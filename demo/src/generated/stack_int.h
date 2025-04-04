#ifndef STACK_int_H
#define STACK_int_H
#include "stdint.h"

typedef struct stack_int {
	int* data;
	int top;
	int capacity;
} stack_int;

stack_int  		stack_int_new(int);
void 				stack_int_free(stack_int*);
void 				stack_int_push(stack_int*, int);
int 					stack_int_peek(stack_int*);
int 					stack_int_pop(stack_int*);
void 				stack_int_print(stack_int*);

#endif
