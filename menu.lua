local suit = require "libs.suit"
local Menu = {}

function Menu.load()
end

-- dt: delta time
-- changeState: function(newState:string)
function Menu.update(dt, changeState)
    local w, h = love.graphics.getDimensions()
    local bw, bh = 200, 40
    local bx, by = (w - bw) / 2, h / 2

    -- Primeira Fase
    if suit.Button("Primeira Fase", bx, by - 60, bw, bh).hit then
        changeState("primeira_fase")
    end

    -- Jogar (fase principal)
    if suit.Button("Jogar", bx, by, bw, bh).hit then
        changeState("segunda_fase")
    end

    -- Sair
    if suit.Button("Sair", bx, by + 60, bw, bh).hit then
        love.event.quit()
    end
end

function Menu.draw()
    suit.draw()
end

return Menu
