const yazap = @import("yazap");
const template = @import("template.zig");
const Arg = yazap.Arg;
const std = @import("std");

pub fn create_adt_command(app: *yazap.App, t: template.Template, alloc: std.mem.Allocator) !yazap.Command {
    var command = app.createCommand(t.name, "");

    for (t.args.items) |arg| {
        // NOTE: Memory leaks?
        const desc = if (arg.def) |d| try std.fmt.allocPrint(alloc, "default = {s}", .{d}) else "";
        try command.addArg(Arg.singleValueOption(arg.name.?, arg.name.?[0], desc));
    }

    try command.addArg(Arg.singleValueOption("outputdir", 'o', "default = ."));

    return command;
}
