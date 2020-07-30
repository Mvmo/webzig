const std = @import("std");
const net = std.net;

const Server = struct {
    
    ip: net.Address,
    streamServer: net.StreamServer,

    pub fn init() Server {
        return Server {
            .ip = net.Address.parseIp4("127.0.0.1", 1889) catch unreachable,
            .streamServer = net.StreamServer.init(net.StreamServer.Options{}),
        };
    }

};

test "create server" {
    const server = Server.init();
    std.debug.warn("{}\n", .{server.ip});
}