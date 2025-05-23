local menu          = require "menu"
local primeira_fase = require "primeira_fase"
local segunda_fase  = require "segunda_fase"
local terceira_fase = require "terceira_fase"
local menu_respawn  = require "menu_respawn"
local gameOverMenu  = require "GameOverMenu"
local Pontos        = require "pontos"
local fonte         = require "fonte"
local Cutscene      = require "cutscene"

local gameState = "menu"
local overlay = nil
local lastPhase = nil
local keyBuffer = {}

local cutscene = nil
local cutsceneType = nil  -- "intro", "entre2e3", "final"

local fontes = {}

local soundTrackMenu = nil

function love.keypressed(key)
    keyBuffer[key] = true
    if gameState == "cutscene" and cutscene then
        cutscene:keypressed(key)
    end
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
    soundTrackMenu = love.audio.newSource("soundEffects/clubbed-to-death-Matrix-soundtrack.mp3", "static")
    fontes.pontoRidiculo = {
        size40 = love.graphics.newFont("fonts/ComicSans.ttf",40),
        size18 = love.graphics.newFont("fonts/ComicSans.ttf",18)
    }
    fontes.pontosHacker = {
        size40 = love.graphics.newFont("fonts/times.ttf",40),
        size18 = love.graphics.newFont("fonts/times.ttf",18)
    }
    fontes.pontosArial = {
        size40 = love.graphics.newFont("fonts/Wingding.ttf",40),
        size18 = love.graphics.newFont("fonts/Wingding.ttf",18)
    }
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
            if choice == "primeira_fase" then
                cutscene = Cutscene.new({
                    "cutscenes/Intro/intr01.png",
                    "cutscenes/Intro/intro02.png",
                    "cutscenes/Intro/intro03.png",
                    "cutscenes/Intro/intro04.png",
                    "cutscenes/Intro/intro05.png",
                    "cutscenes/Intro/intro06.png",
                    "cutscenes/Intro/intro07.png",
                    "cutscenes/Intro/intro08.png",
                    "cutscenes/Intro/intro09.png",
                    "cutscenes/Intro/intro10.png",
                    "cutscenes/Intro/intro11.png",
                    "cutscenes/Intro/intro12.png",
                    "cutscenes/Intro/intro13.png",
                    "cutscenes/Intro/intro14.png",
                    "cutscenes/Intro/intro15.png",
                    "cutscenes/Intro/intro16.png",
                })
                cutsceneType = "intro"
                gameState = "cutscene"
            else
                gameState = choice
            end
        end)

    elseif gameState == "cutscene" then
        if cutscene.finished then
            if cutsceneType == "intro" then
                primeira_fase.load()
                gameState = "primeira_fase"
            elseif cutsceneType == "entre2e3" then
                terceira_fase.load()
                gameState = "terceira_fase"
            elseif cutsceneType == "final" then
                gameState = "menu"
            end
        else
            cutscene:update(dt)
        end

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
            cutscene = Cutscene.new({
                "cutscenes/boss/boss_scene.png",
                "cutscenes/boss/boss_scene2.png",
                "cutscenes/boss/boss_scene3.png",
                "cutscenes/boss/boss_scene4.png",
                "cutscenes/boss/boss_scene5.png",
                "cutscenes/boss/boss_scene6.png",
                "cutscenes/boss/boss_scene7.png",
                "cutscenes/boss/boss_scene8.png",
                "cutscenes/boss/boss_scene9.png",
                "cutscenes/boss/boss_scene10.png",
                "cutscenes/boss/boss_scene11.png",
                -- adicione mais imagens conforme necessário
            })
            cutsceneType = "entre2e3"
            gameState = "cutscene"
        end

    elseif gameState == "terceira_fase" then
        local status = terceira_fase.update(dt)
        if status == "dead" then
            lastPhase = "terceira_fase"
            overlay = "gameover"
        elseif status == "exit" then
            cutscene = Cutscene.new({
                "cutscenes/final/final-scene.png",
                "cutscenes/final/final-scene2.png",
                "cutscenes/final/final-scene3.png",
                "cutscenes/final/final-scene4.png",
                "cutscenes/final/final-scene5.png",
                "cutscenes/final/final-scene6.png",
                "cutscenes/final/final-scene7.png",
                "cutscenes/final/final-scene8.png",
                "cutscenes/final/final-scene9.png",
                "cutscenes/final/final-scene10.png",
                "cutscenes/final/final-scene11.png",
                -- adicione mais imagens conforme necessário
            })
            cutsceneType = "final"
            gameState = "cutscene"
        end
    end
end

function love.draw()
    if gameState == "menu" then
        soundTrackMenu:play()
        menu.draw()
    elseif gameState == "cutscene" and cutscene then
        cutscene:draw()
    elseif gameState == "primeira_fase" then
        soundTrackMenu:stop()
        primeira_fase.draw()
        love.graphics.setFont(fontes.pontoRidiculo.size40)
        love.graphics.print("Pontos: " .. Pontos.get(), 10, 10)
        fonte.setar(fontes.pontoRidiculo.size18)
    elseif gameState == "segunda_fase" then
        segunda_fase.draw()
        love.graphics.setFont(fontes.pontosHacker.size40)
        love.graphics.print("Pontos: " .. Pontos.get(), 10, 10)
        fonte.setar(fontes.pontosHacker.size18)
    elseif gameState == "terceira_fase" then
        terceira_fase.draw()
        love.graphics.setFont(fontes.pontosArial.size40)
        love.graphics.print("Pontos: " .. Pontos.get(), 10, 10)
        fonte.setar(fontes.pontosArial.size18)
    end

    if overlay == "respawn" then
        menu_respawn.draw()
    elseif overlay == "gameover" then
        gameOverMenu.draw()
    end
end
