local Sentinela = {}
Sentinela.__index = Sentinela

local shootSoundEffect = love.audio.newSource("soundEffects/whatsapp-whistle-notification.mp3", "static")
local deadSounFx = love.audio.newSource("soundEffects/erro.mp3", "static")

function Sentinela.new(x, y, properties)
    local self = setmetatable({}, Sentinela)
    self.x, self.y = x, y
    self.w, self.h = 32, 32  -- hitbox reduzida
    self.range = (properties and properties.range) or 200
    self.cooldown = 0
    self.bullets = {}
    self.animTimer = 0
    self.animFrame = 1
    self.bulletFrameIndex = 1
    return self
end

function Sentinela:load(world)
    self.world = world
    world:add(self, self.x, self.y, self.w, self.h)

    self.sprite = love.graphics.newImage("Spritesheets/sentinela_spritesheet.png")
    self.frames = {
        love.graphics.newQuad(0, 0, 64, 64, self.sprite),
        love.graphics.newQuad(64, 0, 64, 64, self.sprite)
    }

    self.bulletSprite = love.graphics.newImage("Spritesheets/municao_spritesheet.png")
    local sw, sh = self.bulletSprite:getDimensions()
    self.bulletFrames = {}
    for i = 0, 3 do
        table.insert(self.bulletFrames, love.graphics.newQuad(i * 64, 0, 64, 64, sw, sh))
    end
end

function Sentinela:update(dt, player)
    self.animTimer = self.animTimer + dt
    if self.animTimer >= 0.5 then
        self.animTimer = 0
        self.animFrame = self.animFrame % 2 + 1
    end

    local px, py = player:getPosition()
    local pw, ph = player.w or 64, player.h or 64
    local dx = px - (self.x + self.w / 2)
    local dy = py - (self.y + self.h / 2)
    local dist = math.sqrt(dx * dx + dy * dy)

    self.cooldown = self.cooldown - dt
    if dist < self.range and self.cooldown <= 0 then
        local frameIndex = self.bulletFrameIndex
        self.bulletFrameIndex = self.bulletFrameIndex % #self.bulletFrames + 1
        shootSoundEffect:stop()
        shootSoundEffect:play()
        table.insert(self.bullets, {
            x = self.x + self.w / 2,
            y = self.y + self.h / 2,
            vx = dx / dist * 300,
            vy = dy / dist * 300,
            frame = frameIndex
        })
        self.cooldown = 2
    end

    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt

        -- Hitbox reduzida e centralizada no tiro (16x16)
        local bw, bh = 16, 16
        local bx = b.x + (64 - bw) / 2
        local by = b.y + (64 - bh) / 2

        if player.canPlayerDie and
           bx < px + pw and
           bx + bw > px and
           by < py + ph and
           by + bh > py then
            deadSounFx:play()
            player.dead = true
        end

        if b.x < 0 or b.y < 0 or b.x > 2000 or b.y > 2000 then
            table.remove(self.bullets, i)
        end
    end
end

function Sentinela:draw()
    love.graphics.setColor(1, 1, 1)
    -- Desenha sprite centralizada na hitbox 32x32
    love.graphics.draw(
        self.sprite,
        self.frames[self.animFrame],
        self.x - (64 - self.w) / 2,
        self.y - (64 - self.h) / 2
    )

    for _, b in ipairs(self.bullets) do
        love.graphics.draw(self.bulletSprite, self.bulletFrames[b.frame], b.x, b.y)
    end
end

return Sentinela
