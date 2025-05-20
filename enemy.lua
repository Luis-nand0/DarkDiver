local Enemy = {}
Enemy.__index = Enemy
local deadSounFx = love.audio.newSource("soundEffects/erro.mp3", "static")
function Enemy.new(world, x, y, props)
    local self = setmetatable({}, Enemy)
    self.world = world
    self.x, self.y = x, y
    self.speed           = props.speed           or 120
    self.detectionRadius = props.detectionRadius or 200
    self.chasing = false
    self.facingRight = true

    local fase = props.fase or 1

    -- Define os sprites de acordo com a fase
    if fase == 1 then
        self.spriteIdle    = love.graphics.newImage("Spritesheets/perseguidor1.png")
        self.spriteChasing = love.graphics.newImage("Spritesheets/perseguidor2.png")
    elseif fase == 2 then
        self.spriteIdle    = love.graphics.newImage("Spritesheets/nacho.fase2_sprite.png")
        self.spriteChasing = love.graphics.newImage("Spritesheets/perseguidorProfundo_sprite.png")
    else
        -- Fallback (sprites padrão se a fase não for reconhecida)
        self.spriteIdle    = love.graphics.newImage("Spritesheets/perseguidor1.png")
        self.spriteChasing = love.graphics.newImage("Spritesheets/perseguidor2.png")
    end

    -- Sprite atual
    self.currentSprite = self.spriteIdle
    self.w = self.currentSprite:getWidth()
    self.h = self.currentSprite:getHeight()

    -- Adiciona no mundo
    world:add(self, self.x, self.y, self.w, self.h)

    return self
end

function Enemy:update(dt, player)
    local px, py = player:getPosition()

    if not self.chasing then
        local dx = px - (self.x + self.w / 2)
        local dy = py - (self.y + self.h / 2)
        if dx * dx + dy * dy <= self.detectionRadius ^ 2 then
            self.chasing = true

            -- Troca para sprite de perseguição
            self.currentSprite = self.spriteChasing
            local oldW, oldH = self.w, self.h
            self.w = self.currentSprite:getWidth()
            self.h = self.currentSprite:getHeight()

            -- Atualiza colisão
            self.world:remove(self)
            self.world:add(self, self.x, self.y, self.w, self.h)
        end
    end

    if self.chasing then
        local dx, dy = px - (self.x + self.w / 2), py - (self.y + self.h / 2)
        self.facingRight = dx >= 0
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > 0 then
            local vx = self.speed * dx / dist
            local vy = self.speed * dy / dist
            local goalX = self.x + vx * dt
            local goalY = self.y + vy * dt
            local actualX, actualY, cols, len = self.world:move(self, goalX, goalY)
            self.x, self.y = actualX, actualY

            for i = 1, (len or 0) do
                if cols[i].other == player then
                    deadSounFx:play()
                    player.dead = true
                end
            end
        end
    end
end

function Enemy:draw()
    local scaleX = self.facingRight and 1 or -1
    local offsetX = self.facingRight and 0 or self.w

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.currentSprite, self.x + offsetX, self.y, 0, scaleX, 1)
end

return Enemy
