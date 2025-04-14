local utils = {}

--[[
Função: limitarCamera
Descrição: Centraliza a câmera no jogador e impede que ela vá além do mapa.
Usa HUMP Camera.
]]
function utils.limitarCamera(camera, targetX, targetY, mapWidth, mapHeight, screenWidth, screenHeight)
    local halfW = screenWidth / 2
    local halfH = screenHeight / 2

    -- Limites de movimento da câmera
    local minX = halfW
    local maxX = mapWidth - halfW
    local minY = halfH
    local maxY = mapHeight - halfH

    -- Garante que a câmera siga o jogador mas fique dentro do mapa
    local camX = math.max(minX, math.min(targetX, maxX))
    local camY = math.max(minY, math.min(targetY, maxY))

    camera:lookAt(camX, camY)
end

return utils
