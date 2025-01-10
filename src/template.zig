const std = @import("std");
const yazap = @import("yazap");
const known_folders = @import("known-folders");
const toml = @import("zig_toml");
const Allocator = std.mem.Allocator;

// represents <adt>.tpl
pub const Template = struct {
    name: ?[]u8 = null,
    datatype: ?[]u8 = null,
    generators: std.ArrayList([]const u8) = undefined,

    pub fn parse(alloc: Allocator, path: []const u8) !@This() {
        var parser = try toml.parseFile(alloc, path);
        defer parser.deinit();

        var table = try parser.parse();
        defer table.deinit();

        var ret = @This(){};
        if (table.keys.get("name")) |name| {
            if (name != .String) return error.malformed_name;
            ret.name = try alloc.dupe(u8, name.String);
        }
        if (table.keys.get("datatype")) |datatype| {
            if (datatype != .String) return error.malformed_datatype;
            ret.datatype = try alloc.dupe(u8, datatype.String);
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
        return ret;
    }

    pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("Template(", .{});
        try writer.print("name: {?s}, ", .{self.name});
        try writer.print("datatype: {?s}, ", .{self.datatype});
        try writer.print("generators: [", .{});
        for (self.generators.items) |generator| try writer.print("{s}, ", .{generator});
        try writer.print("])", .{});
    }
};

pub fn get_template_files(alloc: std.mem.Allocator) !std.ArrayList([]u8) {
    const home = try known_folders.getPath(alloc, .local_configuration) orelse "";
    const path = try std.fs.path.join(alloc, &[_][]const u8{ home, "generics" });
    std.fs.cwd().makeDir(path) catch {};

    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();

    var walker = try dir.walk(alloc);
    defer walker.deinit();

    var filepaths = std.ArrayList([]u8).init(alloc);
    while (try walker.next()) |entry| {
        if (entry.kind != .file) continue;
        const extension = std.fs.path.extension(entry.path);
        if (std.mem.eql(u8, extension, ".tpl")) {
            try filepaths.append(try dir.realpathAlloc(alloc, entry.path));
        }
    }
    return filepaths;
}
