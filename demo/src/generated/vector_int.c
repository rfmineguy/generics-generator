#include "vector_int.h"
#include "vector_int_spec.c"
#include <assert.h>
#include <stdlib.h>

vec_int vec_int_create() {
	vec_int dyn_array = {.data = 0, .capacity = 10, .size = 0};
	return dyn_array;
}

void vec_int_reserve_if_needed(vec_int* arr, int capacity) {
	if (arr->size + 1 >= arr->capacity) {
		arr->data = realloc(arr->data, capacity);
		arr->capacity = capacity;
	}
}

void vec_int_pushback (vec_int* arr, int val) {
	vec_int_reserve_if_needed(arr, arr->capacity * 2);
	arr->data[arr->size++] = val;
}

void vec_int_pushfront(vec_int* arr, int val) {
	vec_int_reserve_if_needed(arr, arr->capacity * 2);
	assert(arr->size + 1 <= arr->capacity && "Not enough space to pushfront");
	for (int i = 0; i < arr->size; i++) {
		arr->data[i + 1] = arr->data[i];
	}
	arr->data[0] = val;
	arr->size++;
}

void vec_int_popback(vec_int* arr) {
	for (int i = 0; i < arr->size; i++) {
		arr->data[i] = arr->data[i + 1];
	}
	arr->size--;
}

void vec_int_popfront (vec_int* arr) {
	for (int i = 1; i < arr->size; i++) {
		arr->data[i - 1] = arr->data[i];
	}
	arr->size--;
}

int vec_int_peekfront(vec_int* arr) {
	assert(arr->size == 0 && "Dynamic array size 0. Can't peekfront.");
	return arr->data[0];
}

int vec_int_peekback(vec_int* arr) {
	assert(arr->size == 0 && "Dynamic array size 0. Can't peekfront.");
	return arr->data[arr->size - 1];
}

void vec_int_print(vec_int* arr) {
	for (int i = 0; i < arr->size; i++) {
		vec_int_print_int(arr->data[i]);
	}
}

int* vec_int_get(vec_int* arr, int v) {
	for (int i = 0; i < arr->size; i++) {
		if (vec_int_cmp(arr->data[i], v) == 0) {
			return &arr->data[i];
		}
	}
	return (void*)0;
}
