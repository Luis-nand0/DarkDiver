-- fase.lua
local sti = require "libs.sti"
local bump = require "libs.bump"
local Camera = require "libs.hump.camera"
local utils = require "utils"
local Player = require "player"
local Blocos = require "blocos"

local Fase = {}
local cam = Camera()
local world, mapa

function Fase.load()
    -- Cria mundo de colisão
    world = bump.newWorld(32)
    
    -- Carrega mapa
    mapa = sti("maps/mapa_teste.lua", { "bump" })
    mapa:resize()

    -- 💡 Carrega blocos especiais ANTES de apagar as camadas
    Blocos.carregar(world, mapa)

    -- Agora sim, remova se quiser evitar duplicação
   

    -- Carrega colisões básicas
    mapa:bump_init(world)

    -- Oculta camadas de colisão
    for _, nome in ipairs({ "Walls", "borders", "colisores" }) do
        if mapa.layers[nome] then
            mapa.layers[nome].visible = false
        end
    end

    -- Cria jogador
    Player:load(world, 100, 100)
end


function Fase.update(dt)
    mapa:update(dt)
    Player:update(dt)
    
    -- Atualiza câmera
    local px, py = Player:getPosition()
    local mapWidth = mapa.width * mapa.tilewidth
    local mapHeight = mapa.height * mapa.tileheight
    utils.limitarCamera(
        cam, 
        px, 
        py, 
        mapWidth, 
        mapHeight, 
        love.graphics.getWidth(), 
        love.graphics.getHeight()
    )
end

function Fase.draw()
    cam:attach()
        -- Desenha camadas visuais
        for _, nome in ipairs({ "fundo", "detalhes", "Camada de Blocos 1" }) do
            if mapa.layers[nome] then
                mapa:drawLayer(mapa.layers[nome])
            end
        end
        
        Player:draw()
        
        -- Debug (opcional)
        -- require("libs.bump-debug").draw(world)
    cam:detach()
end

return Fase