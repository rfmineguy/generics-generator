OUT_DIR   := out
GEN_FILES	:= src/generated/linked_list_int.c \
						 src/generated/linked_list_vec2.c \
						 src/generated/binary_tree_int.c \
						 src/generated/binary_tree_vec2.c \
						 src/generated/hash_table_string_int.c \
						 src/generated/vector_int.c \
						 src/generated/stack_int.c

TPL_OUTDIR:= src/generated
SOURCES   := src/main.c $(GEN_FILES)
BIN 		  := main

# Override the template search path to the local templates folder
export GEN_TEMPLATE_PATH=templates

.PHONY: template_gen
.PHONY: clean always build
always:
	mkdir -p $(OUT_DIR)
	mkdir -p $(TPL_OUTDIR)
clean:
	rm -r $(OUT_DIR)
	rm -r $(TPL_OUTDIR)
build: always template_gen $(OUT_DIR)/$(BIN)

$(OUT_DIR)/$(BIN): $(SOURCES)
	gcc $^ -o $@ -Isrc -Isrc/generated -ggdb

template_gen: $(GEN_FILES)
$(TPL_OUTDIR)/linked_list_int.c $(TPL_OUTDIR)/linked_list_int.h: templates/linked_list.tpl templates/linked_list.htpl templates/linked_list.ctpl
	generics-generator linked_list --datatype=int --outputdir=$(TPL_OUTDIR)

$(TPL_OUTDIR)/linked_list_vec2.c $(TPL_OUTDIR)/linked_list_vec2.h: templates/linked_list.tpl templates/linked_list.htpl templates/linked_list.ctpl
	generics-generator linked_list --datatype=vec2 --header="vec2.h" --outputdir=$(TPL_OUTDIR)

$(TPL_OUTDIR)/binary_tree_int.c $(TPL_OUTDIR)/binary_tree_int.h: templates/binary_tree.tpl templates/binary_tree.htpl templates/binary_tree.ctpl
	generics-generator binary_tree --datatype=int --outputdir=$(TPL_OUTDIR)

$(TPL_OUTDIR)/binary_tree_vec2.c $(TPL_OUTDIR)/binary_tree_vec2.h: templates/binary_tree.tpl templates/binary_tree.htpl templates/binary_tree.ctpl
	generics-generator binary_tree --datatype=vec2 --header="vec2.h" --outputdir=$(TPL_OUTDIR)

$(TPL_OUTDIR)/hash_table_string_int.c $(TPL_OUTDIR)/hash_table_string_int.h: templates/hash_table.tpl templates/hash_table.htpl templates/hash_table.ctpl
	generics-generator hash_table --key-name="string" --key-type="const char*" --val-name="int" --val-type="int" --outputdir=$(TPL_OUTDIR)

$(TPL_OUTDIR)/vector_int.c $(TPL_OUTDIR)/vector_int.h: templates/vector.tpl templates/vector.htpl templates/vector.ctpl
	generics-generator vector --datatype=int --outputdir=$(TPL_OUTDIR)

$(TPL_OUTDIR)/stack_int.c $(TPL_OUTDIR)/stack_int.h: templates/stack.tpl templates/stack.htpl templates/stack.ctpl
	generics-generator stack --datatype=int --outputdir=$(TPL_OUTDIR)
