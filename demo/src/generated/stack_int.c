#include "stack_int.h"
#include "stack_int_spec.c"
#include <stdlib.h>
#include <stdio.h>

stack_int stack_int_new(int initialCapacity) {
	stack_int s = (stack_int){0};
	s.capacity = initialCapacity;
	s.data = calloc(s.capacity, sizeof(int));
	s.top = -1;
	return s;
}

void stack_int_free(stack_int* stack) {
	free(stack->data);
}

void stack_int_push(stack_int* stack, int val) {
	if (stack->top + 1 >= stack->capacity) {
		stack->data = realloc(stack->data, stack->capacity * 2);
		stack->capacity *= 2;
	}
	stack->data[++stack->top] = val;
}

int stack_int_peek(stack_int* stack) {
	if (stack->top == -1) {
		fprintf(stderr, "Can't peek\n");
	}
	return stack->data[stack->top];
}

int stack_int_pop(stack_int* stack) {
	int v = stack_int_peek(stack);
	stack->top--;
	if (stack->top <= -1) stack->top = -1;
	return v;
}

void stack_int_print(stack_int* stack) {
	for (int i = stack->top; i >= 0; i--) {
		printf("%d : ", i); stack_int_print_val(stack->data[i]); printf("\n");
	}
}
