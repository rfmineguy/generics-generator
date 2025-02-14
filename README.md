# Generics Generator
This library solves the problem of C not having C++ style template support built in.

## How?
Generics Generator introduces the concept of a template file and generator files.

## Template File
The template file represents the root of all templates. It specifies the name of the template, the generator files of the template, and the parameters to the template.

Example:
```toml
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
```

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
The default search path for template files is in the system's local configuration dir.
`Linux: ~/.config/generics/`
`MacOS: ~/.config/generics/`
`Windows: %USERPROFILE%\AppData\Local\generics`

Generics Generator will look in this directory to determine what the available templates are, and will generate a special help menu for each template in that directory.

An example of what one might look like is:
```sh
$ generics-generator --help
Generics generator

Usage: generics-gen [COMMAND]

Commands:
    linked_list
```

```sh
Usage: generics-gen linked_list [OPTIONS]

Options:
    -f, --free=<free>                             default = free
    -p, --print=<print>                           default = printf
    -d, --datatype=<datatype>
    -o, --outputdir=<outputdir>                   default = .
    -h, --help                                    Print this help and exit
```
