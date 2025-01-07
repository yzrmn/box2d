# Box2D

This is the [Box2D](https://box2d.org/) physics engine packaged for the Zig build system.

## Usage

Add the dependency to your build.zig.zon:

```shell
zig fetch --save git+https://github.com/allyourcodebase/box2d#main
```

Use the dependency in your build.zig:

```zig
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const box2d = b.dependency("box2d", .{
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        // ...
    });
    exe.addIncludePath(box2d.path("."));
    exe.linkLibrary(box2d.artifact("box2d"));

    // ...
}
```

Import and use the C library:

```zig
const c = @cImport({
    @cInclude("box2d/box2d.h");
});

pub fn main() void {
    const world_def = c.b2DefaultWorldDef();
    const world = c.b2CreateWorld(&world_def);
    // ...
}
```

## Examples

This build script can also run the official examples. From this repository run:

```shell
zig build run
```
