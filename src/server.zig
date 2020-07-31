const std = @import("std");
const net = std.net;
const mem = std.mem;

const Connection = net.StreamServer.Connection;

const Client = struct {
    
    context: *const Connection,
    handle_frame: @Frame(handle),

    fn handle(self: *Client, server: *Server) !void {
        _ = try self.context.file.write("server: welcome to the server");
    }

};

const Server = struct {

    allocator: *mem.Allocator,
    address: net.Address,
    stream_server: net.StreamServer,

    pub fn init(allocator: *mem.Allocator) Server {
        return Server {
            .allocator = allocator,
            .address = net.Address.parseIp4("127.0.0.1", 1889) catch unreachable,
            .stream_server = net.StreamServer.init(net.StreamServer.Options{}),
        };
    }

    fn deinit(self: *Server) void {
        self.* = undefined;
    }

    fn listen(self: *Server) !void {
        try self.stream_server.listen(self.address);
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
    var server = Server.init(allocator);

    defer server.deinit();

    std.debug.warn("Listening on Port {}\n", .{ server.address.getPort() });

    _ = try server.listen();
}