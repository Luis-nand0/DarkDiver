-- Biblioteca para carregar tiled
local sti = require "libs.sti"
-- Biblioteca para colisões
local wf = require "libs.windfield"
-- Biblioteca cameras
local Camera = require "libs.hump.camera"

local Fase = {}

-- Variáveis
local cam = Camera()
local world
local mapa
local player = {}

-- Função dos colisores
local function carregarColisores(layer)
    if layer.type == "objectgroup" then
        for _, obj in ipairs(layer.objects) do
            if obj.shape == "rectangle" then
                local collider = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
                collider:setType("static")

                -- Carregar poligonos
            elseif obj.shape == "polygon" then
                if #obj.polygon > 8 then
                    print("Polígono ignorado: muitos vértices (" .. #obj.polygon .. ")")
                else
                    local vertices = {}
                    for _, v in ipairs(obj.polygon) do
                        table.insert(vertices, v.x)
                        table.insert(vertices, v.y)
                    end
                    local collider = world:newPolygonCollider(vertices)
                    collider:setType("static")
                    collider:setPosition(obj.x, obj.y)
                end

            elseif obj.shape == "polyline" then
                local points = {}
                for _, p in ipairs(obj.polyline) do
                    table.insert(points, obj.x + p.x)
                    table.insert(points, obj.y + p.y)
                end
                local collider = world:newChainCollider(points)
                collider:setType("static")
            end
        end
    end
end

function Fase.load()
    -- Carregar o mundo com WF
    world = wf.newWorld(0, 0, true)
    world:setQueryDebugDrawing(true)

    -- Carregar mapa do tiled
    mapa = sti("maps/mapa_teste.lua")

    -- Carregando as colisões
    if mapa.layers["Walls"] then
        mapa.layers["Walls"].visible = false
        carregarColisores(mapa.layers["Walls"])
    end

    -- Carregar o player
    player.collider = world:newRectangleCollider(100, 100, 32, 32)
    player.collider:setType("dynamic")
    player.collider:setFixedRotation(true)
end

function Fase.update(dt)

    -- update colisões
    world:update(dt)

    -- movimento dos personagens
    local speed = 200
    local moveX, moveY = 0, 0

    if love.keyboard.isDown("right") then moveX = speed end
    if love.keyboard.isDown("left")  then moveX = -speed end
    if love.keyboard.isDown("down")  then moveY = speed end
    if love.keyboard.isDown("up")    then moveY = -speed end

    player.collider:setLinearVelocity(moveX, moveY)

    -- Camera rastreando o jogador
    cam:lookAt(player.collider:getX(), player.collider:getY())
end

function Fase.draw()
    -- Iniciar camera
    cam:attach()

    -- Desenhar o mapa ( não usar mapa:draw)
        mapa:drawLayer(mapa.layers["fundo"])
        mapa:drawLayer(mapa.layers["detalhes"])
        mapa:drawLayer(mapa.layers["Camada de Blocos 1"])

        -- Desenha o jogador
        love.graphics.setColor(1, 0, 0)
        local px, py = player.collider:getPosition()
        love.graphics.rectangle("fill", px - 16, py - 16, 32, 32)
        love.graphics.setColor(1, 1, 1)

    cam:detach()
end

return Fase
