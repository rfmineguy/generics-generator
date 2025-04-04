#include "hash_table_string_int.h"
#include <stdio.h>
#include <string.h>

int ht_string_int_compare_key(const char* key1, const char* key2) {
	return strcmp(key1, key2);
}

int ht_string_int_compare_val(int val1, int val2) {
	return val1 == val2;
}

void ht_string_int_node_print(struct ht_node_string_int* node) {
	printf("%s : %d", node->key, node->val);
}

int ht_string_int_hash(const char* key, int max) {
	int hash = 0;
	for (int i = 0; i < strlen(key); i++) {
		hash += key[i] * 54 + 52;
	}
	return hash % max;
}
