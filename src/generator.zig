const template = @import("template.zig");
const std = @import("std");
const known_folders = @import("knownfolders");

pub fn getGeneratorTemplatePath(alloc: std.mem.Allocator, generatorPath: []const u8) ![]u8 {
    const template_search_path_var = "GEN_TEMPLATE_PATH";
    const local_conf_path = try known_folders.getPath(alloc, .local_configuration);
    defer if (local_conf_path) |h| alloc.free(h);
    const path = path: {
        const template_search_path_val = std.process.getEnvVarOwned(alloc, template_search_path_var) catch {
            if (local_conf_path) |local|
                break :path try std.fs.path.join(alloc, &[_][]const u8{ local, "generics", generatorPath })
            else
                return error.no_output_path;
        };
        break :path try std.fs.realpathAlloc(alloc, try std.fs.path.join(alloc, &[_][]const u8{ template_search_path_val, generatorPath }));
    };
    return path;
}

fn runGenerator(alloc: std.mem.Allocator, _template: template.Template, genFile: []const u8, outdir: []const u8) !u8 {
    const template_search_path_var = "GEN_TEMPLATE_PATH";
    const local_conf_path = try known_folders.getPath(alloc, .local_configuration);
    defer if (local_conf_path) |h| alloc.free(h);

    const path = path: {
        const template_search_path_val = std.process.getEnvVarOwned(alloc, template_search_path_var) catch {
            if (local_conf_path) |local| break :path try std.fs.path.join(alloc, &[_][]const u8{ local, "generics", genFile }) else return 6;
        };
        break :path try std.fs.realpathAlloc(alloc, try std.fs.path.join(alloc, &[_][]const u8{ template_search_path_val, genFile }));
    };
    var file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.debug.print("Error: Failed to open path: {s}. Reason: {}\n", .{ path, err });
        return 1;
    };
    defer file.close();
    const stat = try file.stat();
    const contents = try file.readToEndAlloc(alloc, stat.size);
    var output_filepath = try std.fs.path.join(alloc, &[_][]const u8{ outdir, genFile });
    // 4a. remove tpl extension
    output_filepath = if (std.mem.lastIndexOf(u8, output_filepath, "tpl")) |idx| output_filepath[0..idx] else output_filepath;

    // 4b. add the datatype before the dot
    if (std.mem.lastIndexOfScalar(u8, output_filepath, '.')) |loc| {
        var result = try alloc.dupe(u8, _template.outformat);
        for (_template.args.items) |arg| {
            const old = arg.symbol.?;
            const new = try std.mem.replaceOwned(u8, alloc, arg.value.?, " ", "_");
            const temp = try std.mem.replaceOwned(u8, alloc, result, old, new);
            alloc.free(result);
            alloc.free(new);
            result = temp;
        }
        output_filepath = try std.fmt.allocPrint(alloc, "{s}/{s}.{s}", .{ outdir, result, output_filepath[loc + 1 .. loc + 2] });
    }

    std.debug.print("Begin generation of file: {s}\n", .{output_filepath});

    // 4c. create the final template string
    var result = try alloc.dupe(u8, contents);
    for (_template.args.items) |arg| {
        const old = arg.symbol.?;
        const old_w_hash = try std.fmt.allocPrint(alloc, "#{s}", .{old});
        const new_underscored = try std.mem.replaceOwned(u8, alloc, arg.value.?, " ", "_");
        const new = arg.value.?;

        const temp = try std.mem.replaceOwned(u8, alloc, result, old_w_hash, new);
        const temp2 = try std.mem.replaceOwned(u8, alloc, temp, old, new_underscored);

        alloc.free(result);
        alloc.free(new_underscored);
        alloc.free(old_w_hash);
        alloc.free(temp);
        result = temp2;
    }
    const outfile = std.fs.cwd().createFile(output_filepath, .{}) catch |err| {
        std.debug.print("Error: Failed to create {s}, as the path is not accessible\n", .{output_filepath});
        std.debug.print("       {}\n", .{err});
        return 7;
    };
    defer outfile.close();

    outfile.writeAll(result) catch |e| {
        std.debug.print("WriteError: {}\n", .{e});
    };

    defer alloc.free(result);
    defer alloc.free(output_filepath);
    return 0;
}

// NOTE: We need to populate the argument values based on what the user want to forward
//       I wonder if we can ask yazap to do some of the heavier lifting
pub fn forwardTemplateArgValues(dependency: template.Dependency, forwardFromTemplate: template.Template, forwardToTemplate: *template.Template) u8 {
    var it = dependency.forwardArgs.iterator();
    while (it.next()) |forwardArg| {
        if (forwardToTemplate.getArgMutByName(forwardArg.key_ptr.*)) |argp| {
            if (argp.value) |_| continue;
            if (std.mem.eql(u8, argp.name.?, forwardArg.key_ptr.*)) {
                argp.value = forwardFromTemplate.getArgMutByName(forwardArg.value_ptr.*).?.value;
            } else if (argp.def) |default| {
                argp.value = default;
            } else {
                std.debug.print("Error: No default for {?s}. Must supply --{?s}\n", .{ argp.name, argp.name });
                return 3;
            }
        }
    }
    return 0;
}

var generatedTemplates: ?std.StringHashMap(void) = null;

pub fn generateTemplate(alloc: std.mem.Allocator, _template: template.Template, available_templates: *const std.StringHashMap(template.Template), output_dir: []const u8) !void {
    if (generatedTemplates == null) {
        generatedTemplates = .init(alloc);
    }
    std.debug.print("Generating... {}\n", .{_template});
    for (_template.generators.items) |genFile| {
        // const path = getGeneratorTemplatePath(alloc, genFile);
        _ = runGenerator(alloc, _template, genFile, output_dir) catch |err| {
            std.debug.print("Error: {}\n", .{err});
        };
        try generatedTemplates.?.put(_template.name, {});
    }
    for (_template.deps.items) |dep| {
        if (generatedTemplates.?.contains(dep.name)) continue;

        if (available_templates.getPtr(dep.name)) |t| {
            std.debug.print("before forward => {}\n", .{t.*});
            _ = forwardTemplateArgValues(dep, _template, t);
            std.debug.print("forwarded => {}\n", .{t.*});
            try generateTemplate(alloc, t.*, available_templates, output_dir);
        } else {
            std.debug.print("Error: Dependency {s} not present\n", .{dep.name});
        }
    }
}
