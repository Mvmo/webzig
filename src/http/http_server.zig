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

    fn handleMessage(client: *Client, message: *[]const u8) void {
        // std.debug.warn("Handle incoming message from client\n--- START ---\n{}\n---  END  ---\n", .{message.*});
        var req = parser.request.parse(message) catch unreachable;
        req.print();

        var res = getResponse(req.uri);

        var response_string = res.asString() catch unreachable;
        _ = client.context.file.write(response_string) catch unreachable;
        client.context.file.close();
    }

    fn getResponse(file_path: []const u8) Response {
        const full_path: []const u8 = std.fmt.allocPrint(std.heap.page_allocator, "www{}", .{file_path}) catch |_| return response.internal_server_error;

        std.debug.warn("{}\n", .{full_path});

        const working_dir = std.fs.cwd();

        // TODO check error type...
        const file = working_dir.openFile(full_path, .{ .read = true }) catch |_| return response.file_not_found;

        defer file.close();

        var size: usize = file.getEndPos() catch |_| return response.internal_server_error;
        var body_buffer: []u8 = std.heap.page_allocator.alloc(u8, size) catch |_| return response.internal_server_error;

        const bytes_read = file.read(body_buffer) catch |_| return response.internal_server_error;
        if (bytes_read != size) {
            return response.internal_server_error;
        }

        var msg: []const u8 = "OK";

        return Response{
            .status_code = 200,
            .status_message = msg,
            .body = body_buffer,
        };
    }
};
