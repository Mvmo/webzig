const std = @import("std");

const parser = @import("parser.zig");

pub fn parse(input: []const u8) std.http.Headers {
    var headers = std.http.Headers.init(std.heap.page_allocator);

    var cursor: u64 = 0;
    while (parser.readLine(input[cursor..])) |line| : (cursor += line.len + 2) {
        if (line.len == 0)
            break;

        var key = parser.readToken(input[cursor..]) catch unreachable;
        key = key[0..key.len - 1];

        var value = parser.readToken(input[cursor + key.len + 2..]) catch unreachable;

        _ = headers.append(key, value, null) catch unreachable;
    }

    return headers;
}