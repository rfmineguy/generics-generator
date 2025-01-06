const std = @import("std");
const yazap = @import("yazap");
const toml = @import("toml-zig");

const alloc = std.heap.page_allocator;
const App = yazap.App;
const Arg = yazap.Arg;

/// generics-generator
/// usage: generics-generator <adt> <args>
///
/// adt:
///     linked_list
///     binary_tree
///     max_heap
///     min_heap
///
///
///
pub fn main() anyerror!void {
    var app = App.init(alloc, "generics-gen", null);
    defer app.deinit();

    var generics_gen = app.rootCommand();
    generics_gen.setProperty(.help_on_empty_args);

    var cmd_linked_list = app.createCommand("linked_list", "Create linked list");
    try cmd_linked_list.addArgs(&[_]Arg{Arg.singleValueOption("datatype", 'd', "Which datatype this linked list manages")});

    var cmd_binary_tree = app.createCommand("binary_tree", "Create linked list adt");
    try cmd_binary_tree.addArgs(&[_]Arg{Arg.singleValueOption("datatype", 'd', "The underlying data type")});

    try generics_gen.addSubcommand(cmd_linked_list);
    try generics_gen.addSubcommand(cmd_binary_tree);

    const matches = try app.parseProcess();
    if (matches.subcommandMatches("linked_list")) |llist| {
        if (llist.getSingleValue("datatype")) |arg| {
            std.debug.print("Datatype: {s}", .{arg});
        }
    }
    if (matches.subcommandMatches("binary_tree")) |llist| {
        if (llist.getSingleValue("datatype")) |arg| {
            std.debug.print("Datatype: {s}", .{arg});
        }
    }
}
