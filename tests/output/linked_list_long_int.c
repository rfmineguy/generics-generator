#include "linked_list_long_int.h"
#include "linked_list_support_long_int.c"
#include <stddef.h>
#include <stdlib.h>

ll_long_int ll_long_int_new() {
	return (ll_long_int) {0};
}

void ll_long_int_free(ll_long_int* ll) {
	ll_node_long_int* n = ll->head;
	while (n) {
		ll_node_long_int* t = n;
		n = n->next;
			free(t);
	}
	ll->head = 0;
	ll->tail = 0;
}

void ll_long_int_pushback(ll_long_int* ll, long int val) {
	if (ll->head == NULL || ll->tail == NULL) {
		ll->head = calloc(1, sizeof(ll_node_long_int));
		ll->tail = ll->head;
		ll->head->val = val;
	}
	else {
		ll_node_long_int* n = calloc(1, sizeof(ll_node_long_int));
		n->val = val;
		ll->tail->next = n;
		n->prev = ll->tail;
		ll->tail = n;
	}
}

void ll_long_int_pushfront(ll_long_int* ll, long int val) {
	if (ll->head == NULL || ll->tail == NULL) {
		ll->head = calloc(1, sizeof(ll_node_long_int));
		ll->tail = ll->head;
		ll->head->val = val;
	}
	else {
		ll_node_long_int* n = calloc(1, sizeof(ll_node_long_int));
		n->val = val;
		ll->head->prev = n;
		n->next = ll->head;
		ll->head = n;
	}
}

void ll_long_int_popback(ll_long_int* ll, long int val) {
	ll_node_long_int* n = ll->tail;
	if (!n) return;
	ll->tail = ll->tail->prev;
	ll->tail->next = 0;
	free(n);
}

void ll_long_int_popfront(ll_long_int* ll, long int val) {
	ll_node_long_int* n = ll->head;
	if (!n) return;
	ll->head = ll->head->next;
	ll->head->prev = 0;
	free(n);
}

void ll_long_int_print(ll_long_int* ll) {
	ll_node_long_int* n = ll->head;
	while (n) {
		ll_long_int_node_print(n->val);
		printf(" -> ");
		n = n->next;
	}
	printf("\n");
}
