const std = @import("std");
const rl = @import("raylib");

pub const SCREEN_WIDTH = 800;
pub const SCREEN_HEIGHT = 450;

pub const Sprite = struct {
    frameWidth: f32,
    frameHeight: f32,
    frameTotal: f32,
    frameSpeed: f32,
    currentFrame: f32,
    frameCounter: f32,
    spriteSheet: rl.Texture2D,

    pub fn init(frameWidth: f32, frameHeight: f32, frameTotal: f32, frameSpeed: f32, texture: rl.Texture2D) Sprite {
        return Sprite{
            .frameWidth = frameWidth,
            .frameHeight = frameHeight,
            .frameTotal = frameTotal,
            .frameSpeed = frameSpeed,
            .currentFrame = 0,
            .frameCounter = 0,
            .spriteSheet = texture,
        };
    }

    pub fn deinit(self: *Sprite) void {
        self.spriteSheet.unload();
    }

    pub fn update(self: *Sprite) void {
        self.frameCounter += 1;

        if (self.frameCounter >= self.frameSpeed) {
            self.frameCounter = 0;
            self.currentFrame += 1;

            if (self.currentFrame >= self.frameTotal) {
                self.currentFrame = 0;
            }
        }
    }

    pub fn draw(self: *Sprite, posX: f32, posY: f32) void {
        const sourceRec = rl.Rectangle{
            .x = self.frameWidth * self.currentFrame,
            .y = 0,
            .width = self.frameWidth,
            .height = self.frameHeight,
        };

        const dstRec = rl.Rectangle{
            .x = posX,
            .y = posY,
            .width = self.frameWidth,
            .height = self.frameHeight,
        };

        const origin = rl.Vector2{ .x = 0, .y = 0 };
        const rotation = 0.0;

        rl.drawTexturePro(self.spriteSheet, sourceRec, dstRec, origin, rotation, rl.Color.white);
    }
};

pub const Bullet = struct {
    position: rl.Vector2,
    speed: f32,
    active: bool,
    sprite: Sprite,
    isEnemy: bool,
    demage: u32,

    pub fn init(posX: f32, posY: f32, speed: f32, sprite: Sprite, isEnemy: bool, demage: u32) Bullet {
        return Bullet{
            .position = rl.Vector2.init(posX, posY),
            .speed = speed,
            .active = true,
            .sprite = sprite,
            .isEnemy = isEnemy,
            .demage = demage,
        };
    }

    pub fn update(self: *Bullet) void {
        if (self.active) {
            self.sprite.update();
            if (self.isEnemy) {
                self.position.y += self.speed;
            } else {
                self.position.y -= self.speed;
            }
            if (self.position.y < 0 or self.position.y > SCREEN_HEIGHT) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: *Bullet) void {
        if (self.active) {
            self.sprite.draw(self.position.x, self.position.y);
        }
    }
};

pub const Bgm = struct {
    musicStream: rl.Music,
    soundVolume: f32,
    pause: bool,

    pub fn init(musicStream: rl.Music, soundVolume: f32) Bgm {
        return Bgm{
            .musicStream = musicStream,
            .soundVolume = soundVolume,
            .pause = false,
        };
    }

    pub fn deinit(self: *Bgm) void {
        rl.unloadMusicStream(self.musicStream);
    }

    pub fn play(self: *Bgm) void {
        rl.setMusicVolume(self.musicStream, self.soundVolume);
        rl.playMusicStream(self.musicStream);
    }

    pub fn update(self: *Bgm) void {
        rl.updateMusicStream(self.musicStream);

        if (rl.isKeyPressed(rl.KeyboardKey.key_p)) {
            self.pause = !self.pause;

            if (self.pause) rl.pauseMusicStream(self.musicStream) else rl.resumeMusicStream(self.musicStream);
        }
    }
};

pub const Background = struct {
    stage: u8,
    texture: rl.Texture2D,

    pub fn init(stage: u8, texture: rl.Texture2D) Background {
        return Background{
            .stage = stage,
            .texture = texture,
        };
    }

    pub fn deinit(self: *Background) void {
        self.texture.unload();
    }

    pub fn draw(self: *Background) void {
        // clear color
        rl.clearBackground(rl.Color.white);

        // teture
        const backgroundWidth: f32 = @floatFromInt(self.texture.width);
        const backgroundHeight: f32 = @floatFromInt(self.texture.height);
        const srcRect = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = backgroundWidth,
            .height = backgroundHeight,
        };

        const dstRect = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = SCREEN_WIDTH,
            .height = SCREEN_HEIGHT,
        };

        const origin = rl.Vector2{ .x = 0, .y = 0 };
        rl.drawTexturePro(self.texture, srcRect, dstRect, origin, 0.0, rl.Color.white);
    }
};

pub const Ground = struct {
    texture: rl.Texture2D,
    x: f32,
    y: f32,
    speed: f32,

    pub fn init(texture: rl.Texture2D, x: f32, y: f32, speed: f32) Ground {
        return Ground{
            .texture = texture,
            .x = x,
            .y = y,
            .speed = speed,
        };
    }

    pub fn deinit(self: *Ground) void {
        self.texture.unload();
    }

    pub fn update(self: *Ground) void {
        self.y += self.speed;

        if (self.y >= SCREEN_HEIGHT) {
            self.y = 0;
        }
    }

    pub fn draw(self: *Ground) void {
        const y: i32 = @intFromFloat(self.y);
        const x: i32 = @intFromFloat(self.x);

        rl.drawTexture(self.texture, x, y - SCREEN_HEIGHT, rl.Color.white);
        rl.drawTexture(self.texture, x, y, rl.Color.white);
    }
};
