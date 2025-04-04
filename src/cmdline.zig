const yazap = @import("yazap");
const template = @import("template.zig");
const Arg = yazap.Arg;
const std = @import("std");

pub fn create_adt_command(app: *yazap.App, t: template.Template, alloc: std.mem.Allocator) !yazap.Command {
    var command = app.createCommand(t.name, "Description");

    // Build up the extra data for the command (API WIP)
    for (t.deps.items) |dep| {
        try command.addExtra(try std.fmt.allocPrint(alloc,
            \\
            \\Dependency: {s}
        , .{dep.name}));
        var it = dep.forwardArgs.iterator();
        while (it.next()) |_dep| {
            try command.addExtra(try std.fmt.allocPrint(alloc,
                \\    Forwards '{s}' to '{s}'
            , .{ _dep.value_ptr.*, _dep.key_ptr.* }));
        }
    }

    // Setup the normal arguments
    for (t.args.items) |arg| {
        // NOTE: Memory leaks?
        const desc = if (arg.def) |d| try std.fmt.allocPrint(alloc, "default = {s}", .{d}) else "";
        try command.addArg(Arg.singleValueOption(arg.name.?, arg.name.?[0], desc));
    }

    try command.addArg(Arg.singleValueOption("outputdir", 'o', "default = ."));

    return command;
}
