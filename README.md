# Generics Generator
This library solves the problem of C not having C++ style template support built in.

## How?
Generics Generator introduces the concept of a template file and generator files.

## Building
```bash
$ git clone https://github.com/rfmineguy/generics-generator.git
$ sudo zig build install --prefix /usr/local
```

## Template File
The template file represents the root of all templates. It specifies the name of the template, the generator files of the template, and the parameters to the template.

Example:
```toml
name = "linked_list"
generators = ["linked_list.htpl", "linked_list.ctpl"]
outformat = "linked_list_T"

[args.datatype]     # a required argument (no default available)
symbol = "T"

[args.free]         # an optional argument (default supplied)
symbol = "FREE"
default = "free"

[args.print]        # an optional argument (default supplied)
symbol = "PRINT"
default = "printf"
```

### Explanation
- `name`        This field defines the name of the template in the cli
- `generators`  This field defines all the generators associated with the template
- `outformat`   This field defines the format of the files to be output
- `args`        A table representing the template parameters
    * `symbol`  The actual symbol that should be replaced with the supplied replacement
    * `default` An optional field that specifies the default replacement in the event that the argument is not given

## Generator Files
Generator files are the actual source code. They are just regular text files with your data structure's code in it. However when paired with the template file, you get some new features.

The main new feature is being able to use keywords as "find and replace" tokens.

Example:
```c
// This is the generator file
typedef struct ll_node_T {
	#T val;
	struct ll_node_T *next, *prev;
} ll_node_T;

typedef struct {
	int size;
	struct ll_node_T *head, *tail;
} ll_T;

void linked_list_T_push(ll_T*, #T);
void linked_list_T_pop(ll_T*, #T);
```

### Explanation
Notice we have two different symbols in here with the same name `T`. This is because the hash symbol causes the symbol to be replaced differently!<br>
<br>
When you use a symbol with no hash symbol, the it will be replaced with the supplied string with the spaces replaced with underscores.<br>
If you add a hash, the replacement will keep the spaces intact.<br>
<br>
For example if we ran Generics Generator as such.<br>
```bash
$ generics-generator linked_list --datatype="long double"
```
We would get
```c
// This is the generator file
typedef struct ll_node_long_double {
	long double val;
	struct ll_node_long_double *next, *prev;
} ll_node_long_double;

typedef struct {
	int size;
	struct ll_node_long_double *head, *tail;
} ll_long_double;

void linked_list_long_double_push(ll_long_double*, long double);
void linked_list_long_double_pop(ll_long_double*, long double);
```


## Making Them Work
The default search path for template **and** generator files is in the system's local configuration dir.
- `Linux: ~/.config/generics/`
- `MacOS: ~/.config/generics/`
- `Windows: %USERPROFILE%\AppData\Local\generics`

Generics Generator will look in this directory to determine what the available templates are, and will generate a special help menu for each template in that directory.
To override this default you can run the program as such
```bash
export GEN_TEMPLATE_PATH=.; generics-generator <args>
```

An example of what one might look like is:
```bash
$ generics-generator --help
Generics generator

Usage: generics-gen [COMMAND]

Commands:
    linked_list
```

```bash
$ generics-generator linked_list --help
Usage: generics-gen linked_list [OPTIONS]

Options:
    -f, --free=<free>                             default = free
    -p, --print=<print>                           default = printf
    -d, --datatype=<datatype>
    -o, --outputdir=<outputdir>                   default = .
    -h, --help                                    Print this help and exit
```

Each of the options here correspond to the `args` that we specified in the `.tpl` file earlier

# Samples
For template samples see `generator-files`
