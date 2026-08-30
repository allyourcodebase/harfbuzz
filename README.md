[![CI](https://github.com/allyourcodebase/harfbuzz/actions/workflows/ci.yaml/badge.svg)](https://github.com/allyourcodebase/harfbuzz/actions)

# harfbuzz

This is [harfbuzz](https://harfbuzz.github.io/) packaged for [Zig](https://ziglang.org/).

## Installation

First, update your `build.zig.zon`:

```
# Initialize a `zig build` project if you haven't already
zig init
zig fetch --save git+https://github.com/allyourcodebase/harfbuzz.git
```

You can then import `harfbuzz` in your `build.zig` with:

```zig
const harfbuzz_dependency = b.dependency("harfbuzz", .{
    .target = target,
    .optimize = optimize,
});
your_exe.root_module.linkLibrary(harfbuzz_dependency.artifact("harfbuzz"));
```
