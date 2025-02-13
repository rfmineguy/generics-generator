typedef struct ll_node_char {
	char val;
	ll_node_char *next, *prev;
} ll_node_char;

typedef struct {
	int size;
	struct ll_node_char *head, *tail;
} ll_char;

ll_char ll_char_new();
void ll_char_free(ll_char*);
void ll_char_pushback(ll_char*, char);
void ll_char_pushfront(ll_char*, char);
void ll_char_popback(ll_char*, char);
void ll_char_popfront(ll_char*, char);
char    ll_char_peekback(ll_char*);
char    ll_char_peekfront(ll_char*);
