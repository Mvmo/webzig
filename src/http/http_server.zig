const std = @import("std");
const Allocator = std.mem.Allocator;

const webzig = @import("../webzig.zig");
const net = webzig.net;
const TcpServer = net.server.TcpServer;
const Client = net.client.Client;

const parser = @import("parser/parser.zig");
const response = @import("http.zig").response;
const Response = response.Response;

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

    fn handleMessage(client: *Client, message: []const u8) void {
        // std.debug.warn("Handle incoming message from client\n--- START ---\n{}\n---  END  ---\n", .{message.*});
        var req = parser.request.parse(message) catch unreachable;
        req.print();

        var res = getResponse(req.uri) catch unreachable;

        var response_string = res.asString() catch unreachable;
        _ = client.context.file.write(response_string) catch unreachable;
        client.context.file.close();
    }

    fn getResponse(file_path: []const u8) !Response {
        const full_path: []const u8 = try std.fmt.allocPrint(std.heap.page_allocator, "www{}", .{file_path});

        std.debug.warn("{}\n", .{full_path});

        const working_dir = std.fs.cwd();

        const file = working_dir.openFile(full_path, .{ .read = true }) catch |e| {
            return response.file_not_found;
        };

        defer file.close();

        var size: usize = try file.getEndPos();
        var body_buffer: []u8 = try std.heap.page_allocator.alloc(u8, size);

        const bytes_read = try file.read(body_buffer);
        if (bytes_read != size) {
            return error.BadRequest;
        }

        var msg: []const u8 = "OK";

        return Response{
            .status_code = 200,
            .status_message = msg,
            .body = body_buffer,
        };
    }
};
