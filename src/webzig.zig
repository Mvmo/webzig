const std = @import("std");

pub const net = @import("net/net.zig");
pub const http = @import("http/http.zig");

pub const RequestMethod = http.request.RequestMethod;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    
    var server = http.server.HttpServer.init(allocator);
    defer server.deinit();
    
    try server.listen();
}