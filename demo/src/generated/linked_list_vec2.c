#include "linked_list_vec2.h"
#include "linked_list_support_vec2.c"
#include <stddef.h>
#include <stdlib.h>

ll_vec2 ll_vec2_new() {
	return (ll_vec2) {0};
}

void ll_vec2_free(ll_vec2* ll) {
	ll_node_vec2* n = ll->head;
	while (n) {
		ll_node_vec2* t = n;
		n = n->next;
			free(t);
	}
	ll->head = 0;
	ll->tail = 0;
}

void ll_vec2_pushback(ll_vec2* ll, vec2 val) {
	if (ll->head == NULL || ll->tail == NULL) {
		ll->head = calloc(1, sizeof(ll_node_vec2));
		ll->tail = ll->head;
		ll->head->val = val;
	}
	else {
		ll_node_vec2* n = calloc(1, sizeof(ll_node_vec2));
		n->val = val;
		ll->tail->next = n;
		n->prev = ll->tail;
		ll->tail = n;
	}
}

void ll_vec2_pushfront(ll_vec2* ll, vec2 val) {
	if (ll->head == NULL || ll->tail == NULL) {
		ll->head = calloc(1, sizeof(ll_node_vec2));
		ll->tail = ll->head;
		ll->head->val = val;
	}
	else {
		ll_node_vec2* n = calloc(1, sizeof(ll_node_vec2));
		n->val = val;
		ll->head->prev = n;
		n->next = ll->head;
		ll->head = n;
	}
}

void ll_vec2_popback(ll_vec2* ll, vec2 val) {
	ll_node_vec2* n = ll->tail;
	if (!n) return;
	ll->tail = ll->tail->prev;
	ll->tail->next = 0;
	free(n);
}

void ll_vec2_popfront(ll_vec2* ll, vec2 val) {
	ll_node_vec2* n = ll->head;
	if (!n) return;
	ll->head = ll->head->next;
	ll->head->prev = 0;
	free(n);
}

void ll_vec2_delete(ll_vec2* ll, vec2 val) {
	ll_node_vec2* n = ll->head;
	while (n && ll_vec2_cmp(n->val, val) != 0) n = n->next;
	if (n) {
		n->prev->next = n->next;
		free(n);
	}
}

void ll_vec2_print(ll_vec2* ll) {
	ll_node_vec2* n = ll->head;
	while (n) {
		ll_vec2_node_print(n->val);
		printf(" -> ");
		n = n->next;
	}
	printf("\n");
}
