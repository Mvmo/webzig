const std = @import("std");

pub const request = @import("request_parser.zig");

pub fn isWhitespace(c: u8) bool {
    return c == ' ' or c == '\t';
}

pub fn readToken(buffer: []const u8) ![]const u8 {
    for (buffer) |char, i| {
        if (isWhitespace(char))
            return buffer[0..i];
        if (char == '\r' and buffer[i + 1] == '\n')
            return buffer[0..i];
        if (i > 0 and i == buffer.len - 1)
            return buffer[0 .. i + 1];
    }

    return error.BadRequest;
}

pub fn readLine(buffer: []const u8) ?[]const u8 {
    for (buffer) |item, i|
        if (item == '\n' and buffer[i - 1] == '\r')
            return buffer[0 .. i - 1];
    return null;
}
