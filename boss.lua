local Boss = {}
Boss.__index = Boss
local deadSounFx = love.audio.newSource("soundEffects/erro.mp3", "static")
local hitPlayer = love.audio.newSource("soundEffects/bongo-hit.mp3", "static")
local explosion = love.audio.newSource("soundEffects/cannon.mp3", "static")
local shootBoss = love.audio.newSource("soundEffects/laser-fire.mp3", "static")

local function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and x1+w1 > x2
       and y1 < y2+h2 and y1+h1 > y2
end

-- Boss sprite
local spriteImage    = love.graphics.newImage("Spritesheets/Boss_spritesheet.png")
local frameWidth     = 96
local frameHeight    = 64
local frameCount     = 2
local animationSpeed = 0.30

local quads = {}
for i=0,frameCount-1 do
    quads[i+1] = love.graphics.newQuad(
        i*frameWidth, 0,
        frameWidth, frameHeight,
        spriteImage:getDimensions()
    )
end

-- Sprite explosao
local expImage    = love.graphics.newImage("Spritesheets/explosion.png")
local expFrameW   = 128
local expFrameH   = 128
local expFrames   = 5
local expSpeed    = 0.1
local expQuads    = {}
for i=0,expFrames-1 do
    expQuads[i+1] = love.graphics.newQuad(
        i*expFrameW, 0,
        expFrameW, expFrameH,
        expImage:getDimensions()
    )
end

-- dados do boss
function Boss.new(world, x, y, props)
    local self = setmetatable({}, Boss)
    self.world = world
    self.x, self.y    = x, y
    self.w, self.h    = props.width or frameWidth, props.height or frameHeight
    self.scale        = props.scale or 2.5

    -- movimentacao
    self.speed         = props.speed or 120
    self.detectionRadius = props.detectionRadius or 200
    self.chasing       = false

    -- vida
    self.maxHealth     = props.health or 175
    self.health        = self.maxHealth

    self.bullets       = {}
    self.fireCooldown  = 0
    self.fireRate      = props.fireRate or 2

    self.invincibleTime = 0
    self.isDead        = false

    -- animação do boss
    self.currentFrame = 1
    self.frameTimer   = 0

    -- projéteis
    self.bulletSprite    = love.graphics.newImage("Spritesheets/boss_projeteis.png")
    local sw, sh = self.bulletSprite:getDimensions()
    self.bulletFrames    = {}
    for i=0,3 do
        table.insert(self.bulletFrames, love.graphics.newQuad(
            i*64,0,64,64,sw,sh
        ))
    end
    self.bulletFrameIndex = 1
    self.bulletAnimTimer  = 0

    self.expTimer     = 0
    self.expFrame     = 1

    world:add(self, self.x, self.y, self.w, self.h)
    return self
end

