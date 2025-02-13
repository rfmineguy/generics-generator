const std = @import("std");
const yazap = @import("yazap");
const known_folders = @import("known-folders");
const toml = @import("zig_toml");
const Allocator = std.mem.Allocator;

const ArgType = enum { symbol, def };
const Arg = struct {
    name: []const u8 = undefined,
    symbol: []const u8 = undefined,
    def: ?[]const u8 = null,
    value: []const u8 = undefined,

    pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("   {s} {{", .{self.name});
        try writer.print("symbol = {?s}, ", .{self.symbol});
        try writer.print("default = {?s}, ", .{self.def});
        try writer.print("value = {?s}, ", .{self.value});
        try writer.print("}}", .{});
    }
};

// represents <adt>.tpl
pub const Template = struct {
    name: ?[]u8 = null,
    generators: std.ArrayList([]const u8) = undefined,
    args: std.ArrayList(Arg) = undefined,

    pub fn parse(alloc: Allocator, path: []const u8) !@This() {
        var parser = try toml.parseFile(alloc, path);
        defer parser.deinit();

        var table = try parser.parse();
        defer table.deinit();

        var ret = @This(){};
        ret.args = std.ArrayList(Arg).init(alloc);
        if (table.keys.get("name")) |name| {
            if (name != .String) return error.malformed_name;
            ret.name = try alloc.dupe(u8, name.String);
        }
        if (table.keys.get("generators")) |generators| {
            if (generators != .Array) return error.malformed_generators_array;
            ret.generators = std.ArrayList([]const u8).init(alloc);
            for (generators.Array.items) |file| {
                if (file != .String) continue;
                const t = try alloc.dupe(u8, file.String);
                try ret.generators.append(t);
            }
        }
        if (table.keys.get("args")) |arg| {
            if (arg != .Table) return error.malformed_args_table;
            var args_it = arg.Table.keys.iterator();
            while (args_it.next()) |entry| {
                if (entry.value_ptr.* != .Table) return error.malformed_arg;
                const arg_entry_table = entry.value_ptr.Table;
                var arg_entry_it = arg_entry_table.keys.iterator();
                var argument: Arg = .{};
                argument.name = try alloc.dupe(u8, entry.key_ptr.*);
                while (arg_entry_it.next()) |arg_entry| {
                    if (arg_entry.value_ptr.* != .String) return error.malformed_arg;
                    if (std.mem.eql(u8, arg_entry.key_ptr.*, "symbol"))
                        argument.symbol = try alloc.dupe(u8, arg_entry.value_ptr.String);
                    if (std.mem.eql(u8, arg_entry.key_ptr.*, "default"))
                        argument.def = try alloc.dupe(u8, arg_entry.value_ptr.String);
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
        for (self.generators.items) |generator| try writer.print("{s}, ", .{generator});
        try writer.print("]\n", .{});
        try writer.print(")\n", .{});
    }
};

pub const TemplateFile = struct {
    fullpath: []const u8,
    name: []const u8,
};

pub fn get_template_files(alloc: std.mem.Allocator) !std.ArrayList(TemplateFile) {
    const home = try known_folders.getPath(alloc, .local_configuration) orelse "";
    const path = try std.fs.path.join(alloc, &[_][]const u8{ home, "generics" });
    std.fs.cwd().makeDir(path) catch {};

    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();

    var walker = try dir.walk(alloc);
    defer walker.deinit();

    var filepaths = std.ArrayList(TemplateFile).init(alloc);
    while (try walker.next()) |entry| {
        if (entry.kind != .file) continue;
        const extension = std.fs.path.extension(entry.path);
        if (std.mem.eql(u8, extension, ".tpl")) {
            var basename = try alloc.dupe(u8, std.fs.path.basename(entry.path));
            try filepaths.append(.{
                .fullpath = try dir.realpathAlloc(alloc, entry.path),
                .name = if (std.mem.lastIndexOfScalar(u8, basename, '.')) |idx| basename[0..idx] else basename,
            });
        }
    }
    return filepaths;
}
