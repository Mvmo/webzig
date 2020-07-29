const std = @import("std");
const StreamServer = std.net.StreamServer;
const Address = std.net.Address;

pub fn main() anyerror!void {
    std.debug.warn("All your codebase are belong to us.\n", .{});
}

pub fn listen(server: *StreamServer, address: Address) !void {
    server.deinit();
    server.listen(address) catch |err| switch (err) {
        error.AddressInUse,
        error.AddressNotAvailable,
        => |e| return e,
        else => return error.ListenError,
    };

    
}
