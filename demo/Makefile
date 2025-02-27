OUT_DIR   := out
LL_GEN 		:= src/generated/linked_list_int.c \
						 src/generated/linked_list_vec2.c \
						 src/generated/binary_tree_int.c
SOURCES   := src/main.c $(LL_GEN)
BIN 		  := main

# Override the template search path to the local templates folder
export GEN_TEMPLATE_PATH=templates

.PHONY: template_gen
.PHONY: clean always build
always:
	mkdir -p $(OUT_DIR)
	mkdir -p src/generated
clean:
	rm -r $(OUT_DIR)
	rm -r $(LL_GEN)
build: always template_gen $(OUT_DIR)/$(BIN)

$(OUT_DIR)/$(BIN): $(SOURCES)
	gcc $^ -o $@ -Isrc

template_gen: $(LL_GEN)
src/generated/linked_list_int.c src/generated/linked_list_int.h: templates/linked_list.tpl templates/linked_list.htpl templates/linked_list.ctpl
	generics-generator linked_list --datatype=int --outputdir=src/generated

src/generated/linked_list_vec2.c src/generated/linked_list_vec2.h: templates/linked_list.tpl templates/linked_list.htpl templates/linked_list.ctpl
	generics-generator linked_list --datatype=vec2 --header="vec2.h" --outputdir=src/generated

src/generated/binary_tree_int.c src/generated/binary_tree_int.h: templates/binary_tree.tpl templates/binary_tree.htpl templates/binary_tree.ctpl
	generics-generator binary_tree --datatype=int --outputdir=src/generated
