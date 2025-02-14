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
typedef struct linked_list_T {
    T value;
    linked_list_T* next;
} linked_list_T;

void linked_list_T_push(T);
void linked_list_T_pop(T);
... etc
```

## Making Them Work
The default search path for template **and** generator files is in the system's local configuration dir.
- `Linux: ~/.config/generics/`
- `MacOS: ~/.config/generics/`
- `Windows: %USERPROFILE%\AppData\Local\generics`

Generics Generator will look in this directory to determine what the available templates are, and will generate a special help menu for each template in that directory.

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
