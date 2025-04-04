name = "vector"
generators = ["vector.htpl", "vector.ctpl"]
outformat = "vector_T"

[args.datatype]
symbol = "T"

[args.free]
symbol = "FREE"
default = "free"

[args.print]
symbol = "PRINT"
default = "printf"

[args.calloc]
symbol = "CALLOC"
default = "calloc"

[args.realloc]
symbol = "REALLOC"
default = "realloc"

[args.header]
symbol = "HEADER_INCLUDE"
default = "stdint.h"

