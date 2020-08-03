const std = @import("std");

pub const Response = struct {
    const version: []const u8 = "HTTP/1.1";

    status_code: u16,
    status_message: []const u8,

    body: []const u8,

    pub fn asString(self: *Response) ![]const u8 {
        return try std.fmt.allocPrint(std.heap.page_allocator, "{} {} {}\r\n{}\r\n{}{}\r\n\r\n{}", .{
            Response.version,
            self.status_code,
            self.status_message,
            "Content-Type: text/html",
            "Content-Length: ",
            self.body.len,
            self.body,
        });
    }
};
