local menu          = require "menu"
local primeira_fase = require "primeira_fase"
local segunda_fase  = require "segunda_fase"
local menu_respawn  = require "menu_respawn"
local gameOverMenu  = require "GameOverMenu"
local Pontos        = require "pontos"

-- Estado principal: "menu", "primeira_fase", "segunda_fase"
local gameState = "menu"
-- Overlay ativo: nil, "respawn" ou "gameover"
local overlay = nil
-- Em qual fase o jogador morreu
local lastPhase = nil

-- Buffer para detectar tecla “R”
local keyBuffer = {}

--Fonte padrao
local fontePadrao = love.graphics.newFont(14)

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
    love.window.setMode(0, 0, { fullscreen = true }) 
    menu.load()
    primeira_fase.load()
    segunda_fase.load()
    menu_respawn.load()
    gameOverMenu.load()
    --Fonte para os pontos
    FontToPontos = love.graphics.newFont(32)
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
                    segunda_fase.load()
                    gameState = "segunda_fase"
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
                end
                overlay = nil
            elseif confirm == "resume" then
                overlay = nil
            end
        end)
        return
    end

    -- Atalho R para respawn manual
    if love.keyboard.wasPressed("escape") and gameState ~= "menu" then
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
            segunda_fase.load()
            gameState = "segunda_fase"
        end

    elseif gameState == "segunda_fase" then
        local status = segunda_fase.update(dt)
        if status == "dead" then
            lastPhase = "segunda_fase"
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
        love.graphics.setFont(FontToPontos)
        love.graphics.print("Pontos: " .. Pontos.get(), 10, 10)
        love.graphics.setFont(fontePadrao)
    elseif gameState == "segunda_fase" then
        segunda_fase.draw() 
        love.graphics.setFont(FontToPontos)
        love.graphics.print("Pontos: " .. Pontos.get(), 10, 10)
        love.graphics.setFont(fontePadrao)
    end

    if overlay == "respawn" then
        menu_respawn.draw()
    elseif overlay == "gameover" then
        gameOverMenu.draw()
    end
end
