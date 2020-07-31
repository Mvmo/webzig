const std = @import("std");
const Connection = std.net.StreamServer.Connection;
const TcpServer = @import("server.zig").TcpServer;

pub const Client = struct {
    context: *const Connection,
    handle_frame: @Frame(handle),

    fn handle(self: *Client, server: *TcpServer) !void {
        var buf: [_]u8 = undefined;
        const amt = try self.context.file.read(&buf);
        const msg = buf[0 .. amt];

        for (server.message_handlers.items) |handler| 
            handler(self, msg);
    }
};