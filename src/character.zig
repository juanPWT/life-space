const std = @import("std");
const rl = @import("raylib");
const env = @import("environment.zig");

pub const Mc = struct {
    sprite: env.Sprite,
    spriteBlow: env.Sprite,
    spriteBullet: env.Sprite,
    posX: f32,
    posY: f32,
    speed: f32,
    bullets: std.ArrayList(env.Bullet),
    // sfx
    bulletSfx: rl.Sound,
    // attri
    health: u32,
    isDead: bool,
    deathTimer: f32,

    pub fn init(speed: f32, health: u32) Mc {
        return Mc{
            .sprite = env.Sprite.init(64, 64, 4, 10, rl.loadTexture("resources/craft/mc.png")),
            .spriteBlow = env.Sprite.init(64, 64, 7, 10, rl.loadTexture("resources/craft/mc-blow.png")),
            .spriteBullet = env.Sprite.init(16, 16, 8, 5, rl.loadTexture("resources/bullets/bullet-normal.png")),
            .posX = env.SCREEN_WIDTH / 2,
            .posY = env.SCREEN_HEIGHT - 70,
            .speed = speed,
            .bullets = std.ArrayList(env.Bullet).init(std.heap.page_allocator),
            .bulletSfx = rl.loadSound("resources/sfx/beam-8-43831.mp3"),
            .health = health,
            .isDead = false,
            .deathTimer = 0.0,
        };
    }

    pub fn deinit(self: *Mc) void {
        self.sprite.deinit();
        self.spriteBlow.deinit();
        self.spriteBullet.deinit();
        self.bullets.deinit();

        // sfx
        rl.unloadSound(self.bulletSfx);
    }

    pub fn update(self: *Mc, deltaTime: f32) !void {
        if (self.isDead) {
            self.deathTimer += deltaTime;
            self.spriteBlow.update();

            if (self.deathTimer >= 1.0) {
                // animation remove dead body
                return;
            }

            return;
        } else {
            // sprite animation update
            self.sprite.update();

            if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
                if (self.posX + self.sprite.frameWidth <= env.SCREEN_WIDTH) {
                    self.posX += 4;
                }
            } else if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
                if (self.posX != 0) {
                    self.posX -= 4;
                }
            }

            if (rl.isKeyPressed(rl.KeyboardKey.key_space)) {
                try self.shoot();

                // sfx bullet
                rl.setSoundVolume(self.bulletSfx, 0.6);
                rl.playSound(self.bulletSfx);
            }

            for (self.bullets.items) |*bullet| {
                bullet.update();
            }
        }
    }

    pub fn draw(self: *Mc) void {
        if (self.isDead) {
            if (self.deathTimer < 1.0) {
                self.spriteBlow.draw(self.posX, self.posY);
            }

            return;
        } else {
            self.sprite.draw(self.posX, self.posY);
            for (self.bullets.items) |*bullet| {
                bullet.draw();
            }
        }
    }

    pub fn shoot(self: *Mc) !void {
        const newBullet = env.Bullet.init(self.posX + (self.sprite.frameWidth / 2) - (self.spriteBullet.frameWidth / 2), self.posY, 5, self.spriteBullet, false, 20);
        try self.bullets.append(newBullet);
    }

    pub fn wasShoot(self: *Mc, bulletPosX: f32, bulletPosY: f32) bool {
        const xMax = self.posX + self.sprite.frameWidth;
        const yMax = self.posY + self.sprite.frameHeight;

        return bulletPosX >= self.posX and bulletPosX <= xMax and bulletPosY >= self.posY and bulletPosY <= yMax;
    }

    pub fn takeDemage(self: *Mc, demage: u32) void {
        if (!self.isDead) {
            if (demage >= self.health) {
                self.health = 0;
                self.isDead = true;
            } else {
                self.health -= demage;
            }
        } else {
            return;
        }
    }
};

