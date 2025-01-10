const std = @import("std");
const yazap = @import("yazap");
const template = @import("template.zig");
const cmdline = @import("cmdline.zig");

const App = yazap.App;
const Allocator = std.mem.Allocator;

/// generics-generator
/// usage: generics-generator --tpl=<tpl> <args>
///
/// tpl:
///     dynamically populated based on
///     config dir
///
pub const known_folders_config = .{ .xdg_on_mac = true };

pub fn main() anyerror!void {
    const alloc = std.heap.page_allocator;
    const files = try template.get_template_files(alloc);
    defer for (files.items) |file| alloc.free(file);
    for (files.items) |file| {
        const t = try template.Template.parse(alloc, file);
        std.debug.print("{}\n", .{t});
    }

    var app = App.init(alloc, "generics-gen", null);
    defer app.deinit();

    try cmdline.create_cmdline_args(&app);

    const matches = try app.parseProcess();
    _ = matches;
}
