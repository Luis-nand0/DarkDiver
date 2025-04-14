-- player.lua
local Player = {}
Player.__index = Player

function Player:load(world, x, y)
    self.world = world
    self.x, self.y = x, y
    self.w, self.h = 32, 32
    self.speed = 300
    self.jumpForce = 650
    self.vx, self.vy = 0, 0
    self.gravity = 1200
    self.isGrounded = false
    self.canWallJump = false

    self.world:add(self, self.x, self.y, self.w, self.h)
end

function Player:update(dt)
    -- Controle horizontal
    self.vx = 0
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        self.vx = self.speed
    elseif love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        self.vx = -self.speed
    end

    -- Pulo normal (tecla pressionada)
    if love.keyboard.isDown("space") and self.isGrounded then
        self.vy = -self.jumpForce
        self.isGrounded = false
    end

    -- Aplica gravidade
    self.vy = self.vy + self.gravity * dt

    -- Movimento
    local goalX = self.x + self.vx * dt
    local goalY = self.y + self.vy * dt

    -- Resolve colisões
    local actualX, actualY, cols, len = self.world:move(self, goalX, goalY)
    self.x, self.y = actualX, actualY

   -- Processa colisões
self.isGrounded = false
self.canWallJump = false

for i = 1, len do
    local col = cols[i]

    -- Bloco de pulo
    if col.other.isJumpBlock and col.normal.y < 0 then
        -- Verifica se o jogador está tocando a parte superior do bloco (colisão de baixo para cima)
        if not self.isGrounded then
            self.vy = -self.jumpForce  -- Ajusta a força do pulo
            self.isGrounded = true  -- Marca o jogador como no chão
        end
    end

    -- Wall-jump
    if col.other.isWallJumpBlock then
        if col.normal.x ~= 0 then
            self.canWallJump = true
            self.wallJumpDirection = col.other.jumpDirection

            if love.keyboard.isDown("space") then
                self.vx = (self.wallJumpDirection == "left" and -500) or 500
                self.vy = -400
                self.canWallJump = false
            end
        end
    end

    -- Normalização da gravidade e estado do chão
    if col.normal.y < 0 then
        self.isGrounded = true
        self.vy = 0
    elseif col.normal.y > 0 then
        self.vy = 0
    end
end
end

function Player:draw()
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    
    -- Debug
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Grounded: " .. tostring(self.isGrounded), self.x - 30, self.y - 40)
    love.graphics.print("Vy: " .. math.floor(self.vy), self.x - 30, self.y - 60)
end

function Player:getPosition()
    return self.x + self.w/2, self.y + self.h/2
end

return Player