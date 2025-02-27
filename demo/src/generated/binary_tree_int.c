#include "binary_tree_int.h"
#include "binary_tree_int_spec.c"
#include <stdlib.h>
#include <stdio.h>

/**
 *    User is required to implement a few select functions in their own spec file
 *    	- bt_int_compare(int, int)
 *    		+ return 0 on equal
 *    		+ return -1 on less
 *    		+ return 1 on greater
 *    	- bt_int_node_print(int)
 *    		+ you decide how to print the node data
 */

int bt_int_compare(int, int);
void bt_int_node_print(int);

// Helper functions
void bt_int_insert_node_rec(binary_tree_node_int** n, int val) {
	if (!(*n)) {
		(*n) = calloc(1, sizeof(binary_tree_node_int));
		(*n)->val = val;
		return;
	}
	if ((*n) && bt_int_compare(val, (*n)->val) < 0) bt_int_insert_node_rec(&(*n)->left, val);
	if ((*n) && bt_int_compare(val, (*n)->val) >= 0) bt_int_insert_node_rec(&(*n)->right, val);
}

void bt_int_delete_node_rec(binary_tree_node_int** n, int val) {
	if (!(*n)) {
		return;
	}
	if ((*n)->val == val) {
		// traverse right of left to replace n
		binary_tree_node_int* t = (*n)->left;
		while (t->right) t = t->right;
		(*n)->val = t->val;
		free(t);
	}
	if (val > (*n)->val) {
		bt_int_delete_node_rec(&(*n)->right, val);
	}
	else {
		bt_int_delete_node_rec(&(*n)->left, val);
	}
}

/*
┗4
 ┗5
  ┗5
 ┗6
*/
void bt_int_print_rec(binary_tree_node_int* n, int depth) {
	if (!n) {
		printf("%*.c\\_ NULL\n", depth * 3, ' '); 
		return;
	}
	printf("%*.c\\_ ", depth * 3, ' '); bt_int_node_print(n->val); printf("\n");
	bt_int_print_rec(n->left, depth + 1);
	bt_int_print_rec(n->right, depth + 1);
}

// Main public functions
binary_tree_int bt_int_new() {
	return (binary_tree_int) {0};
}
void bt_int_insert(binary_tree_int* bt, int val) {
	bt_int_insert_node_rec(&bt->root, val);
}
void bt_int_delete(binary_tree_int* bt, int val) {
	bt_int_delete_node_rec(&bt->root, val);
}
void bt_int_print(binary_tree_int* bt) {
	bt_int_print_rec(bt->root, 0);
}
