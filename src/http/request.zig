const std = @import("std");
const startsWith = std.mem.startsWith;

pub const RequestMethod = enum(u8) {
    GET,
    POST,
    PUT,
    DELETE,
    TRACE,
    CONNECT,
    HEAD,
    OPTIONS,
};

const request_method_string_mapping = [_]([]const u8) {
    "GET",
    "POST",
    "PUT",
    "DELETE",
    "TRACE",
    "CONNECT",
    "HEAD",
    "OPTIONS",
};

pub fn getRequestMethod(str: *const []u8) !RequestMethod {
    for (request_method_string_mapping) |element, index| {
        const i: u8 = @intCast(u8, index);
        if (startsWith(u8, str.*, request_method_string_mapping[i]))
            return @intToEnum(RequestMethod, i);
    }

    // TODO do better error handling
    return error.Lost;
}