name = "binary_tree"
generators = ["binary_tree.htpl", "binary_tree.ctpl"]
outformat = "binary_tree_X"

[args.datatype]
symbol = "X"

[args.free]
symbol = "FREE"
default = "free"

[args.print]
symbol = "PRINT"
default = "printf"

[args.calloc]
symbol = "CALLOC"
default = "calloc"

[args.header]
symbol = "HEADER_INCLUDE"
default = "stdint.h"
