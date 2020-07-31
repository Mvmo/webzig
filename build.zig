const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    const exe = b.addExecutable("webzig", "src/webzig.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    {
        const tests = b.addTest("src/tests.zig");
        tests.setTarget(target);
        tests.setBuildMode(mode);
        
        const test_step = b.step("test", "Run the tests");
        test_step.dependOn(&tests.step);
    }
}
