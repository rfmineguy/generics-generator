const std = @import("std");
const template = @import("template.zig");
const yazap = @import("yazap");
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
    var app = App.init(alloc, "generics-gen", "Generics generator");
    defer app.deinit();

    // 2. Cmdline setup
    // Populate yazap app with
    // commands parsed from the config
    // dir
    var templates = std.StringHashMap(template.Template).init(alloc);
    const files = try template.get_template_files(alloc);
    defer for (files.items) |file| {
        alloc.free(file.fullpath);
        alloc.free(file.name);
    };
    for (files.items) |file| {
        // std.debug.print("{}\n", .{file});
        const t = try template.Template.parse(alloc, file.fullpath);
        try templates.put(file.name, t);
        if (try cmdline.create_adt_command(&app, t, alloc)) |command| {
            try app.rootCommand().addSubcommand(command);
        }
    }

    // var it = templates.iterator();
    // while (it.next()) |entry| {
    //     std.debug.print("{s}, {?}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    // }

    // 3. Cmdline parsing
    // Parse the app struct and
    // process the results
    const matches = app.parseProcess() catch |e| {
        std.debug.print("Error: {}\n", .{e});
        std.process.exit(1);
    };
    const subcmd = matches.parse_result.subcmd_parse_result;
    const name = subcmd.?.getCommand().deref().name;
    const tplt = templates.get(name);
    for (tplt.?.args.items) |*arg| {
        // if we supplied the argument in question
        if (subcmd.?.getArgs().get(arg.name)) |subcmd_arg| {
            arg.value = subcmd_arg.single;
        } else {
            if (arg.def) |default| {
                arg.value = default;
            } else {
                std.debug.print("Error: No default for {s}. Must supply --{s}\n", .{ arg.name, arg.name });
                std.process.exit(1);
            }
        }
    }
    std.debug.print("{?}\n", .{tplt});
}
