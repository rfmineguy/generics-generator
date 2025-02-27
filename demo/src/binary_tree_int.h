#ifndef BINARY_TREE_int_H
#define BINARY_TREE_int_H
#include "stdint.h"

typedef struct binary_tree_node_int {
	int val;
	struct binary_tree_node_int *left, *right;
} binary_tree_node_int;

typedef struct binary_tree_int {
	struct binary_tree_node_int *root;
} binary_tree_int;

binary_tree_int bt_int_new();
void 					bt_int_insert(binary_tree_int*, int);
void 					bt_int_delete(binary_tree_int*, int);
void 					bt_int_print(binary_tree_int*);

#endif
