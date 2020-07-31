const std = @import("std");
const net = std.net;
const mem = std.mem;

const ArrayList = std.ArrayList;
const Connection = net.StreamServer.Connection;

const Client = struct {
    
    context: *const Connection,
    handle_frame: @Frame(handle),

    fn handle(self: *Client, server: *Server) !void {
        var buf: [100]u8 = undefined;
        const amt = try self.context.file.read(&buf);
        const msg = buf[0 .. amt];

        std.debug.warn("{}\n", .{msg});

        for (server.message_handlers.items) |handler| {
            handler(self, &msg);
        }
    }

};

const Server = struct {

    const HandlerTypeSignature = fn (client: *Client, message: *const []u8) void;

    allocator: *mem.Allocator,
    address: net.Address,
    stream_server: net.StreamServer,
    message_handlers: ArrayList(HandlerTypeSignature),

    pub fn init(allocator: *mem.Allocator) Server {
        return Server {
            .allocator = allocator,
            .address = net.Address.parseIp4("127.0.0.1", 1889) catch unreachable,
            .stream_server = net.StreamServer.init(net.StreamServer.Options{}),
            .message_handlers = ArrayList(HandlerTypeSignature).init(allocator),
        };
    }

    fn deinit(self: *Server) void {
        self.message_handlers.deinit();
        self.* = undefined;
    }

    fn addHandler(self: *Server, handler_function: HandlerTypeSignature) !void {
        try self.message_handlers.append(handler_function);
    }

    fn listen(self: *Server) !void {
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

fn test_handler(client: *Client, message: *const []u8) void {
    const response = "HTTP/1.1 200 OK\nContent-Type: text/html\nContent-Length: 21\n\n<h1>Hello worlg!</h1>";

    _ = client.context.file.write(response) catch unreachable;
}

test "create server and listen" {
    const allocator = std.heap.page_allocator;
    var server = Server.init(allocator);

    defer server.deinit();

    try server.addHandler(test_handler);

    std.debug.warn("Listening on Port {}\n", .{ server.address.getPort() });

    _ = try server.listen();
}