local sti    = require "libs.sti"
local bump   = require "libs.bump"
local Camera = require "libs.hump.camera"
local utils  = require "utils"
local Player = require "player"
local Blocos = require "blocos"
local Enemy  = require "enemy"
local Sentinela = require "sentinela"

local primeira_fase = {}
local cam = Camera()
local world, mapa, player
local enemies = {}
local sentinelas = {}

-- Função auxiliar para encontrar a posição de spawn do jogador
local function encontrarSpawn(mapa)
    local x, y = 100, 100
    local layer = mapa.layers["spawn"]
    if layer and layer.objects then
        for _, obj in ipairs(layer.objects) do
            if obj.name == "playerSpawn" then
                x, y = obj.x, obj.y
                break
            end
        end
    end
    return x, y
end

function primeira_fase.load()
    world = bump.newWorld(32)
    mapa  = sti("maps/primeira_fase.lua", { "bump" })
    mapa:resize()

    Blocos.carregar(world, mapa)
    mapa:bump_init(world)

    -- Zonas de saída
    local exitLayer = mapa.layers["exitZone"]
    if exitLayer and exitLayer.objects then
        for _, obj in ipairs(exitLayer.objects) do
            if obj.properties and obj.properties.isExit then
                local zone = { x = obj.x, y = obj.y, w = obj.width, h = obj.height, isExit = true }
                world:add(zone, obj.x, obj.y, obj.width, obj.height)
            end
        end
    end

    -- Oculta camadas de colisão visuais
    for _, n in ipairs({ "Walls_fase1", "borders_fase1" }) do
        if mapa.layers[n] then mapa.layers[n].visible = false end
    end

    -- Spawna jogador
    local sx, sy = encontrarSpawn(mapa)
    player = Player.new()
    player:load(world, sx, sy)

    -- Carrega inimigos normais
    enemies = {}
    local enemyLayer = mapa.layers["enemies"]
    if enemyLayer and enemyLayer.objects then
        for _, obj in ipairs(enemyLayer.objects) do
            if obj.properties and obj.properties.isEnemy then
                local e = Enemy.new(world, obj.x, obj.y, {
                    width           = obj.width,
                    height          = obj.height,
                    speed           = obj.properties.speed,
                    detectionRadius = obj.properties.detectionRadius
                })
                table.insert(enemies, e)
            end
        end
    end

    -- Carrega sentinelas
    sentinelas = {}
    local sentinelaLayer = mapa.layers["enemySpawn"]
    if sentinelaLayer and sentinelaLayer.objects then
        for _, obj in ipairs(sentinelaLayer.objects) do
            if obj.name == "sentinela" then
                local s = Sentinela.new(obj.x, obj.y)
                s:load(world)
                table.insert(sentinelas, s)
            end
        end
    end
end

function primeira_fase.update(dt)
    mapa:update(dt)
    player:update(dt)

    for _, e in ipairs(enemies) do
        e:update(dt, player)
    end

    for _, s in ipairs(sentinelas) do
        s:update(dt, player)
    end

    local px, py = player:getPosition()
    utils.limitarCamera(
        cam, px, py,
        mapa.width * mapa.tilewidth,
        mapa.height * mapa.tileheight,
        love.graphics.getWidth(),
        love.graphics.getHeight()
    )

    if player.dead then
        return "dead"
    elseif player.reachedExit then
        return "exit"
    else
        return "alive"
    end
end

function primeira_fase.draw()
    cam:attach()
    for _, n in ipairs({ "fundo", "floor" }) do
        if mapa.layers[n] then mapa:drawLayer(mapa.layers[n]) end
    end

    for _, e in ipairs(enemies) do
        e:draw()
    end

    for _, s in ipairs(sentinelas) do
        s:draw()
    end

    player:draw()
    cam:detach()
end

return primeira_fase
