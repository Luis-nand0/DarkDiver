local suit = require "libs.suit"
local menu_respawn = {}

local confirmCallback = nil

function menu_respawn.load()
end

function menu_respawn.update(dt, callback)
    confirmCallback = callback

    local largura, altura = love.graphics.getDimensions()
    local boxW, boxH = 300, 140
    local boxX = (largura - boxW) / 2
    local boxY = (altura - boxH) / 2

    suit.Label("Deseja reiniciar?", {align = "center"}, boxX, boxY, boxW, 40)

    if suit.Button("Sim", boxX + 30, boxY + 60, 100, 40).hit then
        if confirmCallback then
            confirmCallback(true)
        end
    end

    if suit.Button("Não", boxX + 170, boxY + 60, 100, 40).hit then
        if confirmCallback then
            confirmCallback(false)
        end
    end
end

function menu_respawn.draw()
    local largura, altura = love.graphics.getDimensions()
    local boxW, boxH = 300, 140
    local boxX = (largura - boxW) / 2
    local boxY = (altura - boxH) / 2

    -- Overlay semi-transparente em toda a tela
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, largura, altura)
    love.graphics.setColor(1, 1, 1, 1)

    -- Fundo semi-transparente apenas atrás da caixa (opcional)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)
    love.graphics.setColor(1, 1, 1, 1)

    suit.draw()
end

return menu_respawn