pub const Kroco = struct {
    sprite: env.Sprite,
    spriteBullet: env.Sprite,
    spriteBlow: env.Sprite,
    posX: f32,
    posY: f32,
    speed: f32,
    directionX: f32,
    directionY: f32,
    shootingTimer: f32,
    // attri
    bullets: std.ArrayList(env.Bullet),
    health: u32,
    // con
    isDead: bool,
    deathTimer: f32,

    pub fn init(speed: f32, health: u32) Kroco {
        return Kroco{
            .sprite = env.Sprite.init(64, 57, 7, 10, rl.loadTexture("resources/enemy/kroco/kroco-1.png")),
            .spriteBullet = env.Sprite.init(16, 16, 8, 5, rl.loadTexture("resources/bullets/enemy-bullet-normal.png")),
            .spriteBlow = env.Sprite.init(64, 57, 7, 8, rl.loadTexture("resources/enemy/kroco/kroco-1-blow.png")),
            .posX = std.crypto.random.float(f32) * 70.0 - 20.0,
            .posY = std.crypto.random.float(f32) * 70.0 - 20.0,
            .speed = speed,
            .directionX = (std.crypto.random.float(f32) * 2.0) - 1.0,
            .directionY = (std.crypto.random.float(f32) * 2.0) - 1.0,
            .shootingTimer = 0.0,
            .bullets = std.ArrayList(env.Bullet).init(std.heap.page_allocator),
            .health = health,
            .isDead = false,
            .deathTimer = 0.0,
        };
    }

    pub fn deinit(self: *Kroco) void {
        self.sprite.deinit();
        self.spriteBullet.deinit();
        self.spriteBlow.deinit();
        self.bullets.deinit();
    }

    pub fn update(self: *Kroco, deltaTime: f32) !void {
        if (self.isDead) {
            self.deathTimer += deltaTime;
            self.spriteBlow.update();

            if (self.deathTimer >= 1.0) {
                // TODO wipe out dead body
                return;
            }

            return;
        } else {
            // mc
            self.sprite.update();
            // update pos random
            self.posX += self.directionX * self.speed * deltaTime;
            self.posY += self.directionY * self.speed * deltaTime;

            // check if in bounds
            if (self.posX < 0) {
                self.posX = 0;
                self.directionX *= -1;
            } else if (self.posX > env.SCREEN_WIDTH) {
                self.posX = env.SCREEN_WIDTH;
                self.directionX *= -1;
            }

            if (self.posY < 0) {
                self.posY = 0;
                self.directionY *= -1;
            } else if (self.posY > (env.SCREEN_HEIGHT / 2)) {
                self.posY = env.SCREEN_HEIGHT / 2;
                self.directionY *= -1;
            }

            // change directon random
            if (std.crypto.random.float(f32) < 0.01) {
                self.directionX = (std.crypto.random.float(f32) * 2.0) - 1.0;
                self.directionY = (std.crypto.random.float(f32) * 2.0) - 1.0;
            }

            // shooting random
            self.shootingTimer += deltaTime;
            if (self.shootingTimer >= 2.0) {
                try self.shoot();
                self.shootingTimer = 0.0;
            }

            // update bullet
            for (self.bullets.items) |*b| {
                b.update();
            }
        }
    }

    pub fn draw(self: *Kroco) void {
        if (self.isDead) {
            if (self.deathTimer < 1.0) {
                self.spriteBlow.draw(self.posX, self.posY);
            }

            return;
        } else {
            self.sprite.draw(self.posX, self.posY);
            for (self.bullets.items) |*b| {
                b.draw();
            }
        }
    }

    pub fn shoot(self: *Kroco) !void {
        const newBullet = env.Bullet.init(self.posX + (self.sprite.frameWidth / 2) - (self.spriteBullet.frameWidth / 2), self.posY + self.sprite.frameHeight, 5, self.spriteBullet, true, 20);
        try self.bullets.append(newBullet);
    }

    pub fn wasShoot(self: *Kroco, bulletPosX: f32, bulletPosY: f32) bool {
        const xMax = self.posX + self.sprite.frameWidth;
        const yMax = self.posY + self.sprite.frameHeight;

        return bulletPosX >= self.posX and bulletPosX <= xMax and bulletPosY >= self.posY and bulletPosY <= yMax;
    }

    pub fn takeDemage(self: *Kroco, demage: u32) void {
        if (!self.isDead) {
            if (demage >= self.health) {
                self.health = 0;
                self.isDead = true;
            } else {
                self.health -= demage;
            }
        } else {
            return;
        }
    }
};

