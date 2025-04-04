#include "binary_tree_vec2.h"
#include "binary_tree_vec2_spec.c"
#include <stdlib.h>
#include <stdio.h>

/**
 *    User is required to implement a few select functions in their own spec file
 *    	- bt_vec2_compare(vec2, vec2)
 *    		+ return 0 on equal
 *    		+ return -1 on less
 *    		+ return 1 on greater
 *    	- bt_vec2_node_print(vec2)
 *    		+ you decide how to print the node data
 */

int bt_vec2_compare(vec2, vec2);
void bt_vec2_node_print(vec2);

// Helper functions
void bt_vec2_insert_node_rec(binary_tree_node_vec2** n, vec2 val) {
	if (!(*n)) {
		(*n) = calloc(1, sizeof(binary_tree_node_vec2));
		(*n)->val = val;
		return;
	}
	if ((*n) && bt_vec2_compare(val, (*n)->val) < 0) bt_vec2_insert_node_rec(&(*n)->left, val);
	if ((*n) && bt_vec2_compare(val, (*n)->val) >= 0) bt_vec2_insert_node_rec(&(*n)->right, val);
}

binary_tree_node_vec2** bt_vec2_get_largest_rec(binary_tree_node_vec2** n) {
	binary_tree_node_vec2** largest = n;
	while ((*largest) && (*largest)->right) largest = &(*largest)->right;
	return largest;
}

void bt_vec2_delete_node_rec(binary_tree_node_vec2** n, vec2 val) {
	if (!(*n)) {
		return;
	}
	if (bt_vec2_compare((*n)->val, val) == 0) {
		// check node type
		if (!(*n)->left && !(*n)->right) {
			// leaf node
			free(*n);
			(*n) = 0;
			return;
		}
		if (!(*n)->left && (*n)->right) {
			// has right, no left
			binary_tree_node_vec2** largest = bt_vec2_get_largest_rec(&(*n)->right);
			(*n)->val = (*largest)->val;
			free(*largest);
			*largest = 0;
			return;
		}
		if (!(*n)->right && (*n)->left) {
			// has left, no right
			binary_tree_node_vec2** largest = bt_vec2_get_largest_rec(&(*n)->left);
			(*n)->val = (*largest)->val;
			free(*largest);
			*largest = 0;
			return;
		}
		if ((*n)->left && (*n)->right) {
			// has left and right
			binary_tree_node_vec2** largest = bt_vec2_get_largest_rec(&(*n)->left);
			(*n)->val = (*largest)->val;
			free(*largest);
			*largest = 0;
			return;
		}
	}
	if (bt_vec2_compare((*n)->val, val) < 0) {
		bt_vec2_delete_node_rec(&(*n)->right, val);
	}
	else {
		bt_vec2_delete_node_rec(&(*n)->left, val);
	}
}

void bt_vec2_print_rec(binary_tree_node_vec2* n, int depth) {
	if (!n) {
		printf("%*.c\\_ NULL\n", depth * 3, ' '); 
		return;
	}
	printf("%*.c\\_ ", depth * 3, ' '); bt_vec2_node_print(n->val); printf("\n");
	bt_vec2_print_rec(n->left, depth + 1);
	bt_vec2_print_rec(n->right, depth + 1);
}

void bt_vec2_free_node(binary_tree_node_vec2* node) {
	if (node == 0) return;
	bt_vec2_free_node(node->left);
	bt_vec2_free_node(node->right);
	free(node);
}

binary_tree_node_vec2* bt_vec2_find_by_val(binary_tree_node_vec2* n, vec2 val) {
	if (n == (void*)0) return (void*)0;
	if (bt_vec2_compare(n->val, val) == 0) {
		return n;
	}
	if (bt_vec2_compare(n->val, val) < 0) return bt_vec2_find_by_val(n->left, val);
	return bt_vec2_find_by_val(n->right, val);
}

// Main public functions
binary_tree_vec2 bt_vec2_new() {
	return (binary_tree_vec2) {0};
}
void bt_vec2_insert(binary_tree_vec2* bt, vec2 val) {
	bt_vec2_insert_node_rec(&bt->root, val);
}
void bt_vec2_delete(binary_tree_vec2* bt, vec2 val) {
	bt_vec2_delete_node_rec(&bt->root, val);
}
binary_tree_node_vec2* bt_vec2_find(binary_tree_vec2* bt, vec2 val) {
	return bt_vec2_find_by_val(bt->root, val);
}
void bt_vec2_print(binary_tree_vec2* bt) {
	bt_vec2_print_rec(bt->root, 0);
}
void bt_vec2_free(binary_tree_vec2* bt) {
	bt_vec2_free_node(bt->root);
}
