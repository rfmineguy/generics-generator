const std = @import("std");
const yazap = @import("yazap");
const known_folders = @import("knownfolders");
const toml = @import("tomlz");
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

pub const Dependency = struct {
    name: []const u8,
    forwardTo: []const u8,
    forwardArgs: std.StringHashMap([]const u8),

    pub fn from(name: []const u8, alloc: std.mem.Allocator) @This() {
        return @This(){
            .name = name,
            .forwardTo = "",
            .forwardArgs = .init(alloc),
        };
    }
};
fn printArray(a: []const toml.TomlValue) void {
    for (a) |*value| {
        switch (value.*) {
            .String => |slice| {
                std.debug.print("{s},", .{slice});
            },
            .Boolean => |b| std.debug.print("{},", .{b}),
            .Integer => |int| std.debug.print("{d},", .{int}),
            .Float => |fl| std.debug.print("{d},", .{fl}),
            .DateTime => |*ts| std.debug.print("{any},", .{ts.*}),
            .Table => |*table| {
                std.debug.print("{{ ", .{});
                printTable(table);
                std.debug.print("\n}},", .{});
            },
            .Array => |inner_arry| {
                std.debug.print("[ ", .{});
                printArray(inner_arry);
                std.debug.print("],", .{});
            },
            else => unreachable,
        }
    }
}

fn printTable(t: *const toml.TomlTable) void {
    var it = t.iterator();
    while (it.next()) |e| {
        std.debug.print("\n{s} => ", .{e.key_ptr.*});
        switch (e.value_ptr.*) {
            .String => |slice| std.debug.print("{s}", .{slice}),
            .Boolean => |b| std.debug.print("{},", .{b}),
            .Integer => |i| std.debug.print("{d},", .{i}),
            .Float => |fl| std.debug.print("{d},", .{fl}),
            .DateTime => |*ts| std.debug.print("{any},", .{ts.*}),
            .Array => |a| {
                std.debug.print("[ ", .{});
                printArray(a);
                std.debug.print("]\n", .{});
            },
            .Table => |*table| {
                std.debug.print("{{ ", .{});
                printTable(table);
                std.debug.print("\n}}", .{});
            },
            .TablesArray => |a| {
                std.debug.print("[ ", .{});
                for (a) |*i| {
                    std.debug.print("{{ ", .{});
                    printTable(i);
                    std.debug.print("}},", .{});
                }
                std.debug.print("]\n", .{});
            },
        }
    }
    std.debug.print("\n", .{});
}

