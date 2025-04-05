-- Biblioteca para carregar tiled
local sti = require "libs.sti"
-- Biblioteca para colisões
local wf = require "libs.windfield"
-- Biblioteca cameras
local Camera = require "libs.hump.camera"
-- Utils com funções úteis
local utils = require "utils"
-- Módulo do player
local Player = require "player"

local Fase = {}

-- Variáveis principais
local cam = Camera()
local world
local mapa

function Fase.load()
    -- Criar mundo de física
    world = wf.newWorld(0, 800, true)
    world:setQueryDebugDrawing(true)

    -- Carregar o mapa
    mapa = sti("maps/mapa_teste.lua")

    -- Adicionar colisores do mapa
    if mapa.layers["Walls"] then
        mapa.layers["Walls"].visible = false
        utils.carregarColisores(mapa.layers["Walls"], world)
    end

    if mapa.layers["borders"] then
        mapa.layers["borders"].visible = false
        utils.carregarColisores(mapa.layers["borders"], world)
    end

    -- Iniciar jogador
    Player:load(world, 100, 100)
end

function Fase.update(dt)
    world:update(dt)
    mapa:update(dt)
    Player:update(dt)

    -- Pega posição do player para a câmera
    local px, py = Player:getPosition()

    -- Tamanho do mapa
    local mapWidth = mapa.width * mapa.tilewidth
    local mapHeight = mapa.height * mapa.tileheight

    -- Tamanho da janela
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    utils.limitarCamera(cam, px, py, mapWidth, mapHeight, screenWidth, screenHeight)
end

function Fase.draw()
    cam:attach()

    -- Desenhar camadas visíveis
    mapa:drawLayer(mapa.layers["fundo"])
    mapa:drawLayer(mapa.layers["detalhes"])
    mapa:drawLayer(mapa.layers["Camada de Blocos 1"])

    -- Desenhar jogador
    Player:draw()

    cam:detach()


end

return Fase
