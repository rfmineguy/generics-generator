# Generics Generator
This library solves the problem of C not having C++ style template support built in.

# How?
Generics Generator introduces the concept of a template file and generator files.

## Template File
The template file represents the root of all templates. It specifies the name of the template, the generator files of the template, and the parameters to the template.

### Generator Files
Generator files are the actual source code. They are just regular text files with your data structure's code in it. However when paired with the template file, you get some new features.

The main new feature is being able to use keywords as "find and replace" tokens.

Example:
```ctpl
typedef struct linked_list_T {
    T value;
    linked_list_T* next;
} linked_list_T;

void linked_list_T_push(T);
void linked_list_T_pop(T);
... etc
```