// represents <adt>.tpl
pub const Template = struct {
    name: []const u8,
    generators: std.ArrayList([]const u8),
    outformat: []const u8,
    deps: std.ArrayList(Dependency),
    args: std.ArrayList(Arg),

    fn new(alloc: Allocator) @This() {
        return @This(){
            .name = "",
            .generators = std.ArrayList([]const u8).init(alloc),
            .outformat = "",
            .deps = std.ArrayList(Dependency).init(alloc),
            .args = std.ArrayList(Arg).init(alloc),
        };
    }

    pub fn getArgMutByName(self: @This(), name: []const u8) ?*Arg {
        for (self.args.items) |*arg| {
            if (std.mem.eql(u8, arg.name.?, name)) return arg;
        }
        return null;
    }

    pub fn parse(alloc: Allocator, path: []const u8) !@This() {
        const src = try std.fs.cwd().readFileAlloc(alloc, path, std.math.maxInt(u32));

        var toml_stream = std.io.StreamSource{
            .const_buffer = std.io.FixedBufferStream([]const u8){
                .buffer = src,
                .pos = 0,
            },
        };

        var parser = toml.Parser.init(alloc);
        defer parser.deinit();

        const table = parser.parse(&toml_stream) catch {
            const err = parser.errorMessage();
            std.log.err("The stream isn't a valid TOML document, {s}\n", .{err});
            return error.failed_parse;
        };
        // printTable(table);
        var ret = Template.new(alloc);
        ret.args = std.ArrayList(Arg).init(alloc);
        ret.deps = std.ArrayList(Dependency).init(alloc);
        ret.generators = std.ArrayList([]const u8).init(alloc);
        var it = table.iterator();
        while (it.next()) |entry| {
            if (std.mem.eql(u8, entry.key_ptr.*, "name")) {
                if (entry.value_ptr.* != .String) return error.name_malformed;
                ret.name = try alloc.dupe(u8, entry.value_ptr.*.String);
            }
            if (std.mem.eql(u8, entry.key_ptr.*, "generators")) {
                if (entry.value_ptr.* != .Array) return error.generators_array_malformed;
                for (entry.value_ptr.*.Array) |v| {
                    try ret.generators.append(try alloc.dupe(u8, v.String));
                }
            }
            if (std.mem.eql(u8, entry.key_ptr.*, "outformat")) {
                if (entry.value_ptr.* != .String) return error.outformat_malformed;
                ret.outformat = try alloc.dupe(u8, entry.value_ptr.*.String);
            }
            if (std.mem.eql(u8, entry.key_ptr.*, "deps")) {
                if (entry.value_ptr.* != .Table) return error.deps_table_malformed;
                var tit = entry.value_ptr.*.Table.iterator();
                while (tit.next()) |deptable| {
                    if (deptable.value_ptr.* != .Table) return error.dep_table_malformed;
                    var dep = Dependency.from(try alloc.dupe(u8, deptable.key_ptr.*), alloc);
                    var deptit = deptable.value_ptr.*.Table.iterator();
                    while (deptit.next()) |deptittable| {
                        try dep.forwardArgs.put(try alloc.dupe(u8, deptittable.key_ptr.*), try alloc.dupe(u8, deptittable.value_ptr.*.String));
                    }
                    try ret.deps.append(dep);
                }
            }
            if (std.mem.eql(u8, entry.key_ptr.*, "args")) {
                if (entry.value_ptr.* != .Table) return error.args_table_malformed;
                var argit = entry.value_ptr.*.Table.iterator();
                while (argit.next()) |entry_| {
                    if (entry_.value_ptr.* != .Table) return error.arg_malformed;
                    var argentry_it = entry_.value_ptr.*.Table.iterator();
                    var argument: Arg = .{};
                    argument.name = try alloc.dupe(u8, entry_.key_ptr.*);
                    while (argentry_it.next()) |arg_entry| {
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
        }
        return ret;
    }

    pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("Template(\n", .{});
        try writer.print("  name: {s},\n", .{self.name});
        try writer.print("  args: [\n", .{});
        for (self.args.items) |arg| {
            try writer.print("{any}", .{arg});
        }
        try writer.print("  ]\n", .{});
        try writer.print("  generators: [", .{});
        for (self.generators.items) |generator| try writer.print("{s},", .{generator});
        try writer.print("]\n", .{});
        try writer.print("  deps: [\n", .{});
        for (self.deps.items) |dep| {
            try writer.print("Dep(name={s},\n", .{dep.name});
            var it = dep.forwardArgs.iterator();
            while (it.next()) |arg| {
                try writer.print("arg={s}->{s}\n", .{ arg.key_ptr.*, arg.value_ptr.* });
            }
            try writer.print(")\n", .{});
        }
        try writer.print("  ],\n", .{});
        try writer.print("  outformat: {s},\n", .{self.outformat});
        try writer.print(")\n", .{});
    }
};

pub const TemplateFile = struct {
    fullpath: []const u8,
    name: []const u8,

    pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("TemplateFile(\n", .{});
        try writer.print("  fullpath: {s},\n", .{self.fullpath});
        try writer.print("  name: {s},\n", .{self.name});
        try writer.print(")\n", .{});
    }
};

pub const Error = error{TemplateSearchPathInvalid};

pub fn get_template_files(alloc: std.mem.Allocator) anyerror!std.ArrayList(TemplateFile) {
    const template_search_path_var = "GEN_TEMPLATE_PATH";
    const local_conf_path = try known_folders.getPath(alloc, .local_configuration);
    defer if (local_conf_path) |h| alloc.free(h);

    const path = path: {
        const template_search_path_val = std.process.getEnvVarOwned(alloc, template_search_path_var) catch {
            if (local_conf_path) |local| break :path try std.fs.path.join(alloc, &[_][]const u8{ local, "generics" }) else break :path null;
        };
        std.debug.print("{s}\n", .{template_search_path_val});
        break :path std.fs.realpathAlloc(alloc, template_search_path_val) catch {
            break :path null;
        };
    };

    if (path == null) {
        std.debug.print("Error: Template search path not valid\n", .{});
        return Error.TemplateSearchPathInvalid;
    }

    std.debug.print("Searching: {?s}\n", .{path.?});

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
