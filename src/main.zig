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
    const subcmd = if (matches.parse_result.subcmd_parse_result) |result| result else {
        std.debug.print("Error: no arg provided\n", .{});
        try app.displayHelp();
        return 2;
    };
    const name = subcmd.getCommand().deref().name;
    const tplt = templates.get(name);
    const output_dir = if (subcmd.getArgs().get("outputdir")) |out| out.single else ".";
    for (tplt.?.args.items) |*arg| {
        // if we supplied the argument in question
        if (subcmd.getArgs().get(arg.name)) |subcmd_arg| {
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
    // std.debug.print("{?}\n", .{tplt});

    // 4. Use the data in tplt to do the replacements in the template files
    for (tplt.?.generators.items) |generator_file| {
        const template_search_path_var = "GEN_TEMPLATE_PATH";
        const local_conf_path = try known_folders.getPath(alloc, .local_configuration);
        defer if (local_conf_path) |h| alloc.free(h);

        const path = path: {
            const template_search_path_val = std.process.getEnvVarOwned(alloc, template_search_path_var) catch {
                if (local_conf_path) |local| break :path try std.fs.path.join(alloc, &[_][]const u8{ local, "generics", generator_file }) else return 6;
            };
            break :path try std.fs.realpathAlloc(alloc, try std.fs.path.join(alloc, &[_][]const u8{ template_search_path_val, generator_file }));
        };
        var file = std.fs.cwd().openFile(path, .{}) catch |err| {
            std.debug.print("File path doesn't exist: {s}. Error: {?}\n", .{ path, err });
            return 7;
        };
        defer file.close();
        const stat = try file.stat();
        const contents = try file.readToEndAlloc(alloc, stat.size);

        // perform replacements
        var output_filepath = try std.fs.path.join(alloc, &[_][]const u8{ output_dir, generator_file });

        // 4a. remove tpl extension
        output_filepath = if (std.mem.lastIndexOf(u8, output_filepath, "tpl")) |idx| output_filepath[0..idx] else output_filepath;

        // 4b. add the datatype before the dot
        if (std.mem.lastIndexOfScalar(u8, output_filepath, '.')) |loc| {
            var result = try alloc.dupe(u8, tplt.?.outformat);
            for (tplt.?.args.items) |arg| {
                const old = arg.symbol;
                const new = try std.mem.replaceOwned(u8, alloc, arg.value, " ", "_");
                const temp = try std.mem.replaceOwned(u8, alloc, result, old, new);
                alloc.free(result);
                alloc.free(new);
                result = temp;
            }
            output_filepath = try std.fmt.allocPrint(alloc, "{s}/{s}.{s}", .{ output_dir, result, output_filepath[loc + 1 .. loc + 2] });
        }

        // 4c. create the final template string
        var result = try alloc.dupe(u8, contents);
        for (tplt.?.args.items) |arg| {
            const old = arg.symbol;
            const old_w_hash = try std.fmt.allocPrint(alloc, "#{s}", .{old});
            const new_underscored = try std.mem.replaceOwned(u8, alloc, arg.value, " ", "_");
            const new = arg.value;

            const temp = try std.mem.replaceOwned(u8, alloc, result, old_w_hash, new);
            const temp2 = try std.mem.replaceOwned(u8, alloc, temp, old, new_underscored);

            alloc.free(result);
            alloc.free(new_underscored);
            alloc.free(old_w_hash);
            alloc.free(temp);
            result = temp2;
        }

        defer alloc.free(result);
        defer alloc.free(output_filepath);

        const outfile = std.fs.cwd().createFile(output_filepath, .{}) catch |err| {
            std.debug.print("Error: Failed to create {s}, as the path is not accessible\n", .{output_filepath});
            std.debug.print("       {}\n", .{err});
            continue;
        };
        defer outfile.close();

        outfile.writeAll(result) catch |e| {
            std.debug.print("WriteError: {}\n", .{e});
        };
    }
    return 0;
}
