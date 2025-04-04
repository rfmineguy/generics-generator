name = "queue"
generators = ["queue.htpl", "queue.ctpl"]
outformat = "queue_T"
[deps.linked_list]
datatype = "datatype-type"
free = "free"

[args.datatype-name]
symbol = "$T"

[args.datatype-type]
symbol = "@T"

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
