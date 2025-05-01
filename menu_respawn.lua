local suit = require "libs.suit"
local menu_respawn = {}

local confirmCallback = nil

function menu_respawn.load()
end

function menu_respawn.update(dt, callback)
    confirmCallback = callback

    local largura, altura = love.graphics.getDimensions()
    local boxW, boxH = 300, 280
    local boxX = (largura - boxW) / 2
    local boxY = (altura - boxH) / 2

    suit.Label("Menu de pausa", {align = "center"}, boxX, boxY, boxW, 40)

    if suit.Button("Retomar", boxX + 30, boxY + 50, 240, 30).hit then
        if confirmCallback then
            confirmCallback("resume")
        end
    end

    if suit.Button("Reiniciar", boxX + 30, boxY + 90, 240, 30).hit then
        if confirmCallback then
            confirmCallback(true)
        end
    end

    if suit.Button("Alternar Tela Cheia", boxX + 30, boxY + 130, 240, 30).hit then
        local isFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not isFullscreen)
    end

    if suit.Button("Sair", boxX + 30, boxY + 170, 240, 30).hit then
        love.event.quit()
    end
end

function menu_respawn.draw()
    local largura, altura = love.graphics.getDimensions()
    local boxW, boxH = 300, 280
    local boxX = (largura - boxW) / 2
    local boxY = (altura - boxH) / 2

    -- Overlay semi-transparente
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, largura, altura)
    love.graphics.setColor(1, 1, 1, 1)

    -- Fundo da caixa
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)
    love.graphics.setColor(1, 1, 1, 1)

    suit.draw()
end

return menu_respawn
