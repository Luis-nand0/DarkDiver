local Player = {}
Player.__index = Player

function Player.new(cam)
    local self = setmetatable({}, Player)

    self.x, self.y = 0, 0
    self.w, self.h = 48, 48

    self.vx, self.vy = 0, 0
    self.speed = 300
    self.jumpForce = 425
    self.gravity = 1200
    self.acceleration = 2500
    self.friction = 2000

    self.isGrounded = false
    self.canWallJump = false
    self.dead = false
    self.reachedExit = false
    self.facing = 1

    self.bullets = {}
    self.shootEnabled = true
    self.shootCooldown = 0
    self.shootRate = 0.5

    self.cam = cam

    self.animTimer = 0
    self.animFrame = 1
    self.jumpAnimTimer = 0
    self.jumping = false
    self.falling = false

    self.sprites = {}
    self.sprite = nil

    return self
end

function Player:load(world, x, y)
    self.world = world
    self.x, self.y = x, y
    self.dead = false
    self.reachedExit = false

    self.world:add(self, self.x, self.y, self.w, self.h)

    self.sprites[1] = love.graphics.newImage("Spritesheets/driver2.png")
    self.sprites[2] = love.graphics.newImage("Spritesheets/diver3.png")
    self.sprites[3] = love.graphics.newImage("Spritesheets/diver4.png") -- pulo
    self.sprites[4] = love.graphics.newImage("Spritesheets/diver5.png") -- queda
    self.sprites[5] = love.graphics.newImage("Spritesheets/diver6.png") -- walljump
    self.sprite = self.sprites[1]
end

function Player:update(dt, mapa)
    if self.dead or self.reachedExit then return end

    -- Movimento horizontal
    local target = 0
    if love.keyboard.isDown("d", "right") then
        target = self.speed
        self.facing = 1
    elseif love.keyboard.isDown("a", "left") then
        target = -self.speed
        self.facing = -1
    end

    if self.vx < target then
        self.vx = math.min(self.vx + self.acceleration * dt, target)
    elseif self.vx > target then
        self.vx = math.max(self.vx - self.acceleration * dt, target)
    end

    if target == 0 then
        if self.vx > 0 then
            self.vx = math.max(self.vx - self.friction * dt, 0)
        elseif self.vx < 0 then
            self.vx = math.min(self.vx + self.friction * dt, 0)
        end
    end

    -- Pulo
    if love.keyboard.isDown("space") and self.isGrounded then
        self.vy = -self.jumpForce
        self.isGrounded = false
        self.sprite = self.sprites[3]
        self.jumpAnimTimer = 0.2
        self.jumping = true
        self.falling = false
    end

    -- Gravidade
    local extraGravity = 0
    if love.keyboard.isDown("s", "down") and not self.isGrounded then
        extraGravity = 1500
    end
    self.vy = self.vy + (self.gravity + extraGravity) * dt

    -- Movimento com colisão
    local goalX = self.x + self.vx * dt
    local goalY = self.y + self.vy * dt
    local actualX, actualY, cols, len = self.world:move(self, goalX, goalY)
    self.x, self.y = actualX, actualY

    self.isGrounded = false
    self.canWallJump = false

    local exitFlag = false

    for i = 1, len do
        local col = cols[i]
        local other = col.other
        local handled = false

        if other.isCaranguejo or other.isSpike or other.isRebatedor then
            self.dead = true
        end

        if other.isJumpBlock and col.normal.y < 0 and self.vy >= 0 then
            self.vy = -(other.forcaDoPulo or 600)
            handled = true
        end

        if other.isWallJumpBlock and col.normal.x ~= 0 then
            self.canWallJump = true
            self.wallJumpDirection = other.jumpDirection
            self.sprite = self.sprites[5]

            if love.keyboard.isDown("space") then
                self.vx = (self.wallJumpDirection == "left") and -500 or 500
                self.vy = -400
                self.canWallJump = false
            end
            handled = true
        end

        if not handled then
            if col.normal.y < 0 then
                self.isGrounded = true
                self.vy = 0
                self.falling = false
            elseif col.normal.y > 0 then
                self.vy = 0
            end
        end

        if other.isExit then
            exitFlag = true
        end
    end

    if exitFlag and not self.dead then
        self.reachedExit = true
    end

    -- Animações
    if self.jumping then
        self.jumpAnimTimer = self.jumpAnimTimer - dt
        if self.jumpAnimTimer <= 0 then
            self.jumping = false
            self.sprite = self.sprites[1]
        end
    elseif not self.isGrounded then
        self.falling = true
        self.sprite = self.sprites[4]
    end

    if self.shootEnabled then
        self.shootCooldown = math.max(self.shootCooldown - dt, 0)
    end

    -- Tiros
    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt

        if b.x < -100 or b.x > mapa.width * mapa.tilewidth + 100 or
           b.y < -100 or b.y > mapa.height * mapa.tileheight + 100 then
            table.remove(self.bullets, i)
        end
    end

    -- Animação de corrida
    if math.abs(self.vx) > 10 then
        self.animTimer = self.animTimer + dt
        if self.animTimer >= 0.15 then
            self.animFrame = self.animFrame % 2 + 1
            if not self.jumping and not self.falling then
                self.sprite = self.sprites[self.animFrame]
            end
            self.animTimer = 0
        end
    else
        self.animFrame = 1
        if not self.jumping and not self.falling then
            self.sprite = self.sprites[1]
        end
    end
end

function Player:shoot(screenX, screenY)
    if self.shootCooldown > 0 then return end

    local bulletSpeed = 400
    local size = 8
    local px = self.x + self.w / 2
    local py = self.y + self.h / 2

    local mx, my = self.cam:worldCoords(screenX, screenY)
    local dx, dy = mx - px, my - py
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist == 0 then return end

    dx, dy = dx / dist, dy / dist

    table.insert(self.bullets, {
        x = px - size / 2,
        y = py - size / 2,
        vx = dx * bulletSpeed,
        vy = dy * bulletSpeed,
        w = size,
        h = size
    })

    self.shootCooldown = self.shootRate
end

function Player:mousepressed(x, y, button)
    if self.shootEnabled and button == 1 then
        self:shoot(x, y)
    end
end

function Player:draw()
    if not self.dead then
        local scaleX = self.facing
        love.graphics.draw(
            self.sprite,
            self.x + self.w / 2, self.y + self.h / 2,
            0,
            scaleX, 1,
            32, 32
        )
    end

    -- Hitbox do player
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    love.graphics.setColor(1, 1, 1)

    -- Tiros
    love.graphics.setColor(0, 1, 1)
    for _, b in ipairs(self.bullets) do
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
    end
    love.graphics.setColor(1, 1, 1)
end

function Player:getPosition()
    return self.x + self.w / 2, self.y + self.h / 2
end

function Player:collidesWith(x, y, w, h)
    return self.x < x + w and self.x + self.w > x and
           self.y < y + h and self.y + self.h > y
end

return Player
