#include "hash_table_string_int.h"
#include "hash_table_string_int_support.c"
#include <stdlib.h>
#include <stdio.h>

/**
 *    User is required to implement a few select functions in their own spec file
 *    	- ht_string_int_compare_key(KEY, KEY)
 *    		+ return 0 on equal
 *    		+ return -1 on less
 *    		+ return 1 on greater
 *    	- ht_string_int_compare_val(VAL, VAL)
 *    		+ return 0 on equal
 *    		+ return -1 on less
 *    		+ return 1 on greater
 *    	- ht_string_int_node_print(VAL)
 *    		+ you decide how to print the node data
 *    	- ht_string_int_hash(KEY)
 *    		+ you decide how to generate a hash for the key
 */

ht_string_int ht_string_int_create() {
	ht_string_int ht = {0};
	ht.bucket_count = 10;
	return ht;
}
void ht_string_int_put(ht_string_int* ht, const char* key, int val) {
	// generate hash and node
	int hash = ht_string_int_hash(key, ht->bucket_count);
	ht_node_string_int* node = calloc(1, sizeof(ht_node_string_int));
	node->key = key;
	node->val = val;

	// put the value into the right bucket
	if (ht->buckets[hash] == (void*)0) {
		ht->buckets[hash] = node;
		return;
	}
	else {
		ht_node_string_int* t = ht->buckets[hash];
		ht->buckets[hash] = node;
		node->next = t;
		return;
	}
}
void ht_string_int_remove(ht_string_int* ht, const char* key) {
	int hash = ht_string_int_hash(key, ht->bucket_count);
	if (ht->buckets[hash] == (void*)0) return;
	ht_node_string_int* prev = 0;
	ht_node_string_int* t = ht->buckets[hash];
	while (t && ht_string_int_compare_key(key, t->key) != 0) {
		prev = t;
		t = t->next;
	}
	if (t && prev) {
		prev->next = t->next;
		free(t);
	}
	if (t && !prev) {
		ht->buckets[hash] = t->next;
		free(t);
	}
}
bool ht_string_int_contains_key(ht_string_int* ht, const char* key) {
	int hash = ht_string_int_hash(key, ht->bucket_count);
	if (ht->buckets[hash] == (void*)0) return false;
	ht_node_string_int* n = ht->buckets[hash];
	while (n) {
		if (ht_string_int_compare_key(n->key, key) == 0) {
			return true;
		}
		n = n->next;
	}
	return false;
}
bool ht_string_int_contains_val(ht_string_int* ht, int val) {
	for (int i = 0; i < 10; i++) {
		if (!ht->buckets[i]) continue;
		ht_node_string_int* n = ht->buckets[i];
		while (n) {
			if (ht_string_int_compare_val(n->val, val) == 0) {
				return true;
			}
			n = n->next;
		}
	}
	return false;
}
int* ht_string_int_get(ht_string_int* ht, const char* key) {
	int hash = ht_string_int_hash(key, ht->bucket_count);
	if (ht->buckets[hash] == (void*)0) return false;
	ht_node_string_int* n = ht->buckets[hash];
	while (n) {
		if (ht_string_int_compare_key(n->key, key) == 0) {
			return &n->val;
		}
		n = n->next;
	}
	return (void*)0;
}
void ht_string_int_print(ht_string_int* ht) {
	for (int i = 0; i < 10; i++) {
		if (!ht->buckets[i]) continue;
		ht_node_string_int* n = ht->buckets[i];
		printf("%d  ::  ", i);
		while (n) {
			ht_string_int_node_print(n); printf(" -> ");
			n = n->next;
		}
		printf("\n");
	}
}
