const std = @import("std");

test "test the application" {
    //_ = @import("webzig.zig");
    //_ = @import("net/net.zig");
    //_ = @import("http/http.zig");
    var str: []const u8 = "Hello, World!";
    std.debug.warn("{}\n", .{@typeName(@TypeOf(&str))});

}