const std = @import("std");

const parser = @import("parser.zig");
const readLine = parser.readLine;
const readToken = parser.readToken;

const String = []const u8;

const header = @import("header_parser.zig");

pub const Request = struct {
    request_line: String,
    method: String,
    uri: String,
    version: String,
    headers: std.http.Headers,

    pub fn print(self: *Request) void {
        std.debug.warn("\nRequest-Line: {}\n\nMethod: {}\nUri: {}\nVersion: {}\nHeaders: {}\n", .{
            self.request_line,
            self.method,
            self.uri,
            self.version,
            self.headers.toSlice().len
        });
    }
};

pub fn parse(input: *String) !Request {
    const request_line = readLine(input.*) orelse return error.BadRequest;
    const method = try readToken(request_line);
    const uri = try readToken(request_line[method.len + 1 ..]);
    const version = try readToken(request_line[method.len + uri.len + 2 ..]);
    const headers = header.parse(input[request_line.len + 2..]);

    return Request{
        .request_line = request_line,
        .method = method,
        .uri = uri,
        .version = version,
        .headers = headers,
    };
}
