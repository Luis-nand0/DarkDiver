-- player.lua
local Player = {}
Player.__index = Player

function Player.new(cam)
    local self = setmetatable({}, Player)
    self.x, self.y = 0, 0
    self.w, self.h = 32, 32

    self.speed = 300
    self.jumpForce = 425
    self.vx, self.vy = 0, 0
    self.gravity = 1200
    self.acceleration = 2500
    self.friction = 2000

    self.isGrounded = false
    self.canWallJump = false
    self.dead = false
    self.reachedExit = false

    -- shooting
    self.bullets = {}
    self.shootEnabled = true
    self.shootCooldown = 0
    self.shootRate = 0.5 -- segundos entre disparos

    -- guarda câmera para conversão de coordenadas
    self.cam = cam

    return self
end

function Player:load(world, x, y)
    self.world = world
    self.x, self.y = x, y
    self.world:add(self, self.x, self.y, self.w, self.h)
    self.dead = false
    self.reachedExit = false
end

function Player:update(dt, mapa)
    if self.dead or self.reachedExit then return end

    -- movimento
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

    -- pulo
    if love.keyboard.isDown("space") and self.isGrounded then
        self.vy = -self.jumpForce
        self.isGrounded = false
    end

    local extraGravity = 0
    if love.keyboard.isDown("s", "down") and not self.isGrounded then
        extraGravity = 1500
    end
    self.vy = self.vy + (self.gravity + extraGravity) * dt

    -- colisão mundo
    local goalX = self.x + self.vx * dt
    local goalY = self.y + self.vy * dt
    local actualX, actualY, cols, len = self.world:move(self, goalX, goalY)
    self.x, self.y = actualX, actualY

    self.isGrounded = false
    self.canWallJump = false
    local exitFlag = false

    for i = 1, len do
        local col = cols[i]
        local handled = false
        if col.other.isCaranguejo or col.other.isSpike or col.other.isRebatedor then
            self.dead = true
        end
        if col.other.isJumpBlock and col.normal.y < 0 and self.vy >= 0 then
            self.vy = -(col.other.forcaDoPulo or 600)
            handled = true
        end
        if col.other.isWallJumpBlock and col.normal.x ~= 0 then
            self.canWallJump = true
            self.wallJumpDirection = col.other.jumpDirection
            if love.keyboard.isDown("space") then
                self.vx = (self.wallJumpDirection == "left" and -500) or 500
                self.vy = -400
                self.canWallJump = false
            end
            handled = true
        end
        if not handled then
            if col.normal.y < 0 then
                self.isGrounded = true
                self.vy = 0
            elseif col.normal.y > 0 then
                self.vy = 0
            end
        end
        if col.other.isExit then exitFlag = true end
    end

    if exitFlag and not self.dead then
        self.reachedExit = true
    end

    -- cooldown de tiro
    if self.shootEnabled then
        self.shootCooldown = math.max(self.shootCooldown - dt, 0)
    end

    -- atualizar projéteis
    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt
        if b.x < -100 or b.x > mapa.width * mapa.tilewidth + 100 or
           b.y < -100 or b.y > mapa.height * mapa.tileheight + 100 then
            table.remove(self.bullets, i)
        end
    end
end

function Player:shoot(screenX, screenY)
    if self.shootCooldown > 0 then return end
    local bulletSpeed = 400
    local size = 8
    -- centro do player no mundo
    local px = self.x + self.w/2
    local py = self.y + self.h/2
    -- converte coordenadas da tela para coordenadas do mundo
    local mx, my = self.cam:worldCoords(screenX, screenY)

    local dx = mx - px
    local dy = my - py
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist == 0 then return end
    dx, dy = dx/dist, dy/dist

    local b = {
        x = px - size/2,
        y = py - size/2,
        vx = dx * bulletSpeed,
        vy = dy * bulletSpeed,
        w = size,
        h = size
    }
    table.insert(self.bullets, b)
    self.shootCooldown = self.shootRate
end

function Player:mousepressed(x, y, button)
    if self.shootEnabled and button == 1 then
        self:shoot(x, y)
    end
end

function Player:draw()
    if not self.dead then
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    end
    love.graphics.setColor(0, 1, 1)
    for _, b in ipairs(self.bullets) do
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
    end
    love.graphics.setColor(1, 1, 1)
end

function Player:getPosition()
    return self.x + self.w/2, self.y + self.h/2
end

function Player:collidesWith(x, y, w, h)
    return self.x < x + w and self.x + self.w > x and
           self.y < y + h and self.y + self.h > y
end

return Player
