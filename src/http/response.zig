const std = @import("std");

pub const Response = struct {
    const version: []const u8 = "HTTP/1.1";

    status_code: u8,
    status_message: *[]const u8,

    body: *[]const u8,

    pub fn asString(self: *Response) ![]const u8 {
        return try std.fmt.allocPrint(std.heap.page_allocator, "{} {} {}\r\n{}\r\n{}{}\r\n\r\n{}", .{
            Response.version,
            self.status_code,
            self.status_message.*,
            "Content-Type: text/html",
            "Content-Length: ",
            self.body.len,
            self.body.*,
        });
    }
};

pub const file_not_found = Response {
    .status_code = 404,
    .status_message = "Not Found",
    .body = @embedFile("../../resources/404.html"),
};

pub const internal_server_error = Response {
    .status_code = 500,
    .status_message = "Internal Server Error",
    .body = @embedFile("../../resources/500.html"),
};