pub const Kroco2 = struct {
    sprite: env.Sprite,
    spriteBullet: env.Sprite,
    spriteBlow: env.Sprite,
    posX: f32,
    posY: f32,
    speed: f32,
    directionX: f32,
    directionY: f32,
    shootingTimer: f32,
    // attri
    bullets: std.ArrayList(env.Bullet),
    health: u32,
    // con
    isDead: bool,
    deathTimer: f32,

    pub fn init(speed: f32, health: u32) Kroco2 {
        return Kroco2{
            .sprite = env.Sprite.init(64, 57, 7, 10, rl.loadTexture("resources/enemy/kroco/kroco-2.png")),
            .spriteBullet = env.Sprite.init(16, 16, 8, 5, rl.loadTexture("resources/bullets/enemy-bullet-normal.png")),
            .spriteBlow = env.Sprite.init(64, 57, 7, 8, rl.loadTexture("resources/enemy/kroco/kroco-2-blow.png")),
            .posX = std.crypto.random.float(f32) * 70.0 - 20.0,
            .posY = std.crypto.random.float(f32) * 70.0 - 20.0,
            .speed = speed,
            .directionX = (std.crypto.random.float(f32) * 2.0) - 1.0,
            .directionY = (std.crypto.random.float(f32) * 2.0) - 1.0,
            .shootingTimer = 0.0,
            .bullets = std.ArrayList(env.Bullet).init(std.heap.page_allocator),
            .health = health,
            .isDead = false,
            .deathTimer = 0.0,
        };
    }

    pub fn deinit(self: *Kroco2) void {
        self.sprite.deinit();
        self.spriteBullet.deinit();
        self.spriteBlow.deinit();
        self.bullets.deinit();
    }

    pub fn update(self: *Kroco2, deltaTime: f32) !void {
        if (self.isDead) {
            self.deathTimer += deltaTime;
            self.spriteBlow.update();

            if (self.deathTimer >= 1.0) {
                // TODO wipe out dead body
                return;
            }
        } else {
            // mc
            self.sprite.update();
            // update pos random
            self.posX += self.directionX * self.speed * deltaTime;
            self.posY += self.directionY * self.speed * deltaTime;

            // check if in bounds
            if (self.posX < 0) {
                self.posX = 0;
                self.directionX *= -1;
            } else if (self.posX > env.SCREEN_WIDTH) {
                self.posX = env.SCREEN_WIDTH;
                self.directionX *= -1;
            }

            if (self.posY < 0) {
                self.posY = 0;
                self.directionY *= -1;
            } else if (self.posY > (env.SCREEN_HEIGHT / 2)) {
                self.posY = env.SCREEN_HEIGHT / 2;
                self.directionY *= -1;
            }

            // change directon random
            if (std.crypto.random.float(f32) < 0.01) {
                self.directionX = (std.crypto.random.float(f32) * 2.0) - 1.0;
                self.directionY = (std.crypto.random.float(f32) * 2.0) - 1.0;
            }

            // shooting random
            self.shootingTimer += deltaTime;
            if (self.shootingTimer >= 2.0) {
                try self.shoot();
                self.shootingTimer = 0.0;
            }

            // update bullet
            for (self.bullets.items) |*b| {
                b.update();
            }
        }
    }

    pub fn draw(self: *Kroco2) void {
        if (self.isDead) {
            self.spriteBlow.draw(self.posX, self.posY);
        } else {
            self.sprite.draw(self.posX, self.posY);
            for (self.bullets.items) |*b| {
                b.draw();
            }
        }
    }

    pub fn shoot(self: *Kroco2) !void {
        const newBullet = env.Bullet.init(self.posX + (self.sprite.frameWidth / 2) - (self.spriteBullet.frameWidth / 2), self.posY + self.sprite.frameHeight, 5, self.spriteBullet, true, 20);
        try self.bullets.append(newBullet);
    }

    pub fn wasShoot(self: *Kroco2, bulletPosX: f32, bulletPosY: f32) bool {
        const xMax = self.posX + self.sprite.frameWidth;
        const yMax = self.posY + self.sprite.frameHeight;

        return bulletPosX >= self.posX and bulletPosX <= xMax and bulletPosY >= self.posY and bulletPosY <= yMax;
    }

    pub fn takeDemage(self: *Kroco2, demage: u32) void {
        if (!self.isDead) {
            if (demage >= self.health) {
                self.health = 0;
                self.isDead = true;
            } else {
                self.health -= demage;
            }
        } else {
            return;
        }
    }
};
