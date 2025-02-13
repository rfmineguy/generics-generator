ll_char ll_char_new() {
	return (ll_char) {0};
}

void ll_char_free(ll_char* ll) {
	ll_node_char* n = ll->head;
	while (n) {
		ll_node_char* t = n;
		n = n->next;
			malloc_free(t);
	}
	ll->head = 0;
	ll->tail = 0;
}