function Boss:update(dt, player)
   -- explosao
    if self.exploding then
        self.expTimer = self.expTimer + dt
        if self.expTimer >= expSpeed then
            self.expTimer = self.expTimer - expSpeed
            self.expFrame = self.expFrame + 1
            if self.expFrame > expFrames then
                if self.world then
                    self.world:remove(self)
                    self.world = nil
                end
                self.removed = true
            end
        end
        return
    end

    -- morte boss
    if self.isDead then return end

    -- Animação do boss
    self.frameTimer = self.frameTimer + dt
    if self.frameTimer >= animationSpeed then
        self.frameTimer = self.frameTimer - animationSpeed
        self.currentFrame = (self.currentFrame % frameCount) + 1
    end

    -- Animação dos tiros
    self.bulletAnimTimer = self.bulletAnimTimer + dt
    if self.bulletAnimTimer >= 0.1 then
        self.bulletAnimTimer = 0
        self.bulletFrameIndex = (self.bulletFrameIndex % #self.bulletFrames) + 1
    end

    if self.invincibleTime > 0 then
        self.invincibleTime = self.invincibleTime - dt
    end

    -- Perseguição e tiro
    local px, py = player:getPosition()
    local ex, ey = self.x + self.w/2, self.y + self.h/2
    local dx, dy = px-ex, py-ey
    local dist2 = dx*dx + dy*dy

    if not self.chasing and dist2 <= self.detectionRadius^2 then
        self.chasing = true
    end

    if self.chasing then
        local dist = math.sqrt(dist2)
        if dist > 0 then
            local vx, vy = self.speed*dx/dist, self.speed*dy/dist
            local goalX, goalY = self.x+vx*dt, self.y+vy*dt
            local function filter(item, other)
                if other == player then return "touch" end
                return "cross"
            end
            local ax, ay, cols, len = self.world:move(self, goalX, goalY, filter)
            self.x, self.y = ax, ay
            for i=1,len do
                if cols[i].other == player and player.canPlayerDie then
                    deadSounFx:play()
                    player.dead = true
                end
            end
        end
        self.fireCooldown = self.fireCooldown - dt
        if self.fireCooldown <= 0 then
            shootBoss:stop()
            shootBoss:play()
            self.fireCooldown = self.fireRate
            self:shoot(dx, dy)
        end
    end

    -- Colisão com tiros do player
    for i = #player.bullets, 1, -1 do
        local b = player.bullets[i]
        if checkCollision(b.x,b.y,b.w,b.h, self.x,self.y,self.w,self.h) then
            self:hit(10)
            hitPlayer:stop()
            hitPlayer:play()
            table.remove(player.bullets, i)
        end
    end

    -- Atualizar projéteis do boss
    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b.x = b.x + b.vx*dt
        b.y = b.y + b.vy*dt
        local bw, bh = 16,16
        local bx = b.x + (32-bw)/2
        local by = b.y + (32-bh)/2
        if player.canPlayerDie and checkCollision(bx,by,bw,bh, player.x,player.y,player.w,player.h) then
            player.dead = true
            table.remove(self.bullets, i)
        end
    end

    if self.health <= 0 and not self.isDead then
        self:die()
    end
end

function Boss:shoot(dx, dy)
    local norm = math.sqrt(dx*dx + dy*dy)
    if norm < 1e-5 then dx, dy, norm = 1, 0, 1 end
    dx, dy = dx/norm, dy/norm
    table.insert(self.bullets,{
        x = self.x+self.w/2-16,
        y = self.y+self.h/2-16,
        vx=dx*400, vy=dy*400,
        frame=self.bulletFrameIndex
    })
end

function Boss:hit(damage)
    if self.invincibleTime<=0 then
        self.health = self.health - damage
        if self.health>0 then
            self.invincibleTime = 1
        else
            self:die()
        end
    end
end

function Boss:die()
    explosion:play()
    self.isDead    = true
    self.exploding = true
  
end

function Boss:draw()
    -- se explodindo, desenha animação de explosão
 if self.exploding then
    if self.expFrame <= expFrames and not self.removed then
        -- centralizar quad de explosão no centro do boss
        local scale = 2.5 -- ← AUMENTE ESSE VALOR PARA UMA EXPLOSÃO MAIOR
        local px = self.x + self.w / 2
        local py = self.y + self.h / 2
        local ox = expFrameW / 2
        local oy = expFrameH / 2

        love.graphics.setColor(1,1,1)
        love.graphics.draw(expImage, expQuads[self.expFrame], px, py, 0, scale, scale, ox, oy)
    end
    return
end
    -- Explosão animada
    if self.exploding and not self.removed then
        love.graphics.setColor(1,1,1)
        local px = self.x + self.w/2 - expFrameW/2
        local py = self.y + self.h/2 - expFrameH/2
        if self.expFrame <= expFrames then
            love.graphics.draw(expImage, expQuads[self.expFrame], px, py)
        end
        return
    end
 
    if self.removed then return end

     -- Boss normal
     if self.invincibleTime>0 and math.floor(self.invincibleTime*10)%2==0 then
        love.graphics.setColor(1,0,0)
    else
        love.graphics.setColor(1,1,1)
    end

    love.graphics.draw(spriteImage, quads[self.currentFrame],
        self.x-(frameWidth*(self.scale-1))/2,
        self.y-(frameHeight*(self.scale-1))/2,
        0,self.scale,self.scale
    )

    -- Resetar cor antes de desenhar projéteis
    love.graphics.setColor(1,1,1)

    -- projéteis
    for _,b in ipairs(self.bullets) do
        love.graphics.draw(self.bulletSprite, self.bulletFrames[b.frame],b.x,b.y)
    end
end

return Boss
