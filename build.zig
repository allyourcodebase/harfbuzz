const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const coretext_enabled = b.option(bool, "enable-coretext", "Build coretext") orelse false;
    const freetype_enabled = b.option(bool, "enable-freetype", "Build freetype") orelse true;

    const upstream = b.dependency("harfbuzz", .{});

    const lib = b.addLibrary(.{
        .name = "harfbuzz",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .link_libcpp = true,
        }),
    });
    lib.root_module.addIncludePath(upstream.path("src"));

    var flags: std.ArrayList([]const u8) = .empty;
    defer flags.deinit(b.allocator);

    try flags.appendSlice(b.allocator, &.{
        "-DHAVE_STDBOOL_H",
    });
    if (target.result.os.tag != .windows) {
        try flags.appendSlice(b.allocator, &.{
            "-DHAVE_UNISTD_H",
            "-DHAVE_SYS_MMAN_H",
            "-DHAVE_PTHREAD=1",
        });
    }

    if (freetype_enabled) {
        if (b.systemIntegrationOption("freetype", .{})) {
            lib.root_module.linkSystemLibrary("freetype", .{});
        } else if (b.lazyDependency("freetype", .{
            .target = target,
            .optimize = optimize,
            .@"enable-libpng" = true,
        })) |freetype_dep| {
            lib.root_module.linkLibrary(freetype_dep.artifact("freetype"));
        }
        try flags.appendSlice(b.allocator, &.{
            "-DHAVE_FREETYPE=1",

            // Let's just assume a new freetype
            "-DHAVE_FT_GET_VAR_BLEND_COORDINATES=1",
            "-DHAVE_FT_SET_VAR_BLEND_COORDINATES=1",
            "-DHAVE_FT_DONE_MM_VAR=1",
            "-DHAVE_FT_GET_TRANSFORM=1",
        });
    }

    if (coretext_enabled) {
        try flags.appendSlice(b.allocator, &.{"-DHAVE_CORETEXT=1"});
        lib.root_module.linkFramework("CoreText", .{});
    }

    lib.root_module.addCSourceFile(.{
        .file = upstream.path("src/harfbuzz.cc"),
        .flags = flags.items,
    });
    lib.installHeadersDirectory(
        upstream.path("src"),
        "",
        .{ .include_extensions = &.{".h"} },
    );

    b.installArtifact(lib);
}
