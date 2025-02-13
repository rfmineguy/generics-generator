const std = @import("std");
const known_folders = @import("known-folders");
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
pub fn main() anyerror!u8 {
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
        const t = try template.Template.parse(alloc, file.fullpath);
        try templates.put(file.name, t);
        if (try cmdline.create_adt_command(&app, t, alloc)) |command| {
            try app.rootCommand().addSubcommand(command);
        }
    }

    // 3. Cmdline parsing
    // Parse the app struct and
    // process the results into the final template values
    const matches = app.parseProcess() catch |e| {
        std.debug.print("Error: {}\n", .{e});
        return 1;
    };
    const subcmd = matches.parse_result.subcmd_parse_result;
    const name = subcmd.?.getCommand().deref().name;
    const tplt = templates.get(name);
    const output_dir = if (subcmd.?.getArgs().get("outputdir")) |out| out.single else ".";
    for (tplt.?.args.items) |*arg| {
        // if we supplied the argument in question
        if (subcmd.?.getArgs().get(arg.name)) |subcmd_arg| {
            arg.value = subcmd_arg.single;
        } else {
            if (arg.def) |default| {
                arg.value = default;
            } else {
                std.debug.print("Error: No default for {s}. Must supply --{s}\n", .{ arg.name, arg.name });
                return 3;
            }
        }
    }
    std.debug.print("{?}\n", .{tplt});

    // 4. Use the data in tplt to do the replacements in the template files
    for (tplt.?.generators.items) |generator_file| {
        const home = try known_folders.getPath(alloc, .local_configuration) orelse "";
        const path = try std.fs.path.join(alloc, &[_][]const u8{ home, "generics", generator_file });
        var file = try std.fs.cwd().openFile(path, .{});
        defer file.close();
        const stat = try file.stat();
        const contents = try file.readToEndAlloc(alloc, stat.size);
        std.debug.print("{s}\n", .{path});
        std.debug.print("{s}\n", .{contents});

        // 5. perform replacements
        var result = try alloc.dupe(u8, contents);
        for (tplt.?.args.items) |arg| {
            const old = arg.symbol;
            const new = arg.value;
            const temp = try std.mem.replaceOwned(u8, alloc, result, old, new);
            alloc.free(result);
            result = temp;
        }

        std.debug.print("Result: {s}\n", .{result});
        alloc.free(result);

        std.debug.print("Outputdir: {s}\n", .{output_dir});
    }
    return 0;
}
