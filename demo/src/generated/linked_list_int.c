#include "linked_list_int.h"
#include "linked_list_support_int.c"
#include <stddef.h>
#include <stdlib.h>

ll_int ll_int_new() {
	return (ll_int) {0};
}

void ll_int_free(ll_int* ll) {
	ll_node_int* n = ll->head;
	while (n) {
		ll_node_int* t = n;
		n = n->next;
			free(t);
	}
	ll->head = 0;
	ll->tail = 0;
}

void ll_int_pushback(ll_int* ll, int val) {
	if (ll->head == NULL || ll->tail == NULL) {
		ll->head = calloc(1, sizeof(ll_node_int));
		ll->tail = ll->head;
		ll->head->val = val;
	}
	else {
		ll_node_int* n = calloc(1, sizeof(ll_node_int));
		n->val = val;
		ll->tail->next = n;
		n->prev = ll->tail;
		ll->tail = n;
	}
}

void ll_int_pushfront(ll_int* ll, int val) {
	if (ll->head == NULL || ll->tail == NULL) {
		ll->head = calloc(1, sizeof(ll_node_int));
		ll->tail = ll->head;
		ll->head->val = val;
	}
	else {
		ll_node_int* n = calloc(1, sizeof(ll_node_int));
		n->val = val;
		ll->head->prev = n;
		n->next = ll->head;
		ll->head = n;
	}
}

void ll_int_popback(ll_int* ll, int val) {
	ll_node_int* n = ll->tail;
	if (!n) return;
	ll->tail = ll->tail->prev;
	ll->tail->next = 0;
	free(n);
}

void ll_int_popfront(ll_int* ll, int val) {
	ll_node_int* n = ll->head;
	if (!n) return;
	ll->head = ll->head->next;
	ll->head->prev = 0;
	free(n);
}

void ll_int_delete(ll_int* ll, int val) {
	ll_node_int* n = ll->head;
	while (n && ll_int_cmp(n->val, val) != 0) n = n->next;
	if (n) {
		n->prev->next = n->next;
		free(n);
	}
}

void ll_int_print(ll_int* ll) {
	ll_node_int* n = ll->head;
	while (n) {
		ll_int_node_print(n->val);
		printf(" -> ");
		n = n->next;
	}
	printf("\n");
}
