//! Build tool that combines multiple static archives into a single fat
//! archive using an MRI script piped to `zig ar -M`.
//!
//! MRI scripts require stdin piping (`ar -M < script`), which can't be
//! expressed as a single command in the zig build system's RunStep. The
//! previous approach used `/bin/sh -c` to do the piping, but that isn't
//! available on Windows. This tool handles both the script generation
//! and the piping in a single cross-platform executable.
//!
//! Usage: combine_archives <zig_exe> <output.a> <input1.a> [input2.a ...]

const std = @import("std");

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const alloc = gpa.allocator();

    const args = try std.process.argsAlloc(alloc);
    if (args.len < 4) {
        std.log.err("usage: combine_archives <zig_exe> <output> <input...>", .{});
        std.process.exit(1);
    }

    const zig_exe = args[1];
    const output_path = args[2];
    const inputs = args[3..];

    // Build the MRI script.
    var script: std.ArrayListUnmanaged(u8) = .empty;
    try script.appendSlice(alloc, "CREATE ");
    try script.appendSlice(alloc, output_path);
    try script.append(alloc, '\n');
    for (inputs) |input| {
        try script.appendSlice(alloc, "ADDLIB ");
        try script.appendSlice(alloc, input);
        try script.append(alloc, '\n');
    }
    try script.appendSlice(alloc, "SAVE\nEND\n");

    var child: std.process.Child = .init(&.{ zig_exe, "ar", "-M" }, alloc);
    child.stdin = .pipe;
    child.stdout = .inherit;
    child.stderr = .inherit;

    var threaded: std.Io.Threaded = .init(std.heap.page_allocator, .{});
    const io = threaded.io();
    try child.spawn(io);
    try child.stdin_handle.?.writeAll(script.items);
    child.stdin_handle.?.close();
    child.stdin_handle = null;

    const term = try child.wait(io);
    if (term.Exited.code != 0) {
        std.log.err("zig ar -M exited with code {d}", .{term.Exited.code});
        std.process.exit(1);
    }
}
