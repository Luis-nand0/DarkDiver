-- fase
local fase = require "fase"
-- menu
local menu = require "menu"

-- Definindo estado inicial
local gameState = { current = "menu" }

-- Não esquecer de carregar todos os lua no load
function love.load()
    menu.load()
    fase.load()
end

function love.update(dt)
    -- If para a troca de janelas
    if gameState.current == "menu" then
        menu.update(dt, gameState)
    elseif gameState.current == "fase" then
        fase.update(dt)
    end
end

function love.draw()

    -- if para a troca de janelas
    if gameState.current == "menu" then
        menu.draw()
    elseif gameState.current == "fase" then
        fase.draw()
    end
end
