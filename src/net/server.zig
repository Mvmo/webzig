const std = @import("std");
const net = std.net;
const mem = std.mem;

const ArrayList = std.ArrayList;

const Client = @import("client.zig").Client;

pub const TcpServer = struct {

    const HandlerTypeSignature = fn (client: *Client, message: *const []u8) void;

    allocator: *mem.Allocator,
    address: net.Address,
    stream_server: net.StreamServer,
    message_handlers: ArrayList(HandlerTypeSignature),

    pub fn init(allocator: *mem.Allocator) TcpServer {
        return TcpServer {
            .allocator = allocator,
            .address = net.Address.parseIp4("127.0.0.1", 1888) catch unreachable,
            .stream_server = net.StreamServer.init(net.StreamServer.Options{}),
            .message_handlers = ArrayList(HandlerTypeSignature).init(allocator),
        };
    }

    fn deinit(self: *TcpServer) void {
        self.message_handlers.deinit();
        self.* = undefined;
    }

    fn addHandler(self: *TcpServer, handler_function: HandlerTypeSignature) !void {
        try self.message_handlers.append(handler_function);
    }

    fn listen(self: *TcpServer) !void {
        try self.stream_server.listen(self.address);
        defer self.stream_server.deinit();
        while (true) {
            const connection = try self.stream_server.accept();
            const client = try self.allocator.create(Client);

            client.* = .{
                .context = &connection,
                .handle_frame = async client.handle(self),
            };            
        }
    }

};

test "create server and listen" {
    const allocator = std.heap.page_allocator;
    var server = TcpServer.init(allocator);

    defer server.deinit();

    try server.addHandler(test_handler);

    std.debug.warn("Listening on Port {}\n", .{ server.address.getPort() });

    _ = try server.listen();
}