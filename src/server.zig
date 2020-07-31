const std = @import("std");
const net = std.net;

const Server = struct {
    
    address: net.Address,
    streamServer: net.StreamServer,

    pub fn init() Server {
        return Server {
            .address = net.Address.parseIp4("127.0.0.1", 1889) catch unreachable,
            .streamServer = net.StreamServer.init(net.StreamServer.Options{}),
        };
    }

    fn listen(self: *Server) !void {
        try self.streamServer.listen(self.address);
    }

    fn helloWorld(self: *Server) void {
    }

};

const assert = std.debug.assert;

test "create server" {
    var server = Server.init();
    
    std.debug.warn("Listening on Port {}\n", .{ server.address.getPort() });

    _ = server.helloWorld();
}