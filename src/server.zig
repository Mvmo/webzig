const std = @import("std");
const StreamServer = std.net.StreamServer;
const Address = std.net.Address;
const Allocator = std.mem.Allocator;

pub const Server = struct {
    streamServer: StreamServer;
    allocator: *Allocator;

    pub fn init(allocator: *Allocator) Server {
        return .{
            .streamServer = StreamServer.init(.{}),
            .allocator = allocator,
        };
    }
}