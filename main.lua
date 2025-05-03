local menu          = require "menu"
local primeira_fase = require "primeira_fase"
local segunda_fase  = require "segunda_fase"
local terceira_fase = require "terceira_fase"
local menu_respawn  = require "menu_respawn"
local gameOverMenu  = require "GameOverMenu"
local Pontos        = require "pontos"
local fonte         = require "fonte"  -- ADICIONADO

-- Estado principal: "menu", "primeira_fase", "segunda_fase", "terceira_fase"
local gameState = "menu"
-- Overlay ativo: nil, "respawn" ou "gameover"
local overlay = nil
-- Em qual fase o jogador morreu
local lastPhase = nil

-- Buffer para detectar teclas
local keyBuffer = {}


function love.keypressed(key)
    keyBuffer[key] = true
end

function love.keyboard.wasPressed(key)
    if keyBuffer[key] then
        keyBuffer[key] = false
        return true
    end
    return false
end

function love.mousepressed(x, y, button)
    if overlay == nil then
        if gameState == "primeira_fase" and primeira_fase.mousepressed then
            primeira_fase.mousepressed(x, y, button)
        elseif gameState == "segunda_fase" and segunda_fase.mousepressed then
            segunda_fase.mousepressed(x, y, button)
        elseif gameState == "terceira_fase" and terceira_fase.mousepressed then
            terceira_fase.mousepressed(x, y, button)
        end
    end
end

function love.load()


 
    love.window.setMode(0, 0, { fullscreen = true }) 

    menu.load()
    primeira_fase.load()
    segunda_fase.load()
    terceira_fase.load()
    menu_respawn.load()
    gameOverMenu.load()

    FontToPontos = love.graphics.newFont(32)
end

function love.update(dt)
    if overlay == "gameover" then
        gameOverMenu.update(dt, function(restart)
            overlay = nil
            if restart then
                if lastPhase == "primeira_fase" then
                    primeira_fase.load()
                    gameState = "primeira_fase"
                elseif lastPhase == "segunda_fase" then
                    segunda_fase.load()
                    gameState = "segunda_fase"
                elseif lastPhase == "terceira_fase" then
                    terceira_fase.load()
                    gameState = "terceira_fase"
                end
            else
                gameState = "menu"
            end
        end)
        return

    elseif overlay == "respawn" then
        menu_respawn.update(dt, function(confirm)
            if confirm == true then
                if gameState == "primeira_fase" then
                    primeira_fase.load()
                elseif gameState == "segunda_fase" then
                    segunda_fase.load()
                elseif gameState == "terceira_fase" then
                    terceira_fase.load()
                end
                overlay = nil
            elseif confirm == "resume" then
                overlay = nil
            end
        end)
        return
    end

    if love.keyboard.wasPressed("escape") and gameState ~= "menu" then
        overlay = "respawn"
        return
    end

    if gameState == "menu" then
        menu.update(dt, function(choice)
            gameState = choice
        end)

    elseif gameState == "primeira_fase" then
        local status = primeira_fase.update(dt)
        if status == "dead" then
            lastPhase = "primeira_fase"
            overlay = "gameover"
        elseif status == "exit" then
            segunda_fase.load()
            gameState = "segunda_fase"
        end

    elseif gameState == "segunda_fase" then
        local status = segunda_fase.update(dt)
        if status == "dead" then
            lastPhase = "segunda_fase"
            overlay = "gameover"
        elseif status == "exit" then
            terceira_fase.load()
            gameState = "terceira_fase"
        end

    elseif gameState == "terceira_fase" then
        local status = terceira_fase.update(dt)
        if status == "dead" then
            lastPhase = "terceira_fase"
            overlay = "gameover"
        elseif status == "exit" then
            gameState = "menu"
        end
    end
end

function love.draw()
    if gameState == "menu" then
        menu.draw()
    elseif gameState == "primeira_fase" then
        primeira_fase.draw()
    
        love.graphics.print("Pontos: " .. Pontos.get(), 10, 10)
    elseif gameState == "segunda_fase" then
        segunda_fase.draw()
     
        love.graphics.print("Pontos: " .. Pontos.get(), 10, 10)
    elseif gameState == "terceira_fase" then
        terceira_fase.draw()
       
        love.graphics.print("Pontos: " .. Pontos.get(), 10, 10)
    end

    if overlay == "respawn" then
        menu_respawn.draw()
    elseif overlay == "gameover" then
        gameOverMenu.draw()
    end
end
