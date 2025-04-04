name = "stack"
generators = ["stack.htpl", "stack.ctpl"]
outformat = "stack_X"

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

[args.realloc]
symbol = "REALLOC"
default = "realloc"

[args.header]
symbol = "HEADER_INCLUDE"
default = "stdint.h"
