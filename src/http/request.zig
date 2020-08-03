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

const request_method_string_mapping = [_]([]const u8){
    "GET",
    "POST",
    "PUT",
    "DELETE",
    "TRACE",
    "CONNECT",
    "HEAD",
    "OPTIONS",
};


const allocator = std.heap.page_allocator;
