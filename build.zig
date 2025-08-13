const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const box2d_dep = b.dependency("box2d", .{});

    const lib = b.addStaticLibrary(.{
        .name = "box2d",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.addIncludePath(box2d_dep.path("include"));
    lib.installHeadersDirectory(box2d_dep.path("include"), "", .{});
    lib.addCSourceFiles(.{
        .root = box2d_dep.path("src"),
        .flags = &.{
            "-std=gnu17",
        },
        .files = &.{
            "aabb.c",
            "arena_allocator.c",
            "array.c",
            "bitset.c",
            "body.c",
            "broad_phase.c",
            "constraint_graph.c",
            "contact.c",
            "contact_solver.c",
            "core.c",
            "distance.c",
            "distance_joint.c",
            "dynamic_tree.c",
            "geometry.c",
            "hull.c",
            "id_pool.c",
            "island.c",
            "joint.c",
            "manifold.c",
            "math_functions.c",
            "motor_joint.c",
            "mouse_joint.c",
            "mover.c",
            "prismatic_joint.c",
            "revolute_joint.c",
            "sensor.c",
            "shape.c",
            "solver.c",
            "solver_set.c",
            "table.c",
            "timer.c",
            "types.c",
            "weld_joint.c",
            "wheel_joint.c",
            "world.c",
        },
    });
    b.installArtifact(lib);

    const testing = b.option(bool, "test", "Enable test applications (examples, benchmarks)") orelse false;
    if (!testing) return;

    const glfw_dep = b.lazyDependency("glfw", .{}) orelse return;
    const imgui_dep = b.lazyDependency("imgui", .{}) orelse return;
    const enki_dep = b.lazyDependency("enkits", .{}) orelse return;

    const samples_exe = b.addExecutable(.{
        .name = "samples",
        .target = target,
        .optimize = optimize,
    });
    samples_exe.linkLibrary(lib);
    samples_exe.linkLibCpp();
    samples_exe.addIncludePath(box2d_dep.path("shared"));
    samples_exe.addIncludePath(box2d_dep.path("extern/glad/include"));
    samples_exe.addIncludePath(box2d_dep.path("extern/jsmn"));
    samples_exe.addCSourceFiles(.{
        .flags = &.{
            "-DIMGUI_DISABLE_OBSOLETE_FUNCTIONS",
            "-std=c++20",
        },
        .root = box2d_dep.path("samples"),
        .files = &.{
            "car.cpp",
            "donut.cpp",
            "doohickey.cpp",
            "draw.cpp",
            "main.cpp",
            "sample.cpp",
            "sample_benchmark.cpp",
            "sample_bodies.cpp",
            "sample_character.cpp",
            "sample_collision.cpp",
            "sample_continuous.cpp",
            "sample_determinism.cpp",
            "sample_events.cpp",
            "sample_geometry.cpp",
            "sample_joints.cpp",
            "sample_robustness.cpp",
            "sample_shapes.cpp",
            "sample_stacking.cpp",
            "sample_world.cpp",
            "shader.cpp",
        },
    });
    samples_exe.addCSourceFiles(.{
        .flags = &.{
            "-std=gnu17",
        },
        .root = box2d_dep.path("."),
        .files = &.{
            "extern/glad/src/glad.c",
            "shared/benchmarks.c",
            "shared/determinism.c",
            "shared/human.c",
            "shared/random.c",
        },
    });
    // Library dependencies
    samples_exe.addIncludePath(imgui_dep.path("."));
    samples_exe.addIncludePath(imgui_dep.path("backends"));
    samples_exe.addCSourceFiles(.{
        .flags = &.{
            "-DIMGUI_DISABLE_OBSOLETE_FUNCTIONS",
            "-std=c++20",
        },
        .root = imgui_dep.path("."),
        .files = &.{
            "imgui.cpp",
            "imgui_draw.cpp",
            "imgui_demo.cpp",
            "imgui_tables.cpp",
            "imgui_widgets.cpp",
            "backends/imgui_impl_glfw.cpp",
            "backends/imgui_impl_opengl3.cpp",
        },
    });
    samples_exe.addIncludePath(glfw_dep.path("include"));
    samples_exe.linkLibrary(glfw_dep.artifact("glfw"));
    samples_exe.addIncludePath(enki_dep.path("src"));
    samples_exe.addCSourceFiles(.{
        .flags = &.{
            "-std=c++11",
        },
        .root = enki_dep.path("src"),
        .files = &.{
            "TaskScheduler.cpp",
            "TaskScheduler_c.cpp",
        },
    });
    b.installArtifact(samples_exe);
    b.installDirectory(.{
        .install_dir = .prefix,
        .install_subdir = "samples/data",
        .source_dir = box2d_dep.path("samples/data"),
    });

    const run_cmd = b.addRunArtifact(samples_exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    // TODO: don't hardcode prefix
    run_cmd.setCwd(b.path("zig-out"));

    const run_step = b.step("run", "Run example application");
    run_step.dependOn(&run_cmd.step);
}
