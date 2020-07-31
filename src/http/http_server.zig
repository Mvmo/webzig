const std = @import("std");
const Allocator = std.mem.Allocator;

const webzig = @import("../webzig.zig");
const net = webzig.net;
const TcpServer = net.server.TcpServer;
const Client = net.client.Client;

const request = @import("request.zig");

pub const HttpServer = struct {

    allocator: *Allocator,
    tcpServer: TcpServer,

    pub fn init(allocator: *Allocator) HttpServer {
        return HttpServer {
            .allocator = allocator,
            .tcpServer = TcpServer.init(allocator)
        };
    }

    fn deinit(self: *HttpServer) void {
        self.tcpServer.deinit();
        self.* = undefined;
    }

    fn listen(self: *HttpServer) !void {
        try self.tcpServer.addHandler(handleMessage);
        try self.tcpServer.listen();
    }

    fn handleMessage(client: *Client, message: *const []u8) void {
        std.debug.warn("Handle incoming message from client\n--- START ---\n{}\n---  END  ---\n", .{message.*});

        var req = request.Request.parse(message);
        std.debug.warn("Request: {}\n", .{req});
    }

};