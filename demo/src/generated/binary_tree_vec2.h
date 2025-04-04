#ifndef BINARY_TREE_vec2_H
#define BINARY_TREE_vec2_H
#include "vec2.h"

typedef struct binary_tree_node_vec2 {
	vec2 val;
	struct binary_tree_node_vec2 *left, *right;
} binary_tree_node_vec2;

typedef struct binary_tree_vec2 {
	struct binary_tree_node_vec2 *root;
} binary_tree_vec2;

binary_tree_vec2 		  bt_vec2_new();
void 							  bt_vec2_insert(binary_tree_vec2*, vec2);
void 							  bt_vec2_delete(binary_tree_vec2*, vec2);
binary_tree_node_vec2* bt_vec2_find(binary_tree_vec2*, vec2);
void 						 	  bt_vec2_print(binary_tree_vec2*);
void 						  	bt_vec2_free(binary_tree_vec2*);

#endif
