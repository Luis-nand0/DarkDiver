-- Boss.lua
local Boss = {}
Boss.__index = Boss

-- Função para checar colisão AABB
local function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x1 + w1 > x2 and
           y1 < y2 + h2 and
           y1 + h1 > y2
end

function Boss.new(world, x, y, props)
    local self = setmetatable({}, Boss)
    self.world = world
    self.x, self.y = x, y
    self.w = props.width or 32
    self.h = props.height or 32
    self.speed = props.speed or 120
    self.detectionRadius = props.detectionRadius or 200
    self.chasing = false

    self.maxHealth = props.health or 175
    self.health = self.maxHealth

    self.bullets = {}
    self.fireCooldown = 0
    self.fireRate = props.fireRate or 1.5

    self.invincibleTime = 0
    self.isDead = false

    world:add(self, self.x, self.y, self.w, self.h)
    return self
end

function Boss:update(dt, player)
    if self.isDead then return end

    -- ver invencibilidade
    if self.invincibleTime > 0 then
        self.invincibleTime = self.invincibleTime - dt
    end

    -- perseguir e atirar
    local px, py = player:getPosition()
    local ex, ey = self.x + self.w/2, self.y + self.h/2
    local dx, dy = px - ex, py - ey
    local dist2 = dx*dx + dy*dy

    if not self.chasing and dist2 <= self.detectionRadius^2 then
        self.chasing = true
    end

    if self.chasing then
        -- movimento (ignora colisões com blocos)
        local dist = math.sqrt(dist2)
        if dist > 0 then
            local vx, vy = self.speed * dx/dist, self.speed * dy/dist
            local goalX, goalY = self.x + vx*dt, self.y + vy*dt
            local function filter(item, other)
                if other == player then return "touch" end
                return "cross"
            end
            local ax, ay, cols, len = self.world:move(self, goalX, goalY, filter)
            self.x, self.y = ax, ay
            for i=1, len do
                if cols[i].other == player then
                    player.dead = true
                end
            end
        end

        -- atirar
        self.fireCooldown = self.fireCooldown - dt
        if self.fireCooldown <= 0 then
            self.fireCooldown = self.fireRate
            self:shoot(dx, dy)
        end
    end

    -- detectar tiros do player
    for i=#player.bullets,1,-1 do
        local b = player.bullets[i]
        if checkCollision(b.x,b.y,b.w,b.h, self.x,self.y,self.w,self.h) then
            self:hit(10)
            table.remove(player.bullets, i)
        end
    end

    -- atualizar projéteis do boss
    for i=#self.bullets,1,-1 do
        local b = self.bullets[i]
        b.x = b.x + b.vx*dt
        b.y = b.y + b.vy*dt
        if checkCollision(b.x,b.y,b.w,b.h, player.x,player.y,player.w,player.h) then
            player.dead = true
            table.remove(self.bullets, i)
        end
    end

    -- verificar morte
    if self.health <= 0 and not self.isDead then
        self:die()
    end
end

function Boss:shoot(dx, dy)
    local norm = math.sqrt(dx*dx + dy*dy)
    if norm < 1e-5 then dx,dy,norm = 1,0,1 end
    dx, dy = dx/norm, dy/norm

    local speed, size = 400, 12
    table.insert(self.bullets, {
        x = self.x + self.w/2 - size/2,
        y = self.y + self.h/2 - size/2,
        vx = dx*speed,
        vy = dy*speed,
        w = size, h = size
    })
end

function Boss:hit(damage)
    if self.invincibleTime <= 0 then
        self.health = self.health - damage
        if self.health > 0 then
            self.invincibleTime = 1
        else
            self:die()
        end
    end
end

function Boss:die()
    self.isDead = true
    self.world:remove(self)
    -- aqui você pode disparar um evento ou som de morte
end

function Boss:draw()
    if self.isDead then return end

    -- desenha o boss
    if self.invincibleTime % 0.2 < 0.1 then
        love.graphics.setColor(1,0,0)
    else
        love.graphics.setColor(0,0,1)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- projéteis do boss
    love.graphics.setColor(1,1,0)
    for _,b in ipairs(self.bullets) do
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
    end

    
end

return Boss
