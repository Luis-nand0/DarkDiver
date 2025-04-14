-- Biblioteca do Menu 
local suit = require "libs.suit"

local Menu = {}

function Menu.load()
 
end


function Menu.update(dt, gameState)

    local largura, altura = love.graphics.getDimensions()

    -- Definindo local do menu
    local btnW, btnH = 200, 40
    local btnX = (largura - btnW) / 2
    local btnY = altura / 2

    -- iniciar fase
    if suit.Button("Jogar", {id = 1}, btnX, btnY, btnW, btnH).hit then
        gameState.current = "fase"
    end

   
    -- sair
    if suit.Button("Sair", {id = 2}, btnX, btnY + 60, btnW, btnH).hit then
        love.event.quit()
    end
end

function Menu.draw()
    suit.draw()
end

return Menu
