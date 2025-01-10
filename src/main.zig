const std = @import("std");
const yazap = @import("yazap");
const template = @import("template.zig");
const cmdline = @import("cmdline.zig");

const App = yazap.App;
const Allocator = std.mem.Allocator;

/// generics-generator
/// usage: generics-generator <tpl-subcommand> <args>
///
/// tpl:
///     dynamically populated based on
///     config dir
///
pub const known_folders_config = .{ .xdg_on_mac = true };
const alloc = std.heap.page_allocator;
pub fn main() anyerror!void {
    // 1. Create yazap app struct
    var app = App.init(alloc, "generics-gen", null);
    defer app.deinit();

    // 2. Populate yazap app with
    // commands parsed from the config
    // dir
    const files = try template.get_template_files(alloc);
    defer for (files.items) |file| alloc.free(file);
    for (files.items) |file| {
        const t = try template.Template.parse(alloc, file);
        const command = try cmdline.create_adt_command(&app, t);
        try app.rootCommand().addSubcommand(command);
    }

    // 3. Parse the app struct and
    // process the results
    const matches = try app.parseProcess();
    const subcmd = matches.parse_result.subcmd_parse_result;
    const name = subcmd.?.getCommand().deref().name;
    _ = name;
    var it = subcmd.?.getArgs().iterator();
    while (it.next()) |arg| {
        switch (arg.value_ptr.*) {
            .single => std.debug.print("arg single '{s}' is '{s}'\n", .{ arg.key_ptr.*, arg.value_ptr.*.single }),
            .many => std.debug.print("ERROR: arg type many for '{}' not suppored\n", .{arg.key_ptr}),
            .none => std.debug.print("ERROR: arg type none for '{}' not suppored\n", .{arg.key_ptr}),
        }
    }
}
