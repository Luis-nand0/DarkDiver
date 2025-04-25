-- enemy.lua
local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(world, x, y, props)
    local self = setmetatable({}, Enemy)
    self.world = world
    self.x, self.y = x, y
    self.w = props.width  or 32
    self.h = props.height or 32
    self.speed           = props.speed           or 120
    self.detectionRadius = props.detectionRadius or 200
    self.chasing         = false

    -- adiciona no world do bump
    world:add(self, self.x, self.y, self.w, self.h)
    return self
end

function Enemy:update(dt, player)
    local px, py = player:getPosition()
    -- detecta proximidade
    if not self.chasing then
        local dx = px - (self.x + self.w/2)
        local dy = py - (self.y + self.h/2)
        if dx*dx + dy*dy <= self.detectionRadius^2 then
            self.chasing = true
        end
    end

    if self.chasing then
        -- aponta para o jogador
        local dx, dy = px - (self.x + self.w/2), py - (self.y + self.h/2)
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > 0 then
            local vx = self.speed * dx/dist
            local vy = self.speed * dy/dist
            local goalX = self.x + vx * dt
            local goalY = self.y + vy * dt
            local actualX, actualY, cols, len = self.world:move(self, goalX, goalY)
            self.x, self.y = actualX, actualY
            -- se colidir com o player, mata
            for i=1,(len or 0) do
                if cols[i].other == player then
                    player.dead = true
                end
            end
        end
    end
end

function Enemy:draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(1, 1, 1)
end

return Enemy
