const std = @import("std");
const known_folders = @import("knownfolders");
const template = @import("template.zig");
const yazap = @import("yazap");
const cmdline = @import("cmdline.zig");
const generator = @import("generator.zig");

const App = yazap.App;
const Allocator = std.mem.Allocator;

/// generics-generator
/// usage: generics-generator <tpl-subcommand> <args>
///
/// tpl:
///     dynamically populated based on
///     config dir
///
pub const known_folders_config: known_folders.KnownFolderConfig = .{
    .xdg_on_mac = true,
};
const alloc = std.heap.page_allocator;
pub fn main() anyerror!u8 {

    // 1. Create yazap app struct
    var app = App.init(alloc, "generics-gen", "Generics generator");
    defer app.deinit();

    // 2. Populate yazap app with commands parsed from the config dir
    //    a. Retrieve template files based on the search path
    //    b. Generate yazap commands based on the retrieved template files
    var templates = std.StringHashMap(template.Template).init(alloc);
    const files = template.get_template_files(alloc) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return 4;
    };
    defer for (files.items) |file| {
        alloc.free(file.fullpath);
        alloc.free(file.name);
    };
    for (files.items) |file| {
        const t = template.Template.parse(alloc, file.fullpath) catch |err| {
            std.debug.print("Failed to parse '{s}.tpl': Reason: {any}\n", .{ file.name, err });
            return 0;
        };
        try templates.put(file.name, t);
        const cmd = try cmdline.create_adt_command(&app, t, alloc);
        try app.rootCommand().addSubcommand(cmd);
    }

    // 3. Cmdline parsing
    // Parse the app struct and
    // process the results into the final template values
    const matches = app.parseProcess() catch |e| {
        std.debug.print("Error: {}\n", .{e});
        return 1;
    };
    const subcmd = if (matches.parse_result.subcmd_parse_result) |result| result else {
        std.debug.print("Error: no arg provided\n", .{});
        try app.displayHelp();
        return 2;
    };
    // 4. Populate the argument values from yazap
    //      This is necessary due to supporting default values
    const name = subcmd.getCommand().deref().name;
    const tplt = templates.get(name);
    const output_dir = if (subcmd.getArgs().get("outputdir")) |out| out.single else ".";
    for (tplt.?.args.items) |*arg| {
        // if we supplied the argument in question
        if (subcmd.getArgs().get(arg.name.?)) |subcmd_arg| {
            arg.value = subcmd_arg.single;
        } else {
            if (arg.def) |default| {
                arg.value = default;
            } else {
                std.debug.print("Error: No default for {?s}. Must supply --{?s}\n", .{ arg.name, arg.name });
                return 3;
            }
        }
    }
    std.debug.print("Selected template\n", .{});

    // 4. Use the data in tplt to do the replacements in the template files
    //   NOTE: This should be abstracted to support the dependency generation
    try generator.generateTemplate(alloc, tplt.?, &templates, output_dir);
    return 0;
}
