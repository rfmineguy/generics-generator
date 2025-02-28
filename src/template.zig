const std = @import("std");
const yazap = @import("yazap");
const known_folders = @import("known-folders");
const toml = @import("zig_toml");
const Allocator = std.mem.Allocator;

const ArgType = enum { symbol, def };
const Arg = struct {
    name: ?[]const u8 = null,
    symbol: ?[]const u8 = null,
    def: ?[]const u8 = null,
    value: ?[]const u8 = null,

    pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("   {?s} {{", .{self.name});
        try writer.print("symbol = {?s}, ", .{self.symbol});
        try writer.print("default = {?s}, ", .{self.def});
        try writer.print("value = {?s}, ", .{self.value});
        try writer.print("}}\n", .{});
    }
};

pub const TemplateParseError = error{
    toml_parse_error,

    // Name errors
    name_malformed,
    name_missing,
    // generator array errors
    generators_array_malformed,
    generators_array_missing,
    // outformat errors
    outformat_malformed,
    outformat_missing,
    // args table malformed
    args_table_malformed,
    args_table_missing,
    // arg entry malformed
    arg_malformed,
    arg_symbol_missing,
};

// represents <adt>.tpl
pub const Template = struct {
    name: ?[]u8 = null,
    generators: std.ArrayList([]const u8) = undefined,
    args: std.ArrayList(Arg) = undefined,
    outformat: []const u8 = undefined,

    pub fn parse(alloc: Allocator, path: []const u8) !@This() {
        var parser = try toml.parseFile(alloc, path);
        defer parser.deinit();

        var table = try parser.parse();
        defer table.deinit();

        var ret = @This(){};
        ret.args = std.ArrayList(Arg).init(alloc);

        // Parse the template name field
        if (table.keys.get("name")) |name| {
            if (name != .String) return error.name_malformed;
            ret.name = try alloc.dupe(u8, name.String);
        } else {
            return error.name_missing;
        }
        if (table.keys.get("generators")) |generators| {
            if (generators != .Array) return error.generators_array_malformed;
            ret.generators = std.ArrayList([]const u8).init(alloc);
            for (generators.Array.items) |file| {
                if (file != .String) continue;
                const t = try alloc.dupe(u8, file.String);
                try ret.generators.append(t);
            }
        } else {
            return error.generators_array_missing;
        }
        if (table.keys.get("outformat")) |outformat| {
            if (outformat != .String) return error.outformat_malformed;
            ret.outformat = try alloc.dupe(u8, outformat.String);
        } else {
            return error.outformat_missing;
        }
        if (table.keys.get("args")) |arg| {
            if (arg != .Table) return error.args_table_malformed;
            var args_it = arg.Table.keys.iterator();
            while (args_it.next()) |entry| {
                if (entry.value_ptr.* != .Table) return error.arg_malformed;
                const arg_entry_table = entry.value_ptr.Table;
                var arg_entry_it = arg_entry_table.keys.iterator();
                var argument: Arg = .{};
                argument.name = try alloc.dupe(u8, entry.key_ptr.*);
                while (arg_entry_it.next()) |arg_entry| {
                    if (arg_entry.value_ptr.* != .String) return error.arg_malformed;
                    if (std.mem.eql(u8, arg_entry.key_ptr.*, "symbol")) {
                        argument.symbol = try alloc.dupe(u8, arg_entry.value_ptr.String);
                    }
                    if (std.mem.eql(u8, arg_entry.key_ptr.*, "default")) {
                        argument.def = try alloc.dupe(u8, arg_entry.value_ptr.String);
                    }
                }

                if (argument.symbol) |_| {} else {
                    return error.arg_symbol_missing;
                }
                try ret.args.append(argument);
            }
        }
        return ret;
    }

    pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("Template(\n", .{});
        try writer.print("  name: {?s},\n", .{self.name});
        try writer.print("  args: [\n", .{});
        for (self.args.items) |arg| {
            try writer.print("{}", .{arg});
        }
        try writer.print("  ]\n", .{});
        try writer.print("  generators: [", .{});
        for (self.generators.items) |generator| try writer.print("{s},", .{generator});
        try writer.print("]\n", .{});
        try writer.print("  outformat: {s},\n", .{self.outformat});
        try writer.print(")\n", .{});
    }
};

pub const TemplateFile = struct {
    fullpath: []const u8,
    name: []const u8,
};

pub fn get_template_files(alloc: std.mem.Allocator) !std.ArrayList(TemplateFile) {
    const template_search_path_var = "GEN_TEMPLATE_PATH";
    const local_conf_path = try known_folders.getPath(alloc, .local_configuration);
    // const default_search_path = try std.fs.path.join(alloc, &[_][]const u8{ local_conf_path, "generics" });
    defer if (local_conf_path) |h| alloc.free(h);
    // defer alloc.free(default_search_path);

    const path = path: {
        const template_search_path_val = std.process.getEnvVarOwned(alloc, template_search_path_var) catch {
            if (local_conf_path) |local| break :path try std.fs.path.join(alloc, &[_][]const u8{ local, "generics" }) else break :path null;
        };
        break :path try std.fs.realpathAlloc(alloc, template_search_path_val);
    };

    // std.debug.print("Searching: {?s}\n", .{path.?});

    var dir = std.fs.cwd().openDir(path.?, .{ .iterate = true }) catch |err| {
        std.debug.print("Search path doesnt exist: {s}. Error: {?}\n", .{ path.?, err });
        std.process.exit(5);
    };
    defer dir.close();

    var walker = dir.iterate();

    var filepaths = std.ArrayList(TemplateFile).init(alloc);
    while (try walker.next()) |entry| {
        if (entry.kind != .file) continue;
        const extension = std.fs.path.extension(entry.name);
        if (std.mem.eql(u8, extension, ".tpl")) {
            var basename = try alloc.dupe(u8, std.fs.path.basename(entry.name));
            try filepaths.append(.{
                .fullpath = try dir.realpathAlloc(alloc, entry.name),
                .name = if (std.mem.lastIndexOfScalar(u8, basename, '.')) |idx| basename[0..idx] else basename,
            });
        }
    }
    return filepaths;
}

// =====================
// TESTS FROM HERE BELOW
// =====================
const expect = std.testing.expect;

test "template parse 1" {}
