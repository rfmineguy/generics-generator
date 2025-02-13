const yazap = @import("yazap");
const template = @import("template.zig");
const Arg = yazap.Arg;
const std = @import("std");

pub fn create_adt_command(app: *yazap.App, t: template.Template, alloc: std.mem.Allocator) !?yazap.Command {
    var command = if (t.name) |name| app.createCommand(name, "") else return null;

    for (t.args.items) |arg| {
        // NOTE: Memory leaks?
        const desc = if (arg.def) |d| try std.fmt.allocPrint(alloc, "default = {s}", .{d}) else "";
        try command.addArg(Arg.singleValueOption(arg.name, arg.name[0], desc));
    }

    return command;
}

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
