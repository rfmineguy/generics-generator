#include <stdio.h>
#include "generated/linked_list_vec2.h"
#include "generated/linked_list_int.h"
#include "generated/binary_tree_vec2.h"
#include "generated/binary_tree_int.h"

int main() {
	printf("=======================\n");
	printf("   Linked list int\n");
	printf("=======================\n");
	ll_int ll = ll_int_new();
	ll_int_pushback(&ll, 4);
	ll_int_pushback(&ll, 9);
	ll_int_print(&ll);
	ll_int_free(&ll);


	printf("=======================\n");
	printf("   Linked list vec2\n");
	printf("=======================\n");
	ll_vec2 ll2 = ll_vec2_new();
	ll_vec2_pushback(&ll2, (vec2){.x=0,.y=0});
	ll_vec2_pushback(&ll2, (vec2){.x=5,.y=5});
	ll_vec2_print(&ll2);
	ll_vec2_free(&ll2);


	printf("=======================\n");
	printf("     Binary tree int\n");
	printf("=======================\n");
	binary_tree_int bt1 = bt_int_new();
	bt_int_insert(&bt1, 9);
	bt_int_insert(&bt1, 4);
	bt_int_insert(&bt1, 1);
	bt_int_insert(&bt1, 6);
	bt_int_insert(&bt1, 3);
	bt_int_insert(&bt1, 20);
	bt_int_print(&bt1);
	printf("-=-----=-\n");
	bt_int_delete(&bt1, 9);
	bt_int_print(&bt1);
	printf("-=-----=-\n");
	bt_int_delete(&bt1, 4);
	bt_int_print(&bt1);
	printf("-=-----=-\n");
	bt_int_delete(&bt1, 3);
	bt_int_print(&bt1);

	if (bt_int_find(&bt1, 3)) {
		printf("Found 4\n");
	}

	bt_int_free(&bt1);


	printf("=======================\n");
	printf("     Binary tree vec2\n");
	printf("=======================\n");
	binary_tree_vec2 bt2 = bt_vec2_new();
	bt_vec2_insert(&bt2, (vec2){0, 0});
	bt_vec2_insert(&bt2, (vec2){1, 1});
	bt_vec2_insert(&bt2, (vec2){3, 3});
	bt_vec2_insert(&bt2, (vec2){2, 2});
	bt_vec2_insert(&bt2, (vec2){4, 4});
	bt_vec2_insert(&bt2, (vec2){5, 5});
	bt_vec2_print(&bt2);
	printf("-=-----=-\n");
	bt_vec2_delete(&bt2, (vec2){0, 0});
	bt_vec2_print(&bt2);
	printf("-=-----=-\n");
	bt_vec2_delete(&bt2, (vec2){4, 4});
	bt_vec2_print(&bt2);
	printf("-=-----=-\n");
	bt_vec2_delete(&bt2, (vec2){5, 5});
	bt_vec2_print(&bt2);

	if (bt_vec2_find(&bt2, (vec2){1, 1})) {
		printf("Found {1,1}\n");
	}

	bt_vec2_free(&bt2);
}
