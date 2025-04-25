local menu          = require "menu"
local primeira_fase = require "primeira_fase"
local fase          = require "fase"
local menu_respawn  = require "menu_respawn"
local gameOverMenu  = require "GameOverMenu"

-- Estado principal: "menu", "primeira_fase", "fase"
local gameState = "menu"
-- Overlay ativo: nil, "respawn" ou "gameover"
local overlay = nil
-- Em qual fase o jogador morreu
local lastPhase = nil

-- Buffer para detectar tecla “R”
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

function love.load()
    menu.load()
    primeira_fase.load()
    fase.load()
    menu_respawn.load()
    gameOverMenu.load()
end

function love.update(dt)
    -- Se um overlay estiver ativo, só processa ele
    if overlay == "gameover" then
        gameOverMenu.update(dt, function(restart)
            overlay = nil
            if restart then
                if lastPhase == "primeira_fase" then
                    primeira_fase.load()
                    gameState = "primeira_fase"
                else
                    fase.load()
                    gameState = "fase"
                end
            else
                gameState = "menu"
            end
        end)
        return
    elseif overlay == "respawn" then
        menu_respawn.update(dt, function(confirm)
            overlay = nil
            if confirm then
                if gameState == "primeira_fase" then
                    primeira_fase.load()
                else
                    fase.load()
                end
            end
        end)
        return
    end

    -- Atalho R para respawn manual
    if love.keyboard.wasPressed("r") and gameState ~= "menu" then
        overlay = "respawn"
        return
    end

    -- Fluxo normal
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
            fase.load()
            gameState = "fase"
        end

    elseif gameState == "fase" then
        local status = fase.update(dt)
        if status == "dead" then
            lastPhase = "fase"
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
    elseif gameState == "fase" then
        fase.draw()
    end

    if overlay == "respawn" then
        menu_respawn.draw()
    elseif overlay == "gameover" then
        gameOverMenu.draw()
    end
end
