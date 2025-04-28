local Rebatedor = {}
Rebatedor.__index = Rebatedor

function Rebatedor.new(x, y, properties)
   
    local self = setmetatable({}, Rebatedor)

    -- Carrega spritesheet com 6 quadros lado a lado
    self.spriteSheet = love.graphics.newImage("Spritesheets/baiacu_spritesheet.png")
    local sw, sh = self.spriteSheet:getDimensions()
    local frameCount = 6
    self.frameW = sw / frameCount
    self.frameH = sh

    -- Gera os quadros
    self.frames = {}
    for i = 1, frameCount do
        self.frames[i] = love.graphics.newQuad(
            (i-1) * self.frameW, 0,
            self.frameW, self.frameH,
            sw, sh
        )
    end

    -- Propriedades de colisão e movimento
    self.x, self.y = x, y
    self.w, self.h = self.frameW * 0.8, self.frameH *0.8
    self.vx = properties.speedX or 100
    self.vy = properties.speedY or 100
    self.isRebatedor = true

    -- Quadro atual
    self.currentFrame = 1

    return self
end

function Rebatedor:load(world)
    self.world = world
    world:add(self, self.x, self.y, self.w, self.h)
end

function Rebatedor:update(dt)
    -- Calcula novo alvo
    local goalX = self.x + self.vx * dt
    local goalY = self.y + self.vy * dt

    -- Move com rebote
    local actualX, actualY, cols, len = self.world:move(self, goalX, goalY, function() return "bounce" end)

    -- Processa colisões
    for i = 1, len do
        local col = cols[i]
        -- Colisão horizontal
        if col.normal.x ~= 0 then
            self.vx = -self.vx
            if col.normal.x > 0 then
                self.currentFrame = 2 -- bateu vindo da esquerda
            else
                self.currentFrame = 5 -- bateu vindo da direita
            end
        end
        -- Colisão vertical
        if col.normal.y ~= 0 then
            self.vy = -self.vy
            if col.normal.y > 0 then
                self.currentFrame = 3 -- bateu vindo de cima
            else
                self.currentFrame = 6 -- bateu vindo de baixo
            end
        end
    end

    -- Atualiza posição
    self.x, self.y = actualX, actualY
end

function Rebatedor:draw()
    love.graphics.draw(
        self.spriteSheet,
        self.frames[self.currentFrame],
        self.x, self.y
    )
end

return Rebatedor
