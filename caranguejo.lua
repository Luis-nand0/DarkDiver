local Caranguejo = {}
Caranguejo.__index = Caranguejo
local deadSounFx = love.audio.newSource("soundEffects/erro.mp3", "static")

function Caranguejo.new(x, y, properties)
    assert(properties, "Caranguejo.new: faltam propriedades!")
    local self = setmetatable({}, Caranguejo)

    -- Spritesheet e quadros
    self.spriteSheet = love.graphics.newImage("Spritesheets/roteagueijo_spitesheet.png")
    local sw, sh = self.spriteSheet:getDimensions()
    local frameCount = 2
    local frameW = sw / frameCount
    local frameH = sh
    self.frames = {
        right = love.graphics.newQuad(0,      0, frameW, frameH, sw, sh),
        left  = love.graphics.newQuad(frameW, 0, frameW, frameH, sw, sh),
    }

    -- Dimensões de colisão reduzidas (ajustado para facilitar o pulo)
    self.width, self.height = frameW * 0.8, frameH * 0.8  -- Reduzido 20%

    -- Ajuste para alinhar a imagem corretamente, deslocando o Caranguejo para cima
    self.offsetY = (frameH - self.height) / 2  -- Deslocando o Caranguejo para cima

    -- Posição e movimento
    self.x, self.y = x, y
    self.speed       = properties.speed or 100
    self.direction   = 1          -- 1 = direita, -1 = esquerda
    self.vy          = 0
    self.gravity     = properties.gravity or 1200
    self.isGrounded  = false

    self.isCaranguejo = true
    return self
end

function Caranguejo:load(world)
    self.world = world
    world:add(self, self.x, self.y, self.width, self.height)
end

function Caranguejo:update(dt, player)
    -- Aplica gravidade
    self.vy = self.vy + self.gravity * dt

    -- Calcula onde quer se mover
    local goalX = self.x + self.speed * self.direction * dt
    local goalY = self.y + self.vy * dt

    -- Move no Bump, slide para rebatidas suaves
    local actualX, actualY, cols, len =
        self.world:move(self, goalX, goalY, function(item, other)
            -- mantém slide para chão/paredes
            return "slide"
        end)

    -- Reset de chão
    self.isGrounded = false

    -- Processa colisões
    for i = 1, len do
        local col = cols[i]
        -- Se bateu no chão: para o vy e marca grounded
        if col.normal.y < 0 then
            self.isGrounded = true
            self.vy = 0
        end
        -- Se bateu em parede: inverte direção
        if col.normal.x ~= 0 then
            self.direction = -self.direction
        end
    end

    -- Atualiza posição final
    self.x, self.y = actualX, actualY

    -- Colisão com o jogador
    if player.x < self.x + self.width
    and player.x + player.w > self.x
    and player.y < self.y + self.height
    and player.y + player.h > self.y then
        deadSounFx:play()
        player.dead = true
    end
end

function Caranguejo:draw()
    local quad = (self.direction == 1) and self.frames.right or self.frames.left
    love.graphics.draw(self.spriteSheet, quad, self.x, self.y - self.offsetY)  -- Deslocando a imagem para cima
end

return Caranguejo
