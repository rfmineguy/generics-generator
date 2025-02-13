ll_int ll_int_new() {
	return (ll_int) {0};
}

void ll_int_free(ll_int* ll) {
	ll_node_int* n = ll->head;
	while (n) {
		ll_node_int* t = n;
		n = n->next;
			malloc_free(t);
	}
	ll->head = 0;
	ll->tail = 0;
}
