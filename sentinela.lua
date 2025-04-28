local Sentinela = {}
Sentinela.__index = Sentinela

function Sentinela.new(x, y, properties)
    local self = setmetatable({}, Sentinela)
    self.x, self.y = x, y
    self.w, self.h = 32, 32
    self.vx = (properties and properties.speed) or 60 -- velocidade vinda do Tiled, se tiver
    self.range = (properties and properties.range) or 200
    self.direcao = 1
    self.patrolMin = x - ((properties and properties.patrolDistance) or 64)
    self.patrolMax = x + ((properties and properties.patrolDistance) or 64)
    self.cooldown = 0
    self.bullets = {}
    return self
end

function Sentinela:load(world)
    self.world = world
    world:add(self, self.x, self.y, self.w, self.h)
end

function Sentinela:update(dt, player)
    -- Movimento lateral
    self.x = self.x + self.vx * dt * self.direcao
    if self.x < self.patrolMin then
        self.x = self.patrolMin
        self.direcao = 1
    elseif self.x > self.patrolMax then
        self.x = self.patrolMax
        self.direcao = -1
    end
    self.world:move(self, self.x, self.y)

    -- Área de tiro
    local px, py = player:getPosition()
    local dx = px - (self.x + self.w / 2)
    local dy = py - (self.y + self.h / 2)
    local dist = math.sqrt(dx * dx + dy * dy)

    self.cooldown = self.cooldown - dt
    if dist < self.range and self.cooldown <= 0 then
        table.insert(self.bullets, {
            x = self.x + self.w / 2,
            y = self.y + self.h / 2,
            vx = dx / dist * 300,
            vy = dy / dist * 300
        })
        self.cooldown = 2
    end

    -- Atualiza balas
    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt
        if math.abs(b.x - px) < 10 and math.abs(b.y - py) < 10 then
            player.dead = true
        end
        if b.x < 0 or b.y < 0 or b.x > 2000 or b.y > 2000 then
            table.remove(self.bullets, i)
        end
    end
end

function Sentinela:draw()
    love.graphics.setColor(1, 0.4, 0.1)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(1, 1, 0)
    for _, b in ipairs(self.bullets) do
        love.graphics.circle("fill", b.x, b.y, 8)
    end
    love.graphics.setColor(1, 1, 1)
end

return Sentinela
