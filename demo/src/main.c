#include <stdio.h>
#include "generated/linked_list_vec2.h"
#include "generated/linked_list_int.h"
#include "generated/binary_tree_int.h"

int main() {
	printf("=======================\n");
	printf("   Linked list int\n");
	printf("=======================\n");
	ll_int ll = ll_int_new();
	ll_int_pushback(&ll, 4);
	ll_int_pushback(&ll, 9);
	ll_int_print(&ll);


	printf("=======================\n");
	printf("   Linked list vec2\n");
	printf("=======================\n");
	ll_vec2 ll2 = ll_vec2_new();
	ll_vec2_pushback(&ll2, (vec2){.x=0,.y=0});
	ll_vec2_pushback(&ll2, (vec2){.x=5,.y=5});
	ll_vec2_print(&ll2);


	printf("=======================\n");
	printf("     Binary tree\n");
	printf("=======================\n");
	binary_tree_int bt = bt_int_new();
	bt_int_insert(&bt, 4);
	bt_int_insert(&bt, 2);
	bt_int_insert(&bt, 1);
	bt_int_insert(&bt, 6);
	bt_int_print(&bt);
}
