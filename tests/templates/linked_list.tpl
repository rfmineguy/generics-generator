name = "linked_list"
generators = ["linked_list.htpl", "linked_list.ctpl"]
outformat = "linked_list_T"

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

[args.header]
symbol = "HEADER_INCLUDE"
default = "stdint.h"
