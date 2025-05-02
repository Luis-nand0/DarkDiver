local Boss = {}
Boss.__index = Boss

-- Função para checar colisão (substituindo utils)
function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
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
    self.health = props.health or 250 -- Quantidade de vida inicial do boss, pode ser ajustada

    self.bullets = {}
    self.fireCooldown = 1
    self.fireRate =  1.5 -- segundos entre disparos

    self.invincibleTime = 0 -- Tempo de invencibilidade após ser atingido

    world:add(self, self.x, self.y, self.w, self.h)
    return self
end

function Boss:update(dt, player)
    local px, py = player:getPosition()
    local ex, ey = self.x + self.w/2, self.y + self.h/2

    -- Detectar jogador
    local dx = px - ex
    local dy = py - ey
    local dist2 = dx*dx + dy*dy
    if not self.chasing and dist2 <= self.detectionRadius^2 then
        self.chasing = true
    end

    if self.chasing then
        -- Movimento (ignora colisões com blocos, só "toca" o player)
        local dist = math.sqrt(dist2)
        if dist > 0 then
            local vx = self.speed * dx / dist
            local vy = self.speed * dy / dist
            local goalX = self.x + vx * dt
            local goalY = self.y + vy * dt

            local function ignoreFilter(item, other)
                if other == player then return "touch" end
                return "cross"
            end

            local actualX, actualY, cols, len = self.world:move(self, goalX, goalY, ignoreFilter)
            self.x, self.y = actualX, actualY

            for i = 1, len do
                if cols[i].other == player then
                    player.dead = true
                end
            end
        end

        -- Atirar no jogador
        self.fireCooldown = self.fireCooldown - dt
        if self.fireCooldown <= 0 then
            self.fireCooldown = self.fireRate
            self:shoot(dx, dy)
        end
    end

    -- Detectar colisão com os tiros do player
    for i = #player.bullets, 1, -1 do
        local bullet = player.bullets[i]
        if checkCollision(bullet.x, bullet.y, bullet.w, bullet.h, self.x, self.y, self.w, self.h) then
            self:hit(10)  -- dano do tiro
            table.remove(player.bullets, i)
        end
    end

    -- Atualizar projéteis do boss
    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt

        -- Colisão com o jogador
        if checkCollision(b.x, b.y, b.w, b.h, player.x, player.y, player.w, player.h) then
            player.dead = true
            table.remove(self.bullets, i)
        end
    end

    -- Gerenciar o tempo de invencibilidade
    if self.invincibleTime > 0 then
        self.invincibleTime = self.invincibleTime - dt
    end

    -- Verificar morte do Boss
    if self.health <= 0 and not self.isDead then
        self:die()
    end
end

function Boss:shoot(dx, dy)
    local norm = math.sqrt(dx*dx + dy*dy)
    if not norm or norm ~= norm or norm < 1e-5 then
        dx, dy = 1, 0
        norm = 1
    end
    dx, dy = dx / norm, dy / norm

    local speed = 500
    local bullet = {
        x = self.x + self.w/2 - 4,
        y = self.y + self.h/2 - 4,
        vx = dx * speed,
        vy = dy * speed,
        w = 12,
        h = 12
    }
    table.insert(self.bullets, bullet)
end

function Boss:hit(damage)
    if self.invincibleTime <= 0 then
        self.health = self.health - damage
        if self.health <= 0 then
            self:die()
        else
            -- Após ser atingido, entra em invencibilidade
            self.invincibleTime = 1 -- Tempo de invencibilidade após ser atingido
        end
    end
end

function Boss:die()
    -- Marca o boss como morto
    self.isDead = true
    print("Boss morreu!")

    -- Remova o boss do mundo
    self.world:remove(self)
end

function Boss:draw()
    -- Desenha o inimigo
    if self.invincibleTime % 0.2 < 0.1 then
        love.graphics.setColor(1, 0, 0)  -- Boss pisca em vermelho quando invencível
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    else
        love.graphics.setColor(0, 0, 1)  -- Boss normal (azul)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    end

    -- Desenha a barra de vida
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", self.x, self.y - 10, (self.health / 100) * self.w, 5)

    -- Desenha as balas
    love.graphics.setColor(1, 1, 0)
    for _, b in ipairs(self.bullets) do
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
    end

    love.graphics.setColor(1, 1, 1)
end

return Boss
