const yazap = @import("yazap");
const Arg = yazap.Arg;

pub fn create_cmdline_args(app: *yazap.App) !void {
    var generics_gen = app.rootCommand();
    generics_gen.setProperty(.help_on_empty_args);

    var cmd_linked_list = app.createCommand("linked_list", "Create linked list");
    try cmd_linked_list.addArgs(&[_]Arg{Arg.singleValueOption("datatype", 'd', "Which datatype this linked list manages")});

    var cmd_binary_tree = app.createCommand("binary_tree", "Create linked list adt");
    try cmd_binary_tree.addArgs(&[_]Arg{Arg.singleValueOption("datatype", 'd', "The underlying data type")});

    try generics_gen.addSubcommand(cmd_linked_list);
    try generics_gen.addSubcommand(cmd_binary_tree);
}
