name = "hash_table"
generators = ["hash_table.htpl", "hash_table.ctpl"]
outformat = "hash_table_$KEY_$VAL"

[args.key-name]
symbol = "$KEY"

[args.key-type]
symbol = "^KEY"

[args.val-name]
symbol = "$VAL"

[args.val-type]
symbol = "^VAL"

[args.bucketcount]
symbol = "BUCKETCOUNT"
default = "10"

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
