#ifndef HASH_TABLE_string_int_H
#define HASH_TABLE_string_int_H
#include <stdbool.h>

typedef struct ht_node_string_int {
	struct ht_node_string_int* next;
	const char* key;
	int val;
} ht_node_string_int;

typedef struct ht_string_int {
	struct ht_node_string_int* buckets[10];
	int bucket_count;
} ht_string_int;

ht_string_int ht_string_int_create();
void 			 	 ht_string_int_put(ht_string_int*, const char*, int);
void 			 	 ht_string_int_remove(ht_string_int*, const char*);
bool 				 ht_string_int_contains_key(ht_string_int*, const char*);
bool 				 ht_string_int_contains_val(ht_string_int*, int);
int* 		   ht_string_int_get(ht_string_int*, const char*);
void 				 ht_string_int_print(ht_string_int*);

#endif
