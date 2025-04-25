local suit = require "libs.suit"
local gameOverMenu = {}

local confirmCallback = nil

function gameOverMenu.load()
end

function gameOverMenu.update(dt, callback)
    confirmCallback = callback

    local largura, altura = love.graphics.getDimensions()
    local boxW, boxH = 300, 100
    local boxX = (largura - boxW) / 2
    local boxY = (altura - boxH) / 2

    suit.Label("Game Over", { align = "center" }, boxX, boxY, boxW, 40)

    local btnW, btnH = 120, 40
    local btnX = boxX + (boxW - btnW) / 2
    local btnY = boxY + 50
    if suit.Button("Reiniciar", btnX, btnY, btnW, btnH).hit then
        if confirmCallback then confirmCallback(true) end
    end
end

function gameOverMenu.draw()
    local largura, altura = love.graphics.getDimensions()
    local boxW, boxH = 300, 100
    local boxX = (largura - boxW) / 2
    local boxY = (altura - boxH) / 2

    -- 1) overlay vermelho semi-transparente por toda a tela
    love.graphics.setColor(1, 0, 0, 0.3)
    love.graphics.rectangle("fill", 0, 0, largura, altura)

    -- 2) bloco preto semi-transparente atrás do menu
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)

    -- 3) reset de cor e desenhar o menu
    love.graphics.setColor(1, 1, 1, 1)
    suit.draw()
end

return gameOverMenu
