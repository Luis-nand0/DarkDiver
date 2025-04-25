local sti    = require "libs.sti"
local bump   = require "libs.bump"
local Camera = require "libs.hump.camera"
local utils  = require "utils"
local Player = require "player"
local Blocos = require "blocos"
local Enemy  = require "enemy" -- novo

local Fase = {}
local cam = Camera()
local world, mapa
local playerInstance
local enemies = {}
local exitZones = {}

local function encontrarSpawn(mapa)
    local spawnX, spawnY = 100, 100
    local spawnLayer = mapa.layers["spawn"]
    if spawnLayer and spawnLayer.objects then
        for _, obj in ipairs(spawnLayer.objects) do
            if obj.name == "playerSpawn" then
                spawnX, spawnY = obj.x, obj.y
                break
            end
        end
    end
    return spawnX, spawnY
end

local function carregarZonasDeSaida()
    exitZones = {}
    local exitLayer = mapa.layers["exitZone"]
    if exitLayer and exitLayer.objects then
        for _, obj in ipairs(exitLayer.objects) do
            if obj.properties and obj.properties.isExit then
                table.insert(exitZones, {
                    x = obj.x,
                    y = obj.y,
                    w = obj.width,
                    h = obj.height
                })
            end
        end
    end
end

local function carregarInimigos()
    enemies = {}
    local enemyLayer = mapa.layers["enemies"]
    if enemyLayer and enemyLayer.objects then
        for _, obj in ipairs(enemyLayer.objects) do
            if obj.properties and obj.properties.isEnemy then
                local enemy = Enemy.new(world, obj.x, obj.y, {
                    width           = obj.width,
                    height          = obj.height,
                    speed           = obj.properties.speed,
                    detectionRadius = obj.properties.detectionRadius
                })
                table.insert(enemies, enemy)
            end
        end
    end
end

function Fase.load()
    world = bump.newWorld(32)
    mapa = sti("maps/mapa_teste.lua", { "bump" })
    mapa:resize()

    Blocos.carregar(world, mapa)
    mapa:bump_init(world)

    for _, nome in ipairs({ "Walls", "borders", "colisores" }) do
        if mapa.layers[nome] then
            mapa.layers[nome].visible = false
        end
    end

    carregarZonasDeSaida()
    carregarInimigos()

    local spawnX, spawnY = encontrarSpawn(mapa)
    playerInstance = Player.new()
    playerInstance:load(world, spawnX, spawnY)
end

function Fase.update(dt)
    mapa:update(dt)
    playerInstance:update(dt)

    for _, enemy in ipairs(enemies) do
        enemy:update(dt, playerInstance)
    end

    local px, py = playerInstance:getPosition()
    utils.limitarCamera(
        cam, px, py,
        mapa.width * mapa.tilewidth,
        mapa.height * mapa.tileheight,
        love.graphics.getWidth(),
        love.graphics.getHeight()
    )

    if playerInstance.dead then
        return "dead"
    end

    for _, zona in ipairs(exitZones) do
        if px > zona.x and px < zona.x + zona.w and py > zona.y and py < zona.y + zona.h then
            return "exit"
        end
    end

    return "alive"
end

function Fase.draw()
    cam:attach()
    for _, nome in ipairs({ "fundo", "detalhes", "Camada de Blocos 1" }) do
        if mapa.layers[nome] then
            mapa:drawLayer(mapa.layers[nome])
        end
    end

    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end

    playerInstance:draw()
    cam:detach()
end

return Fase
