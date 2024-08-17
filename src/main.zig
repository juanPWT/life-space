const std = @import("std");
const rl = @import("raylib");

const env = @import("environment.zig");
const game = @import("game.zig");

pub fn main() anyerror!void {
    rl.initWindow(env.SCREEN_WIDTH, env.SCREEN_HEIGHT, "life space");
    defer rl.closeWindow();

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    rl.setTargetFPS(60);

    var g = game.Game.init();
    defer g.deinit();

    // env play
    g.envPlay();

    while (!rl.windowShouldClose()) {
        // update game
        try g.update();

        rl.beginDrawing();
        defer rl.endDrawing();

        // background env play
        g.backgroundEnvPlay();

        rl.clearBackground(rl.Color.init(44, 52, 82, 255));

        // draw game
        g.draw();
    }
}
