```c++ linked_list_T.h
#ifndef LINKED_LIST_<T>_H
#define LINKED_LIST_<T>_H

typedef struct {
    int size;
    struct ll<T> *head, *tail;
} ll<T>;

typedef struct ll_node<T> {
    T val;
    struct ll_node<T> *next, *prev;
} ll_node<T>;

void ll_T_free(ll<T>*);
void ll_T_push_back(ll<T>*, T);
void ll_T_pop_back(ll<T>*);
void ll_T_push_front(ll<T>*, T);
void ll_T_pop_front(ll<T>*);
bool ll_T_contains(ll<T>*, T);
bool ll_T_cmp(T, T);
void ll_T_print(T);

#endif
```

```c++ linked_list_T.c
#include "linked_list_T.h"
#include <stdlib.h>
#define CALLOC calloc

void ll_free<T>(ll<T>* ll) {
    ll_node<T> *n = list->head;
    while (n) {
        ll_node<T> *t = n;
        n = n->next;
        free(t);
    }
    list->head = 0;
    list->tail = 0;
}
void ll_push_back<T>(ll<T>* ll, T v) {
    if (list->head == NULL || list->tail == NULL) {
        list->head = CALLOC(1, sizeof(ll_node<T>));
        list->tail = list->head;
        list->head->val = val;
    }
    else {
        ll_node<T> *n = CALLOC(1, sizeof(ll_node<T>));
        n->val = val;
        list->tail->next = n;
        n->prev = list->tail;
        list->tail = n;
    }
}
void ll_T_pop_back(ll_T*);
void ll_T_push_front(ll_T*, T);
void ll_T_pop_front(ll_T*);
bool ll_T_contains(ll_T*, T);
bool ll_T_cmp(T, T);
void ll_T_print(T);
```
