const std = @import("std");

pub fn build(b: *std.Build) void {
    const stylesheet = compileStylesheet(b);

    const release = b.addSystemCommand(&.{ "zine", "release" });
    release.addArg("--force");
    release.addArg(b.fmt("--output={s}", .{b.getInstallPath(.prefix, "site")}));
    addStylesheet(release, stylesheet);

    b.default_step.dependOn(&release.step);

    const serve = b.addSystemCommand(&.{"zine"});
    addStylesheet(serve, stylesheet);
    const serve_step = b.step("serve", "Compile Sass and run Zine's development server");
    serve_step.dependOn(&serve.step);
}

fn compileStylesheet(b: *std.Build) std.Build.LazyPath {
    const sass = b.addSystemCommand(&.{
        "sass",
        "--no-source-map",
        "--silence-deprecation=global-builtin",
        "--silence-deprecation=if-function",
        "--silence-deprecation=slash-div",
    });
    sass.addFileArg(b.path("sass/zine.scss"));
    sass.has_side_effects = true;

    return sass.addOutputFileArg("base.css");
}

fn addStylesheet(command: *std.Build.Step.Run, stylesheet: std.Build.LazyPath) void {
    command.addArg("--build-asset=base.css");
    command.addFileArg(stylesheet);
    command.addArg("--install=base.css");
}
