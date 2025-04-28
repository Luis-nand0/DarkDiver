local Player = {}
Player.__index = Player

function Player.new()
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

    return self
end

function Player:load(world, x, y)
    self.world = world
    self.x, self.y = x, y
    self.world:add(self, self.x, self.y, self.w, self.h)
    self.dead = false
    self.reachedExit = false
end

function Player:update(dt)
if self.dead or self.reachedExit then return end

local target = 0
if love.keyboard.isDown("d", "right") then
    target = self.speed
elseif love.keyboard.isDown("a", "left") then
    target = -self.speed
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

if love.keyboard.isDown("space") and self.isGrounded then
    self.vy = -self.jumpForce
    self.isGrounded = false
end

self.vy = self.vy + self.gravity * dt

local goalX = self.x + self.vx * dt
local goalY = self.y + self.vy * dt
local actualX, actualY, cols, len = self.world:move(self, goalX, goalY)
self.x, self.y = actualX, actualY

self.isGrounded = false
self.canWallJump = false

local exitedFlag = false
for i = 1, (len or 0) do
    local col = cols[i]
    local handled = false

    -- Aqui detecta se o player morreu ao colidir com o caranguejo
    if col.other.isCaranguejo or col.other.isSpike or col.other.isRebatedor then
        self.dead = true
        -- Não retorna aqui! Permite detectar saída também
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

    if col.other.isExit then
        exitedFlag = true
    end
end

if exitedFlag and not self.dead then
    self.reachedExit = true
end
end


function Player:draw()
    if self.dead then return end
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(1, 1, 1)
end

function Player:getPosition()
    return self.x + self.w / 2, self.y + self.h / 2
end

return Player
