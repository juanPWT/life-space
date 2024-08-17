const std = @import("std");
const rl = @import("raylib");
const character = @import("character.zig");
const env = @import("environment.zig");

pub const ModeEnv = enum {
    Normal,
    Story,
    Boss,
};

pub const Game = struct {
    // game
    mode: ModeEnv,
    mc: character.Mc,
    enemy: [4]character.Kroco,
    // attri
    bgm: env.Bgm,
    bg: env.Background,
    midG: env.Ground,
    foreG: env.Ground,

    pub fn init() Game {
        return Game{
            // game
            .mode = ModeEnv.Normal,
            .mc = character.Mc.init(4, 100),
            .enemy = [4]character.Kroco{ character.Kroco.init(50, 100), character.Kroco.init(50, 100), character.Kroco.init(50, 100), character.Kroco.init(50, 100) },
            // attri
            .bgm = env.Bgm.init(rl.loadMusicStream("resources/bgm/bgm-idle.mp3"), 0.4),
            .bg = env.Background.init(1, rl.loadTexture("resources/env/background/normal2.png")),
            .midG = env.Ground.init(rl.loadTexture("resources/env/mid/mid.png"), 150, 0, 0.2),
            .foreG = env.Ground.init(rl.loadTexture("resources/env/fore/fore.png"), 0, 0, 0.8),
        };
    }

    pub fn deinit(self: *Game) void {
        // game
        self.mc.deinit();
        for (&self.enemy) |*e| {
            e.deinit();
        }
        // attri
        self.bgm.deinit();
        self.bg.deinit();
        self.midG.deinit();
        self.foreG.deinit();
    }

    pub fn envPlay(self: *Game) void {
        self.bgm.play();
    }

    pub fn backgroundEnvPlay(self: *Game) void {
        self.bg.draw();
        self.midG.draw();
        self.foreG.draw();
    }

    pub fn update(self: *Game) !void {
        // game
        try self.mc.update(rl.getFrameTime());

        // check enemy wasshoot
        for (self.mc.bullets.items) |*mc_bullet| {
            if (!mc_bullet.active) continue;
            for (&self.enemy) |*e| {
                if (e.wasShoot(mc_bullet.position.x, mc_bullet.position.y)) {
                    // mc bullet de actived
                    if (!e.isDead) {
                        mc_bullet.active = false;
                    }

                    e.takeDemage(mc_bullet.demage);
                    break;
                }
            }
        }

        // update enemys
        for (&self.enemy) |*e| {
            try e.update(rl.getFrameTime());

            // check mc was shoot
            for (e.bullets.items) |*enemy_bullet| {
                if (!enemy_bullet.active) continue;
                if (self.mc.wasShoot(enemy_bullet.position.x, enemy_bullet.position.y)) {
                    if (!self.mc.isDead) {
                        enemy_bullet.active = false;
                    }

                    self.mc.takeDemage(enemy_bullet.demage);
                    break;
                }
            }
        }

        // attri
        self.bgm.update();
        self.midG.update();
        self.foreG.update();
    }

    pub fn draw(self: *Game) void {
        self.mc.draw();
        for (&self.enemy) |*e| {
            e.draw();
        }
    }
};
