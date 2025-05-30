local utils = {}

local Pontos = require "pontos"

--[[
Função: limitarCamera
Descrição: Centraliza a câmera no jogador e impede que ela vá além do mapa.
Usa HUMP Camera.
]]
function utils.limitarCamera(camera, targetX, targetY, mapWidth, mapHeight, screenWidth, screenHeight)
    local halfW = screenWidth / 2
    local halfH = screenHeight / 2

    local minX = halfW
    local maxX = math.max(halfW, mapWidth - halfW)

    -- Garante que o valor mínimo de Y nunca permita a câmera descer além do fundo
    local minY = halfH
    local maxY = math.max(halfH, mapHeight - halfH)

    -- Se o mapa for menor que a tela, centraliza a câmera no centro do mapa
    if mapHeight <= screenHeight then
        targetY = mapHeight / 2
    end

    local camX = math.max(minX, math.min(targetX, maxX))
    local camY = math.max(minY, math.min(targetY, maxY))

    camera:lookAt(camX, camY)
end

-- Função genérica de colisão AABB
function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

-- Verifica se o jogador colidiu com pontos e remove os coletados
function utils.coletarPontos(player, listaDePontos)
    for i = #listaDePontos, 1, -1 do
        local p = listaDePontos[i]
        if checkCollision(player.x, player.y, player.w, player.h, p.x, p.y, p.w, p.h) then
            table.remove(listaDePontos, i)
            Pontos.add(10)
        end
    end
end

return utils
