const std = @import("std");
const Connection = std.net.StreamServer.Connection;
const TcpServer = @import("server.zig").TcpServer;
const ArrayList = std.ArrayList;

pub const Client = struct {
    context: *const Connection,
    handle_frame: @Frame(handle),

    fn handle(self: *Client, server: *TcpServer) !void {
        var buffer: [comptime 1024 * 2]u8 = undefined;
        const bytes_read = try self.context.file.read(&buffer);
        const message = buffer[0..bytes_read];

        for (server.message_handlers.items) |handler|
            handler(self, &message);
    }
};
