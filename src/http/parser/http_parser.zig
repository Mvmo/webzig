const Request = struct {};

const RequestParser = struct {

    var cursor: u32;

    original_input: *[]const u8,
    consumed_input: *[]const u8,
    request_type: []const u8,

    pub fn parse(input: *[]const u8) RequestParser {
        return RequestParser {
            .original_input = original_input,
            .consumed_input = "",
            .request_type = ""
        };
    }

};

const std = @import("std");