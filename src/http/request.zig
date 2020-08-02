const std = @import("std");
const ArrayList = std.ArrayList;
const startsWith = std.mem.startsWith;

const http = @import("http.zig");
const Header = http.Header;

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

pub const Request = struct {
    request_string: *const []u8,
    method: RequestMethod,
    request_url: *const []u8,

    // TODO Error Handling
    pub fn parse(request_string: *const []u8) Request {
        return Request {
            .request_string = request_string
        };
    }
};

const allocator = std.heap.page_allocator;