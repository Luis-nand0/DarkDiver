-- O utils contêm funções criadas por nós, porém que podem ser reaproveitadas
local utils = {}

-- Funções contidas no utils atualmente (Atualizar a cada função adicionada)
-- Camera
-- Colisões 

-- Função para carregar colisores a partir de uma camada do Tiled
function utils.carregarColisores(layer, world)
    if layer.type == "objectgroup" then
        for _, obj in ipairs(layer.objects) do
            if obj.shape == "rectangle" then
                local collider = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
                collider:setType("static")

            elseif obj.shape == "polygon" then
                if #obj.polygon > 8 then
                    print("Polígono ignorado: muitos vértices (" .. #obj.polygon .. ")")
                else
                    local vertices = {}
                    for _, v in ipairs(obj.polygon) do
                        table.insert(vertices, v.x)
                        table.insert(vertices, v.y)
                    end
                    local collider = world:newPolygonCollider(vertices)
                    collider:setType("static")
                    collider:setPosition(obj.x, obj.y)
                end

            elseif obj.shape == "polyline" then
                local points = {}
                for _, p in ipairs(obj.polyline) do
                    table.insert(points, obj.x + p.x)
                    table.insert(points, obj.y + p.y)
                end
                local collider = world:newChainCollider(points)
                collider:setType("static")
            end
        end
    end
end

-- Função para limitar a câmera dentro dos limites do mapa
function utils.limitarCamera(camera, targetX, targetY, mapWidth, mapHeight, screenWidth, screenHeight)
    local halfW = screenWidth / 2
    local halfH = screenHeight / 2

    -- Define limites mínimos e máximos
    local minX = halfW
    local maxX = mapWidth - halfW
    local minY = halfH
    local maxY = mapHeight - halfH

    -- Garante que a câmera não saia do mapa
    local camX = math.max(minX, math.min(targetX, maxX))
    local camY = math.max(minY, math.min(targetY, maxY))

    camera:lookAt(camX, camY)
end

return utils
