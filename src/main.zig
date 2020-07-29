const std = @import("std");
const network = @import("zig-network");

pub fn main() anyerror!void {
    std.debug.warn("All your codebase are belong to us.\n", .{});

    try echo();
}

pub fn echo() !void {
    try network.init();
    defer network.deinit();

    const sock = try network.connectToHost(std.heap.page_allocator, "tcpbin.com", 4242, .tcp);
    defer sock.close();

    const message = "Hello\n";
    try sock.writer().writeAll(message);

    var buf: [128]u8 = undefined;
    std.debug.warn("Echo: {}\n", .{
        buf[0 .. try sock.reader().readAll(buf[0 .. message.len])]
    });
}