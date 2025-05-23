local suit = require "libs.suit"
local Menu = {}

local backgroundImage

function Menu.load()
    backgroundImage = love.graphics.newImage("cutscenes/menu_background.png") -- coloque sua imagem na pasta 'imagens'
end

-- dt: delta time
-- changeState: function(newState:string)
function Menu.update(dt, changeState)
    local w, h = love.graphics.getDimensions()
    local bw, bh = 200, 40
    local bx, by = (w - bw) / 2, h / 2

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
    if backgroundImage then
        love.graphics.draw(backgroundImage, 0, 0, 0,
            love.graphics.getWidth() / backgroundImage:getWidth(),
            love.graphics.getHeight() / backgroundImage:getHeight()
        )
    end

    suit.draw()
end
 
return Menu
