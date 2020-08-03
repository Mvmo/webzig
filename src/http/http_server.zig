const std = @import("std");
const Allocator = std.mem.Allocator;

const webzig = @import("../webzig.zig");
const net = webzig.net;
const TcpServer = net.server.TcpServer;
const Client = net.client.Client;

const parser = @import("parser/parser.zig");
const Response = @import("http.zig").Response;

const ArrayList = std.ArrayList;

pub const HttpServer = struct {
    allocator: *Allocator,
    tcpServer: TcpServer,

    pub fn init(allocator: *Allocator) HttpServer {
        return HttpServer{
            .allocator = allocator,
            .tcpServer = TcpServer.init(allocator),
        };
    }

    fn deinit(self: *HttpServer) void {
        self.tcpServer.deinit();
        self.* = undefined;
    }

    fn listen(self: *HttpServer) !void {
        // TODO make port configurable
        std.debug.warn("Webzig Server is running on port {}\n", .{80});
        try self.tcpServer.addHandler(handleMessage);
        try self.tcpServer.listen();
    }

    fn handleMessage(client: *Client, message: *[]const u8) void {
        // std.debug.warn("Handle incoming message from client\n--- START ---\n{}\n---  END  ---\n", .{message.*});
        var req = parser.request.parse(message) catch unreachable;
        req.print();

        var content = getContent(req.uri) catch unreachable;
        var msg: []const u8 = "OK";

        var res = Response{
            .status_code = 200,
            .status_message = &msg,
            .body = &content,
        };

        var response_string = res.asString() catch unreachable;
        _ = client.context.file.write(response_string) catch unreachable;
        client.context.file.close();
    }

    fn getContent(file_path: []const u8) ![]const u8 {
        const full_path: []const u8 = try std.fmt.allocPrint(std.heap.page_allocator, "www{}", .{file_path});

        std.debug.warn("{}\n", .{full_path});

        const file = try std.fs.cwd().openFile(full_path, .{ .read = true });
        defer file.close();

        var size: usize = try file.getEndPos();
        var s: []u8 = try std.heap.page_allocator.alloc(u8, size);

        const bytesRead = try file.read(s);
        if (bytesRead != size) {
            return error.BadRequest;
        }

        return s;
    }
};
